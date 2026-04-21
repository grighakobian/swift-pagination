#if canImport(AppKit)
import AppKit
import Combine
import Pagination

/// An `NSViewController` demonstrating pagination using an `NSCollectionView` with a
/// compositional list layout.
final class RepositoriesViewController: NSViewController {
  private static let itemIdentifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("RepoItem")

  private let viewModel = RepositoriesViewModel()
  private var cancellables = Set<AnyCancellable>()
  private let scrollView: NSScrollView
  private let collectionView: NSCollectionView
  private let dataSource: NSCollectionViewDiffableDataSource<Int, RepositoryViewModel>

  init() {
    let collectionView = NSCollectionView()
    collectionView.collectionViewLayout = Self.makeLayout()
    collectionView.isSelectable = true
    collectionView.backgroundColors = [.clear]
    collectionView.register(RepositoryItem.self, forItemWithIdentifier: Self.itemIdentifier)
    self.collectionView = collectionView

    let scrollView = NSScrollView()
    scrollView.documentView = collectionView
    scrollView.hasVerticalScroller = true
    scrollView.drawsBackground = false
    self.scrollView = scrollView

    self.dataSource = NSCollectionViewDiffableDataSource<Int, RepositoryViewModel>(
      collectionView: collectionView
    ) { collectionView, indexPath, item in
      let cell = collectionView.makeItem(
        withIdentifier: Self.itemIdentifier, for: indexPath) as! RepositoryItem
      cell.configure(with: item)
      return cell
    }

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    let container = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(scrollView)
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: container.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])
    view = container
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    scrollView.pagination.delegate = self
    scrollView.pagination.direction = .vertical

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
        self?.scrollView.pagination.isEnabled = hasMorePages
      }
      .store(in: &cancellables)
  }

  private static func makeLayout() -> NSCollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(52))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(52))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    section.interGroupSpacing = 4

    return NSCollectionViewCompositionalLayout(section: section)
  }
}

// MARK: - RepositoryItem

final class RepositoryItem: NSCollectionViewItem {
  private let titleLabel = NSTextField(labelWithString: "")
  private let subtitleLabel = NSTextField(labelWithString: "")

  override func loadView() {
    view = NSView()

    titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(titleLabel)

    subtitleLabel.font = .systemFont(ofSize: 11)
    subtitleLabel.textColor = .secondaryLabelColor
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(subtitleLabel)

    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),

      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
      subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
      subtitleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
    ])
  }

  func configure(with item: RepositoryViewModel) {
    titleLabel.stringValue = item.title
    subtitleLabel.stringValue = item.subtitle
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
