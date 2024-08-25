//
//  PopularMoviesViewController.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 07.11.21.
//

import Pagination
import UIKit

public final class PopularMoviesViewController: UICollectionViewController {
  private var currentPage: Int
  private let moviesService: MoviesService
  private var dataSource: PopularMovies.DataSource!

  // MARK: - Init

  init(moviesService: MoviesService) {
    self.currentPage = 0
    self.moviesService = moviesService
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalWidth(1.25))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.interItemSpacing = .flexible(20)
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 20
    section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
    super.init(collectionViewLayout: UICollectionViewCompositionalLayout(section: section))

    self.collectionView.backgroundColor = UIColor.systemBackground
    self.collectionView.register(MovieCollectionViewCell.self)
    self.dataSource = PopularMovies.DataSource(collectionView: collectionView) {
      collectionView, indexPath, movieViewModel in
      let cell = collectionView.dequeueReusableCell(
        ofType: MovieCollectionViewCell.self, at: indexPath)
      cell.movieView.imageView.sd_setImage(with: movieViewModel.posterImageUrl, completed: nil)
      cell.movieView.ratingLabel.text = movieViewModel.averageRating
      return cell
    }
    self.collectionView.dataSource = dataSource
    self.collectionView.pagination.delegate = self
  }

  required init?(coder: NSCoder) {
    fatalError("Use init(viewModel:) instead")
  }

  func loadMovies(using pagination: Pagination, in context: PaginationContext) {
    context.start()
    Task {
      do {
        let nextPage = currentPage + 1
        let moviesResult = try await moviesService.getPopularMovies(page: nextPage)
        self.updateMovies(with: moviesResult)
        self.currentPage = nextPage
        if let totalPages = moviesResult.totalPages {
          pagination.isEnabled = self.currentPage < totalPages
        }
        context.finish(true)
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

  public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    print(#function)
  }
}

// MARK: - PaginationDelegate

extension PopularMoviesViewController: PaginationDelegate {

  public func pagination(_ pagination: Pagination, prefetchNextPageWith context: PaginationContext)
  {
    loadMovies(using: pagination, in: context)
  }
}
