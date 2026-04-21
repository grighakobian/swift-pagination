#if canImport(UIKit)
  import UIKit
  public typealias PlatformScrollView = UIScrollView
#elseif canImport(AppKit)
  import AppKit
  public typealias PlatformScrollView = NSScrollView
#endif

/// A protocol that defines methods for handling pagination.
@objc public protocol PaginationDelegate: AnyObject, Sendable {
  /// Called when the pagination has requested the next page of data.
  /// - Parameters:
  ///   - pagination: The pagination instance that requested the next page.
  ///   - context: The pagination context containing the current state.
  @objc(pagination:prefetchNextPageWithContext:)
  func pagination(_ pagination: Pagination, prefetchNextPageWith context: PaginationContext)
}

/// A class that manages pagination for a scroll view by detecting when to request additional pages of data.
///
/// The `Pagination` monitors the scroll view's content offset and determines when to trigger pagination based on the scroll direction and proximity to the end of the content. It supports vertical and horizontal scrolling and allows you to configure the threshold for triggering new fetches.
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
///     // .. init
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
///         context.start()
///         let nextPage = currentPage + 1
///         feedProvider.provideFeed(page: nextPage, pageSize: 20) { [weak self] result in
///             switch result {
///             case .success(let newFeed):
///                 self?.currentPage = nextPage
///                 pagination.isEnabled = nextPage < newFeed.totalPages
///                 self?.reload(using: newFeed)
///                 context.finish(true)
///             case .failure:
///                 context.finish(false)
///             }
///         }
///     }
/// }
/// ```
/// > Warning: It is mandatory to call `context.start()` when beginning a fetch and `context.finish(_:)` with either `true` or `false` once the data loading is complete, to accurately reflect the pagination state.
///
/// This class provides methods to monitor scroll view events and manage pagination state efficiently.
@MainActor
@objcMembers public final class Pagination: NSObject {
  /// The scroll view associated with the paginator.
  ///
  /// This scroll view is monitored for scroll events to trigger pagination.
  ///
  /// Defaults to `nil`.
  weak var scrollView: PlatformScrollView? {
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

  /// The observation token used to observe changes in the scroll view's content offset.
  #if canImport(UIKit)
    private(set) var observation: NSKeyValueObservation?
  #elseif canImport(AppKit)
    private(set) var observation: (any NSObjectProtocol)?
  #endif

  /// Initializes a new instance of `Pagination` with default settings.
  public override init() {
    self.isEnabled = true
    self.direction = .vertical
    self.context = PaginationContext()
    self.leadingScreensForPrefetching = 2.0
    super.init()
  }

  /// Manages the observation of the scroll view's content offset to trigger pagination.
  func togglePrefetchingEnabled() {
    guard isEnabled, let scrollView, delegate != nil else {
      #if canImport(AppKit)
        if let observation {
          NotificationCenter.default.removeObserver(observation)
        }
      #endif
      observation = nil
      return
    }
    if observation != nil { return }

    #if canImport(UIKit)
      observation = scrollView.observe(
        \.contentOffset,
        options: [.old, .new]
      ) { [weak self] scrollView, change in
        guard let self else { return }
        MainActor.assumeIsolated {
          guard let delegate = self.delegate,
            let oldOffset = change.oldValue,
            let newOffset = change.newValue
          else { return }
          self.prefetchIfNeeded(
            scrollView: scrollView,
            delegate: delegate,
            oldOffset: oldOffset,
            newOffset: newOffset)
        }
      }
    #elseif canImport(AppKit)
      scrollView.contentView.postsBoundsChangedNotifications = true
      var lastOffset = scrollView.contentView.bounds.origin
      observation = NotificationCenter.default.addObserver(
        forName: NSView.boundsDidChangeNotification,
        object: scrollView.contentView,
        queue: .main
      ) { [weak self] _ in
        guard let self else { return }
        MainActor.assumeIsolated {
          guard let delegate = self.delegate,
            let scrollView = self.scrollView
          else { return }
          let newOffset = scrollView.contentView.bounds.origin
          self.prefetchIfNeeded(
            scrollView: scrollView,
            delegate: delegate,
            oldOffset: lastOffset,
            newOffset: newOffset)
          lastOffset = newOffset
        }
      }
    #endif

    #if canImport(AppKit)
      // Trigger an initial prefetch check for empty or small content.
      // Deferred to the next run loop cycle so the view has been laid out.
      // Only needed on macOS — on iOS, KVO on `contentOffset` fires naturally
      // during the first layout pass, which covers the initial check.
      DispatchQueue.main.async { [weak self] in
        guard let self,
          let scrollView = self.scrollView,
          let delegate = self.delegate
        else { return }
        let offset = scrollView.contentView.bounds.origin
        self.prefetchIfNeeded(
          scrollView: scrollView,
          delegate: delegate,
          oldOffset: offset,
          newOffset: offset)
      }
    #endif
  }

  /// Evaluates whether the next page of data should be prefetched based on the scroll view's current state and direction of scrolling.
  func prefetchIfNeeded(
    scrollView: PlatformScrollView,
    delegate: PaginationDelegate,
    oldOffset: CGPoint,
    newOffset: CGPoint
  ) {
    let scrollDirection = detectScrollDirection(
      oldOffset: oldOffset,
      newOffset: newOffset)
    let isScrollViewVisible = scrollView.window != nil

    #if canImport(UIKit)
      let scrollViewBounds = scrollView.bounds
      let scrollViewContentSize = scrollView.contentSize
      let scrollViewContentOffset = scrollView.contentOffset
      let shouldRenderRTLLayout =
        UIView.userInterfaceLayoutDirection(for: scrollView.semanticContentAttribute)
        == .rightToLeft
      let flipsHorizontallyInOppositeLayoutDirection: Bool = {
        if let collectionView = scrollView as? UICollectionView {
          return collectionView.collectionViewLayout.flipsHorizontallyInOppositeLayoutDirection
        }
        return false
      }()
    #elseif canImport(AppKit)
      let scrollViewBounds = scrollView.contentView.bounds
      let scrollViewContentSize = scrollView.documentView?.frame.size ?? .zero
      let scrollViewContentOffset = scrollView.contentView.bounds.origin
      let shouldRenderRTLLayout = NSApp?.userInterfaceLayoutDirection == .rightToLeft
      let flipsHorizontallyInOppositeLayoutDirection = false
    #endif

    if shouldPrefetchNextPage(
      context: context,
      scrollDirection: scrollDirection,
      scrollableDirections: direction,
      isScrollViewVisible: isScrollViewVisible,
      scrollViewBounds: scrollViewBounds,
      scrollViewContentSize: scrollViewContentSize,
      scrollViewContentOffset: scrollViewContentOffset,
      leadingScreens: leadingScreensForPrefetching,
      shouldRenderRTLLayout: shouldRenderRTLLayout,
      flipsHorizontallyInOppositeLayoutDirection: flipsHorizontallyInOppositeLayoutDirection)
    {
      delegate.pagination(self, prefetchNextPageWith: context)
    }
  }
}

// MARK: - Helpers

/// Determines whether the next page of data should be prefetched based on the
/// scroll view's current state and scrolling direction.
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
  if context.isStarted {
    return false
  }
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
  let hasSmallContent = contentLength < viewLength
  if hasSmallContent {
    return true
  }
  guard isScrollViewVisible else {
    return false
  }
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
  let triggerDistance = viewLength * leadingScreens
  let remainingDistance: CGFloat = {
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

/// Detects the direction of the scroll based on the change in content offset.
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
