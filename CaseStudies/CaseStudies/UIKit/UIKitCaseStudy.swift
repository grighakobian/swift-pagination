#if canImport(UIKit) && !os(watchOS)
import Pagination
import SwiftUI
import UIKit

/// SwiftUI wrapper so the `RepositoriesViewController` can be shown in a navigation stack
/// and previewed without running the app.
struct UIKitCaseStudy: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> RepositoriesViewController {
    RepositoriesViewController()
  }

  func updateUIViewController(_ uiViewController: RepositoriesViewController, context: Context) {}
}

/// A `UICollectionViewController` demonstrating pagination using a compositional list layout.
final class RepositoriesViewController: UICollectionViewController {
  private let service = GitHubService()
  private var currentPage = 0
  private var hasMorePages = true

  private lazy var dataSource: UICollectionViewDiffableDataSource<Int, Repository> = {
    let registration = UICollectionView.CellRegistration<UICollectionViewListCell, Repository> {
      cell, _, repo in
      var content = cell.defaultContentConfiguration()
      content.text = repo.fullName
      content.secondaryText =
        "★ \(repo.stargazersCount.formatted()) · \(repo.language ?? "—")"
      cell.contentConfiguration = content
    }
    return UICollectionViewDiffableDataSource<Int, Repository>(
      collectionView: collectionView
    ) { collectionView, indexPath, repo in
      collectionView.dequeueConfiguredReusableCell(
        using: registration, for: indexPath, item: repo)
    }
  }()

  init() {
    let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
    let layout = UICollectionViewCompositionalLayout.list(using: configuration)
    super.init(collectionViewLayout: layout)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "UIKit — Popular Repositories"
    collectionView.dataSource = dataSource
    collectionView.pagination.delegate = self
    collectionView.pagination.direction = .vertical
  }
}

// MARK: - PaginationDelegate

extension RepositoriesViewController: @preconcurrency PaginationDelegate {
  func pagination(_ pagination: Pagination, prefetchNextPageWith context: PaginationContext) {
    context.update(state: .started)
    Task { @MainActor in
      do {
        let nextPage = currentPage + 1
        let response = try await service.fetchPopularRepositories(page: nextPage)
        var snapshot = dataSource.snapshot()
        if snapshot.sectionIdentifiers.isEmpty {
          snapshot.appendSections([0])
        }
        snapshot.appendItems(response.items, toSection: 0)
        await dataSource.apply(snapshot, animatingDifferences: true)
        currentPage = nextPage
        hasMorePages = snapshot.numberOfItems < response.totalCount
        pagination.isEnabled = hasMorePages
        context.update(state: .completed)
      } catch {
        context.update(state: .failed)
      }
    }
  }
}

// MARK: - Preview

#Preview("UIKit — Popular Repositories") {
  RepositoriesViewController()
}
#endif
