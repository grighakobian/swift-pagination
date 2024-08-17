//
//  MovieDetailViewController.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 08.11.21.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage

public class MovieDetailViewController: UIViewController {
    
    private lazy var movieView = makeMovieView()
    private lazy var overviewLabel = makeOverviewLabel()
    private lazy var headingLabel = makeHeadingLabel()
    private lazy var containerView = makeContainerView()
    private lazy var collectionView = makeCollectionView()
    private lazy var stackView = makeStackView()
    private lazy var scrollView = makeScrollView()
    
    private(set) var viewModel: MovieDetailViewModel
    private(set) var dataSource: MoviesDataSource!
    
    private let disposeBag = DisposeBag()
    
    public init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use init(viewModel:) instead")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureDataSource()
        bindViewModel()
    }
    
    private func bindViewModel() {
        let onMovieSelected = collectionView.rx
            .itemSelected
            .map({ $0.item })
        
        let input = MovieDetailViewModel.Input(onMovieSelected: onMovieSelected)
        let output = viewModel.transform(input: input, disposeBag: disposeBag)
        
        output.movieDriver
            .drive(onNext: { [unowned self] item in
                navigationItem.title = item.title
                movieView.bind(item: item)
                overviewLabel.text = item.overview
            }).disposed(by: disposeBag)
        
        output.similarMoviesDriver
            .map({ $0.isEmpty })
            .drive(containerView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.similarMoviesDriver
            .drive(dataSource.rx.sectionItems)
            .disposed(by: disposeBag)
    }
    
    private func configureDataSource() {
        dataSource = MoviesDataSource(collectionView: collectionView)
    }
}


// MARK: - View Configuration

extension MovieDetailViewController {
    
    private func configureView() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        configureScrollView()
        configureStackView()
        configureCollectionView()
    }
    
    private func configureScrollView() {
        view.addSubview(scrollView)
        let safeArea = view.safeAreaLayoutGuide
        scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
    }
    
    private func configureStackView() {
        scrollView.addSubview(stackView)
        
        let layoutGuide = scrollView.contentLayoutGuide
        stackView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor).isActive = true
    }
    
    private func configureCollectionView() {
        stackView.addArrangedSubview(movieView)
        stackView.addArrangedSubview(overviewLabel)
        movieView.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.5).isActive = true
        
        containerView.addSubview(headingLabel)
        containerView.addSubview(collectionView)
        stackView.addArrangedSubview(containerView)
        containerView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        headingLabel.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        headingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        headingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: headingLabel.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
}
