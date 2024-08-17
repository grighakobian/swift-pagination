//
//  MovieDetailViewModel.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 08.11.21.
//

import Domain
import RxSwift
import RxCocoa
import RxFlow

public class MovieDetailViewModel: ViewModel, Stepper {

    public var steps = PublishRelay<Step>()
    
    private let movie: MovieRepresentable
    private let moviesSevice: Domain.MoviesService
    private let sectionItems: BehaviorRelay<[SectionItem]>
    
    public init(movie: MovieRepresentable,
                moviesSevice: Domain.MoviesService) {
        
        self.movie = movie
        self.moviesSevice = moviesSevice
        self.sectionItems = BehaviorRelay<[SectionItem]>(value: [])
    }
    
    public struct Input {
        /// Triggers when user selects a movie
        let onMovieSelected: Observable<Int>
    }
    
    public struct Output {
        let movieDriver: Driver<MovieRepresentable>
        let similarMoviesDriver: Driver<[SectionItem]>
    }
    
    public func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let movie = self.movie
        let movieDriver = Driver.just(movie)
        
        moviesSevice
            .getSimilarMovies(id: movie.id, page: 1)
            .map({ $0.results ?? [] })
            .map({ $0.filter({ $0.id != movie.id }) })
            .map({ $0.map({ SectionItem.movie(MovieItemViewModel(movie: $0)) }) })
            .catchAndReturn([])
            .asObservable()
            .bind(to: sectionItems)
            .disposed(by: disposeBag)
        
        input.onMovieSelected
            .withLatestFrom(sectionItems, resultSelector: { $1[$0] })
            .map({ $0.movieViewModel })
            .filter({ $0 != nil })
            .map({ AppStep.movieDetail($0!) })
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        return Output(movieDriver: movieDriver,
                      similarMoviesDriver: sectionItems.asDriver())
    }
}
