import ObjectiveC
import UIKit

/// A key used for associating the `Pagination` instance with a `UIScrollView` object.
private var paginationKey: UInt8 = 0
/// Extension to add pagination functionality to any UIScrollView or its subclasses.
///
/// This extension allows `UIScrollView`, including subclasses like `UITableView` and `UICollectionView`, to seamlessly integrate with the `Pagination` class, enabling automatic detection and handling of paginated content loading.
///
/// By accessing the `pagination` property, developers can easily configure and manage pagination settings, such as setting the delegate to handle pagination events, defining the number of leading screens for prefetching, and more.
///
/// This extension simplifies the implementation of infinite scrolling and other pagination patterns by automatically associating a `Pagination` instance with any `UIScrollView` or its subclasses.
extension UIScrollView {
  /// The `Pagination` instance associated with the scrollable view.
  ///
  /// This property provides a convenient way to manage pagination for any `UIScrollView` (or its subclasses like `UITableView` or `UICollectionView`).
  ///
  /// - Note: The `Pagination` instance monitors the scroll view’s content offset to determine when to request additional data.
  /// This is particularly useful when implementing infinite scrolling or batch data loading in large lists.
  ///
  /// # Usage Example:
  /// ```swift
  /// import UIKit
  /// import Pagination
  ///
  /// class FeedViewController: UICollectionViewController {
  ///     private var currentPage = 0
  ///     private let feedProvider: FeedProvider
  ///
  ///     override func viewDidLoad() {
  ///         super.viewDidLoad()
  ///
  ///         collectionView.pagination.isEnabled = true
  ///         collectionView.pagination.direction = .vertical
  ///         collectionView.pagination.delegate = self
  ///     }
  /// }
  ///
  /// // MARK: - PaginationDelegate
  ///
  /// extension FeedViewController: PaginationDelegate {
  ///
  ///     func pagination(_ pagination: Pagination, prefetchNextPageWith context: PaginationContext) {
  ///         let nextPage = currentPage + 1
  ///         feedProvider.provideFeed(page: nextPage, pageSize: 20) { [weak self] result in
  ///             switch result {
  ///             case .success(let newFeed):
  ///                 self?.currentPage = nextPage
  ///                 pagination.isPagingEnabled = nextPage < newFeed.totalPages
  ///                 self?.reload(using: newFeed)
  ///                 context.finish(true)
  ///             case .failure:
  ///                 context.finish(false)
  ///             }
  ///         }
  ///     }
  /// }
  /// ```
  /// > Warning: It is mandatory to call `context.finish(_:)` with either `true` or `false` once the data loading is complete, to accurately reflect the pagination state.
  @objc public var pagination: Pagination {
    get {
      if let pagination = objc_getAssociatedObject(self, &paginationKey) as? Pagination {
        return pagination
      } else {
        let pagination = Pagination()
        pagination.scrollView = self
        objc_setAssociatedObject(
          self, &paginationKey, pagination, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return pagination
      }
    }
    set {
      newValue.scrollView = self
      objc_setAssociatedObject(self, &paginationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}
