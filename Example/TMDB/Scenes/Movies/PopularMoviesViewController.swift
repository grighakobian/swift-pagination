//
//  PopularMoviesViewController.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 07.11.21.
//

import UIKit
import Paginator

public final class PopularMoviesViewController: UICollectionViewController {
    private var currentPage: Int
    private let paginator: Paginator
    private let moviesService: MoviesService
    private var dataSource: PopularMovies.DataSource!
    
    // MARK: - Init
    
    init(moviesService: MoviesService) {
        self.currentPage = 0
        self.paginator = Paginator()
        self.moviesService = moviesService
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.6))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .flexible(20)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        super.init(collectionViewLayout: UICollectionViewCompositionalLayout(section: section))
        
        self.collectionView.backgroundColor = UIColor.systemBackground
        self.collectionView.register(MovieCollectionViewCell.self)
        self.dataSource = PopularMovies.DataSource(collectionView: collectionView) { collectionView, indexPath, movieViewModel in
            let cell = collectionView.dequeueReusableCell(ofType: MovieCollectionViewCell.self, at: indexPath)
            cell.movieView.imageView.sd_setImage(with: movieViewModel.posterImageUrl, completed: nil)
            cell.movieView.ratingLabel.text = movieViewModel.averageRating
            return cell
        }
        self.collectionView.dataSource = dataSource
        
        self.paginator.scrollableDirections = .horizontal
        self.paginator.leadingScreensForBatching = 0.2
        self.paginator.delegate = self
        self.paginator.attach(to: collectionView)
         
        self.title = "TMDB"
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use init(viewModel:) instead")
    }
        
    func loadMovies(in context: PaginationContext) {
        Task {
            do {
                context.start()
                let nextPage = currentPage + 1
                print("Start fetching page \(nextPage)")
                let moviesResult = try await moviesService.getPopularMovies(page: nextPage)
                self.updateMovies(with: moviesResult)
                self.currentPage = nextPage
                context.finish(true)
                print("Fetching completed for page \(nextPage)")
            } catch {
                context.finish(false)
            }
        }
    }
    
    @MainActor func updateMovies(with moviesResult: MoviesResult) {
        var snapshot = dataSource.snapshot()
        if snapshot.sectionIdentifiers.isEmpty {
            snapshot.appendSections([.main])
        }
        let sectionItems = (moviesResult.results ?? [])
            .map({ PopularMovies.ViewModel(movie: $0) })
        snapshot.appendItems(sectionItems, toSection: .main)
        dataSource.apply(snapshot)
    }
}

// MARK: - PaginationDelegate

extension PopularMoviesViewController: PaginationDelegate {
    
    public func paginator(_ paginator: Paginator, shouldRequestNextPageWith context: PaginationContext) -> Bool {
        return true
    }
    
    public func paginator(_ paginator: Paginator, didRequestNextPageWith context: PaginationContext) {
        loadMovies(in: context)
    }
}
