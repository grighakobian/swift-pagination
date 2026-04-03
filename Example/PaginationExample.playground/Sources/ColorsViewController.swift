import Pagination
import UIKit

/// A view controller that displays a paginated grid of random colors.
public final class ColorsViewController: UICollectionViewController {
  private var currentPage = 0
  private let colorService: any ColorService
  private var dataSource: UICollectionViewDiffableDataSource<Int, Color>!

  public init(colorService: some ColorService = ColorServiceImpl()) {
    self.colorService = colorService

    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(0.5),
      heightDimension: .fractionalWidth(0.6))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalWidth(0.6))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

    super.init(collectionViewLayout: UICollectionViewCompositionalLayout(section: section))

    collectionView.backgroundColor = .systemBackground
    collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)

    dataSource = .init(collectionView: collectionView) { collectionView, indexPath, color in
      let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: ColorCell.reuseIdentifier,
        for: indexPath) as! ColorCell
      cell.configure(with: color)
      return cell
    }

    collectionView.dataSource = dataSource
    collectionView.pagination.delegate = self
    collectionView.pagination.direction = .vertical
    collectionView.pagination.leadingScreensForPrefetching = 1.5
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - PaginationDelegate

extension ColorsViewController: PaginationDelegate {
  public func pagination(
    _ pagination: Pagination,
    prefetchNextPageWith context: PaginationContext
  ) {
    Task {
      do {
        let response = try await colorService.fetchColors(page: currentPage + 1)

        var snapshot = dataSource.snapshot()
        if snapshot.sectionIdentifiers.isEmpty {
          snapshot.appendSections([0])
        }
        snapshot.appendItems(response.colors, toSection: 0)
        await dataSource.apply(snapshot)

        currentPage = response.page
        pagination.isEnabled = response.page < response.totalPages
        context.finish(true)
      } catch {
        context.finish(false)
      }
    }
  }
}
