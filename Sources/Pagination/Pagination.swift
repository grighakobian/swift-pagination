import Foundation
import UIKit

/// A protocol that defines methods for handling pagination.
@objc public protocol PaginationDelegate: AnyObject {
  /// Called when the pagination has requested the next page of data.
  /// - Parameters:
  ///   - pagination: The pagination instance that requested the next page.
  ///   - context: The pagination context containing the current state.
  @objc(pagination:prefetchNextPageWithContext:)
  func pagination(_ pagination: Pagination, prefetchNextPageWith context: PaginationContext)
}

/// A class that manages pagination for a `UIScrollView` by detecting when to request additional pages of data.
///
/// The `Pagination` monitors the scroll view’s content offset and determines when to trigger pagination based on the scroll direction and proximity to the end of the content. It supports vertical and horizontal scrolling and allows you to configure the threshold for triggering new fetches.
///
/// **Example Usage:**
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
///
/// This class provides methods to monitor scroll view events and manage pagination state efficiently.
@objcMembers open class Pagination: NSObject {
  /// The scroll view associated with the paginator.
  ///
  /// This scroll view is monitored for scroll events to trigger pagination.
  ///
  /// Defaults to `nil`.
  weak var scrollView: UIScrollView? {
    didSet { togglePrefetchingEnabled() }
  }

  /// A Boolean value that determines whether the pagination is enabled.
  ///
  /// Defaults to `true`.
  public var isEnabled: Bool {
    didSet { togglePrefetchingEnabled() }
  }

  /// The delegate to notify about pagination events.
  public weak var delegate: PaginationDelegate? {
    didSet { togglePrefetchingEnabled() }
  }

  /// The context managing the current state of pagination.
  ///
  /// This property tracks the state of pagination, including in-flight fetches and their status.
  public private(set) var context: PaginationContext

  /// The supported pagination direction for triggering pagination.
  ///
  /// This property defines whether pagination should occur based on vertical or horizontal scrolling.
  ///
  /// Defaults to `.vertical`. Can be set to `.horizontal` or `.vertical` based on the desired scroll direction.
  public var direction: PaginationDirection

  /// The number of screens of distance from the end of content that will trigger a prefetch.
  ///
  /// This property defines how soon before reaching the end of content a new fetch should be triggered.
  ///
  /// Defaults to `2.0`. Increase this value to trigger fetches earlier or decrease to trigger them later.
  public var leadingScreensForPrefetching: CGFloat

  /// The observation token used to observe changes in the scroll view’s content offset.
  private(set) var observation: NSKeyValueObservation?

  /// Initializes a new instance of `Pagination` with default settings.
  public override init() {
    self.isEnabled = true
    self.direction = .vertical
    self.context = PaginationContext()
    self.leadingScreensForPrefetching = 2.0
    super.init()
  }

  /// Manages the observation of the scroll view’s content offset to trigger pagination.
  func togglePrefetchingEnabled() {
    guard isEnabled, let scrollView, let delegate else {
      observation = nil
      return
    }
    observation = scrollView.observe(
      \.contentOffset,
      options: [.old, .new]
    ) { [unowned self] scrollView, change in
      prefetchIfNeeded(
        scrollView: scrollView,
        delegate: delegate,
        change: change)
    }
  }

  /// Evaluates whether the next page of data should be prefetched based on the scroll view's current state and direction of scrolling.
  /// - Parameters:
  ///   - scrollView: The `UIScrollView` that is being observed for content offset changes.
  ///   - change: The `NSKeyValueObservedChange<CGPoint>` that represents the old and new content offset of the `scrollView`.
  func prefetchIfNeeded(
    scrollView: UIScrollView,
    delegate: PaginationDelegate,
    change: NSKeyValueObservedChange<CGPoint>
  ) {
    // If the scroll view is not visible, don't prefetch.
    // Determine the scroll direction based on the change in content offset.
    let scrollDirection = detectScrollDirection(
      oldOffset: change.oldValue!,
      newOffset: change.newValue!
    )
    let isScrollViewVisible = scrollView.window != nil
    let scrollViewBounds = scrollView.bounds
    let scrollViewContentSize = scrollView.contentSize
    // Determine if the layout direction is right-to-left.
    let shouldRenderRTLLayout =
      UIView.userInterfaceLayoutDirection(for: scrollView.semanticContentAttribute) == .rightToLeft
    // Check if the scroll view flips horizontally in opposite layout directions (only applicable to UICollectionView).
    let flipsHorizontallyInOppositeLayoutDirection: Bool = {
      if let collectionView = scrollView as? UICollectionView {
        return collectionView.collectionViewLayout.flipsHorizontallyInOppositeLayoutDirection
      }
      return false
    }()
    // If a new page should be requested, notify the delegate to prefetch.
    if shouldPrefetchNextPage(
      context: context,
      scrollDirection: scrollDirection,
      scrollableDirections: direction,
      isScrollViewVisible: isScrollViewVisible,
      scrollViewBounds: scrollViewBounds,
      scrollViewContentSize: scrollViewContentSize,
      scrollViewContentOffset: scrollView.contentOffset,
      leadingScreens: leadingScreensForPrefetching,
      shouldRenderRTLLayout: shouldRenderRTLLayout,
      flipsHorizontallyInOppositeLayoutDirection: flipsHorizontallyInOppositeLayoutDirection)
    {
      context.start()
      delegate.pagination(self, prefetchNextPageWith: context)
    }
  }

  /// Detects the direction of the scroll based on the change in content offset.
  ///
  /// This method compares the old and new content offsets to determine which direction
  /// the user is scrolling. The returned `ScrollDirection` indicates whether the scroll
  /// is moving left, right, up, or down. Multiple directions can be returned if the scroll
  /// occurs diagonally.
  ///
  /// - Parameters:
  ///   - oldOffset: The content offset before the scroll action occurred.
  ///   - newOffset: The content offset after the scroll action occurred.
  /// - Returns: A `ScrollDirection` indicating the direction of the scroll. This could be
  ///            `.left`, `.right`, `.up`, `.down`, or a combination of these if scrolling
  ///            occurs diagonally.
  func detectScrollDirection(
    oldOffset: CGPoint,
    newOffset: CGPoint
  ) -> ScrollDirection {
    var direction: ScrollDirection = []
    if oldOffset.x != newOffset.x {
      if oldOffset.x < newOffset.x {
        direction.insert(.right)
      } else {
        direction.insert(.left)
      }
    }
    if oldOffset.y != newOffset.y {
      if oldOffset.y < newOffset.y {
        direction.insert(.down)
      } else {
        direction.insert(.up)
      }
    }
    return direction
  }

  /// Determines whether the next page of data should be prefetched based on the scroll view’s current state and scrolling direction.
  /// - Parameters:
  ///   - context: The context managing the current state of pagination.
  ///   - scrollDirection: The direction in which the user is scrolling.
  ///   - direction: The overall direction of pagination (e.g., vertical or horizontal).
  ///   - isScrollViewVisible: A Boolean value indicating whether the scroll view is currently visible on the screen.
  ///   - scrollViewBounds: The bounds of the `UIScrollView`.
  ///   - scrollViewContentSize: The total size of the content in the `UIScrollView`.
  ///   - scrollViewContentOffset: The current content offset of the `UIScrollView`.
  ///   - leadingScreens: The number of screens' worth of content that should be visible before prefetching the next page.
  ///   - shouldRenderRTLLayout: A Boolean value indicating whether the layout direction is right-to-left.
  ///   - flipsHorizontallyInOppositeLayoutDirection: A Boolean value indicating whether the scroll view flips horizontally in opposite layout directions (applicable to `UICollectionView`).
  ///
  /// - Returns: A Boolean value indicating whether the next page should be prefetched.
  func shouldPrefetchNextPage(
    context: PaginationContext,
    scrollDirection: ScrollDirection,
    scrollableDirections: PaginationDirection,
    isScrollViewVisible: Bool,
    scrollViewBounds: CGRect,
    scrollViewContentSize: CGSize,
    scrollViewContentOffset: CGPoint,
    leadingScreens: CGFloat,
    shouldRenderRTLLayout: Bool,
    flipsHorizontallyInOppositeLayoutDirection: Bool
  ) -> Bool {
    // Do not allow fetching if a batch is already in-flight and hasn't been completed or cancelled.
    if context.isFetching {
      return false
    }
    // No prefetching if leadingScreens is less than or equal to 0 or if bounds are empty.
    if leadingScreens <= 0.0 || scrollViewBounds.isEmpty {
      return false
    }
    let offset: CGFloat
    let viewLength: CGFloat
    let contentLength: CGFloat
    if scrollableDirections == .vertical {
      offset = scrollViewContentOffset.y
      viewLength = scrollViewBounds.size.height
      contentLength = scrollViewContentSize.height
    } else {
      offset = scrollViewContentOffset.x
      viewLength = scrollViewBounds.size.width
      contentLength = scrollViewContentSize.width
    }
    // If content length is smaller than the view length, always request a new page.
    let hasSmallContent = contentLength < viewLength
    if hasSmallContent {
      return true
    }
    // If we are not visible, but we do have enough content to fill visible area,
    // don't batch fetch.
    guard isScrollViewVisible else {
      return false
    }
    // If they are scrolling toward the head of content, don't batch fetch.
    let isScrollingTowardHead: Bool = {
      if scrollDirection.contains(.up) {
        return true
      }
      if shouldRenderRTLLayout {
        return scrollDirection.contains(.right)
      } else {
        return scrollDirection.contains(.left)
      }
    }()
    if isScrollingTowardHead {
      return false
    }
    // Calculate remaining and trigger distance
    let triggerDistance = viewLength * leadingScreens
    let remainingDistance: CGFloat = {
      // If the scroll view flips horizontally in the opposite layout direction and RTL layout is enabled, calculate remaining distance accordingly.
      if !flipsHorizontallyInOppositeLayoutDirection
        && shouldRenderRTLLayout
        && scrollableDirections.contains(.horizontal)
      {
        return offset
      } else {
        return contentLength - viewLength - offset
      }
    }()
    return remainingDistance <= triggerDistance
  }
}
