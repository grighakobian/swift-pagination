//
//  PopularMoviesViewModel.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 07.11.21.
//

import Domain
import RxSwift
import RxRelay
import RxFlow
import RxCocoa

public final class PopularMoviesViewModel: ViewModel, Stepper {
    
    // Stepper
    public var steps = PublishRelay<Step>()
    
    // Movies service
    private let moviesService: Domain.MoviesService
    private let sectionItems: BehaviorRelay<[SectionItem]>

    // Pagination context
    private var currentPage: Int
    private var paginationContext: PaginationContext
    private let serialScheduler: SerialDispatchQueueScheduler
    
    // Loading state handling
    private let errorTracker = ErrorTracker()
    private let activityIndicator = ActivityIndicator()
    private let initialLoadingCompleted: BehaviorRelay<Bool>
    
    public init(moviesService: Domain.MoviesService) {
        self.moviesService = moviesService
        self.currentPage = 0
        self.paginationContext = PaginationContext()
        self.sectionItems = BehaviorRelay<[SectionItem]>(value: [])
        self.serialScheduler = SerialDispatchQueueScheduler(qos: .userInteractive)
        self.initialLoadingCompleted = BehaviorRelay(value: false)
    }
    
    public struct Input {
        /// Triggers when user scrolls to the
        /// bottom of the target scroll view
        let nextPageTrigger: PublishSubject<Void>
        /// Triggers when user selects a movie
        let onMovieSelected: Observable<Int>
    }
    
    public struct Output {
        let popularMovies: Driver<[SectionItem]>
    }
    
    public func transform(input: Input, disposeBag: DisposeBag) -> Output {
        input.nextPageTrigger
            .observe(on: serialScheduler)
            .skip(while: { [unowned self] in
                if !paginationContext.isFetching {
                    paginationContext.start()
                    return false
                }
                return true
            })
            .flatMap { [unowned self] _ -> Observable<MoviesResult?> in
                return moviesService.getPopularMovies(page: currentPage + 1)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asObservable()
                    .map({ result -> MoviesResult? in
                        return result
                    })
                    .catch({ error in return Observable<MoviesResult?>.just(nil) })
            }
            .filter({ $0 != nil })
            .map({ $0! })
            .subscribe(onNext: { [unowned self] response in
                handleSuccessResponse(response)
            }, onError: { [unowned self] error in
                paginationContext.finish(false)
            }).disposed(by: disposeBag)
        
        configureActivityIndicator(disposeBag)
        configireErrorTracker(disposeBag)
        handleMovieSelection(input: input, disposeBag: disposeBag)
        
        return Output(popularMovies: sectionItems.asDriver())
    }
    
    private func configireErrorTracker(_ disposeBag: DisposeBag) {
        errorTracker.asObservable()
            .withLatestFrom(initialLoadingCompleted, resultSelector: { error, isLoaded -> Error? in
                return isLoaded ? nil : error
            })
            .filter({ $0 != nil })
            .map({ [SectionItem.state(.failed(with: $0!))] })
            .bind(to: sectionItems)
            .disposed(by: disposeBag)
    }
    
    private func configureActivityIndicator(_ disposeBag: DisposeBag) {
        activityIndicator.asObservable()
            .withLatestFrom(initialLoadingCompleted) { $0 && !$1 }
            .filter({ $0 })
            .mapVoid()
            .map({ [SectionItem.state(.loading)] })
            .bind(to: sectionItems)
            .disposed(by: disposeBag)
    }
    
    private func handleMovieSelection(input: Input, disposeBag: DisposeBag) {
        input.onMovieSelected
            .withLatestFrom(sectionItems, resultSelector: { $1[$0] })
            .map({ $0.movieViewModel })
            .filter({ $0 != nil })
            .map({ AppStep.movieDetail($0!) })
            .bind(to: steps)
            .disposed(by: disposeBag)
    }
    
    private func handleSuccessResponse(_ response: MoviesResult) {
        self.currentPage = response.page ?? 0
        let results = response.results ?? []
        var sectionItems = self.sectionItems.value
        if (initialLoadingCompleted.value == false) {
            initialLoadingCompleted.accept(true)
            sectionItems.removeAll()
        }
        let newSectionItems = results
            .map({ MovieItemViewModel(movie: $0) })
            .map({ SectionItem.movie($0) })
        sectionItems.append(contentsOf: newSectionItems)
        self.sectionItems.accept(sectionItems)
        self.paginationContext.finish(true)
    }
}
