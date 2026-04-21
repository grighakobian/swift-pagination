#if canImport(UIKit) && !os(watchOS)
import Combine
import Pagination
import UIKit

/// A `UICollectionViewController` demonstrating pagination using a compositional list layout.
final class RepositoriesViewController: UICollectionViewController {
  private let viewModel = RepositoriesViewModel()
  private var cancellables = Set<AnyCancellable>()

  private lazy var dataSource: UICollectionViewDiffableDataSource<Int, RepositoryViewModel> = {
    let registration = UICollectionView.CellRegistration<UICollectionViewListCell, RepositoryViewModel> {
      cell, _, item in
      var content = cell.defaultContentConfiguration()
      content.text = item.title
      content.secondaryText = item.subtitle
      cell.contentConfiguration = content
    }
    return UICollectionViewDiffableDataSource<Int, RepositoryViewModel>(
      collectionView: collectionView
    ) { collectionView, indexPath, item in
      collectionView.dequeueConfiguredReusableCell(
        using: registration, for: indexPath, item: item)
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

    title = "Popular Repositories"
    collectionView.dataSource = dataSource
    collectionView.pagination.delegate = self
    collectionView.pagination.direction = .vertical

    viewModel.$repositories
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] items in
        guard let self else { return }
        var snapshot = NSDiffableDataSourceSnapshot<Int, RepositoryViewModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
      }
      .store(in: &cancellables)

    viewModel.$hasMorePages
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] hasMorePages in
        self?.collectionView.pagination.isEnabled = hasMorePages
      }
      .store(in: &cancellables)
  }
}

// MARK: - PaginationDelegate

extension RepositoriesViewController: @preconcurrency PaginationDelegate {
  func pagination(_ pagination: Pagination, prefetchNextPageWith context: PaginationContext) {
    context.update(state: .started)
    Task { @MainActor in
      do {
        try await viewModel.fetchNextPage()
        context.update(state: .completed)
      } catch {
        context.update(state: .failed)
      }
    }
  }
}
#endif
