import AppKit
import Pagination

final class ColorsViewController: NSViewController {
  private var currentPage = 0
  private let totalPages = 5
  private var scrollView: NSScrollView!
  private var collectionView: NSCollectionView!
  private var dataSource: NSCollectionViewDiffableDataSource<Int, ColorItem>!

  override func loadView() {
    view = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 500))
 
    let layout = NSCollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.itemSize = NSSize(width: 200, height: 280)
    layout.minimumInteritemSpacing = 12
    layout.minimumLineSpacing = 12
    layout.sectionInset = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    collectionView = NSCollectionView()
    collectionView.collectionViewLayout = layout
    collectionView.register(
      ColorCollectionViewItem.self,
      forItemWithIdentifier: ColorCollectionViewItem.identifier)

    dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
      let viewItem = collectionView.makeItem(
        withIdentifier: ColorCollectionViewItem.identifier,
        for: indexPath) as! ColorCollectionViewItem
      viewItem.configure(with: item)
      return viewItem
    }

    scrollView = NSScrollView()
    scrollView.documentView = collectionView
    scrollView.hasHorizontalScroller = true
    scrollView.hasVerticalScroller = false
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    scrollView.pagination.delegate = self
    scrollView.pagination.direction = .horizontal
  }
}

// MARK: - PaginationDelegate

extension ColorsViewController: @preconcurrency PaginationDelegate {
  func pagination(_ pagination: Pagination, prefetchNextPageWith context: PaginationContext) {
    let nextPage = currentPage + 1

    // Simulate network delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self else {
        context.finish(false)
        return
      }

      let newItems = ColorPalette.page(nextPage)
      var snapshot = dataSource.snapshot()
      if snapshot.sectionIdentifiers.isEmpty {
        snapshot.appendSections([0])
      }
      snapshot.appendItems(newItems, toSection: 0)
      dataSource.apply(snapshot, animatingDifferences: true)

      currentPage = nextPage
      pagination.isEnabled = nextPage < totalPages
      context.finish(true)
    }
  }
}

// MARK: - NSCollectionViewItem

final class ColorCollectionViewItem: NSCollectionViewItem {
  static let identifier = NSUserInterfaceItemIdentifier("ColorCollectionViewItem")

  private let colorItemView = ColorItemView()

  override func loadView() {
    view = colorItemView
  }

  func configure(with item: ColorItem) {
    colorItemView.configure(with: item)
  }
}
