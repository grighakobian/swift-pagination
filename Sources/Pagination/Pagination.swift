import Foundation
import UIKit

/// A protocol that defines methods for handling pagination.
@objc public protocol PaginationDelegate: AnyObject {
    /// Called when the pagination has requested the next page of data.
    /// - Parameters:
    ///   - pagination: The pagination instance that requested the next page.
    ///   - context: The pagination context containing the current state.
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
///     private let pagination = Pagination()
///     private var currentPage = 0
///     private var isPagingEnabled = true
///
///     override func viewDidLoad() {
///         super.viewDidLoad()
///
///         pagination.delegate = self
///         pagination.attach(to: collectionView)
///     }
/// }
///
/// // MARK: - PaginatorDelegate
///
/// extension FeedViewController: PaginatorDelegate {
///
///     func pagination(_ pagination: Pagination, shouldRequestNextPageWith context: PaginationContext) -> Bool {
///         return isPagingEnabled
///     }
///
///     func pagination(_ pagination: Pagination, didRequestNextPageWith context: PaginationContext) {
///         context.start()
///         let nextPage = currentPage + 1
///         feedProvider.provideFeed(page: nextPage, pageSize: 20) { [weak self] result in
///             switch result {
///             case .success(let newFeed):
///                 self?.currentPage = nextPage
///                 self?.isPagingEnabled = nextPage < newFeed.totalPages
///                 self?.reload(using: newFeed)
///                 context.finish(true)
///             case .failure(let error):
///                 context.finish(false)
///             }
///         }
///     }
/// }
/// ```
/// > Warning: It is mandatory to call `context.start()` when pagination begins and `context.finish(_:)` with either `true` or `false` once the data loading is complete, to accurately reflect the pagination state.
///
/// This class provides methods to attach and detach from a scroll view and manage pagination state efficiently.
@objcMembers
open class Pagination: NSObject {
    
    /// The scroll view associated with the paginator.
    ///
    /// This scroll view is monitored for scroll events to trigger pagination. It should be set using the `attach(to:)` method.
    ///
    /// Defaults to `nil`.
    public private(set) weak var scrollView: UIScrollView?

    /// A Boolean value that determines whether the pagination is enabled.
    ///
    ////// Defaults to `true`.
    public var isEnabled: Bool

    /// The scrollable directions supported by the paginator for triggering pagination.
    ///
    /// This property defines whether pagination should occur based on vertical or horizontal scrolling.
    ///
    /// Defaults to `.vertical`. Can be set to `.horizontal` or `.vertical` based on the desired scroll direction.
    public var scrollableDirections: ScrollDirection

    /// The delegate to notify about pagination events.
    ///
    /// Assign a delegate to receive callbacks about pagination requests and related events.
    ///
    /// Defaults to `nil`. Set this property to handle pagination events through the `PaginationDelegate`.
    public weak var delegate: PaginationDelegate?

    /// The context managing the current state of pagination.
    ///
    /// This property tracks the state of pagination, including in-flight fetches and their status.
    ///
    /// Defaults to a new instance of `PaginationContext`. This context helps in determining whether pagination is ongoing or completed.
    public private(set) var context: PaginationContext

    /// The number of screens of distance from the end of content that will trigger a batch fetch.
    ///
    /// This property defines how soon before reaching the end of content a new fetch should be triggered.
    ///
    /// Defaults to `2.0`. Increase this value to trigger fetches earlier or decrease to trigger them later.
    public var leadingScreensForBatching: CGFloat

    /// The observation token used to observe changes in the scroll view’s content offset.
    ///
    /// This internal property is used for managing the KVO (Key-Value Observing) on the scroll view's content offset.
    ///
    /// Defaults to `nil`. It is automatically managed and should not be modified directly.
    private(set) var observationToken: NSKeyValueObservation?

    /// Initializes a new instance of `Pagination` with specified scroll directions and batching settings.
    ///
    /// - Parameters:
    ///   - scrollableDirections: The scroll directions in which pagination should be enabled.
    ///   - leadingScreensForBatching: The number of screens to keep ahead for triggering batch fetching.
    public init(scrollableDirections: ScrollDirection, leadingScreensForBatching: CGFloat) {
        self.isEnabled = true
        self.context = PaginationContext()
        self.scrollableDirections = scrollableDirections
        self.leadingScreensForBatching = leadingScreensForBatching
        super.init()
    }

    /// Initializes a new instance of `Pagination` with default settings.
    ///
    /// This initializer sets up the `Pagination` with a vertical scroll direction and a default batching setting of 2 screens.
    public override init() {
        self.isEnabled = true
        self.context = PaginationContext()
        self.scrollableDirections = .vertical
        self.leadingScreensForBatching = 2.0
        super.init()
    }

    deinit {
        observationToken?.invalidate()
    }
    
    /// Attaches the `Pagination` to a new `UIScrollView` and starts observing its content offset.
    ///
    /// This method sets up the `Pagination` to observe the specified `UIScrollView` for changes in content offset,
    /// enabling pagination functionality for the new scroll view. It invalidates any existing observation token
    /// to stop observing the previous scroll view and then begins observing the new scroll view.
    ///
    /// - Parameter scrollView: The `UIScrollView` to which the `Pagination` will be attached. This scroll view
    ///   will be observed for changes in its content offset to trigger pagination.
    ///
    /// This method is useful when you need to switch the `Pagination` to a different `UIScrollView`
    /// or when the initial scroll view is dynamically changed.
    public func attach(to scrollView: UIScrollView) {
        // Invalidate the existing observation token to stop observing changes on the previous scroll view.
        self.observationToken?.invalidate()
        // Clear the existing observation token reference.
        self.observationToken = nil
        // Set the new scroll view to observe.
        self.scrollView = scrollView
        // Start observing the content offset of the new scroll view.
        self.observeValues(for: scrollView)
    }
    
    /// Detaches the `Pagination` from its associated `UIScrollView` and cleans up resources.
    ///
    /// This method invalidates the observation token to stop observing scroll view changes,
    /// sets the `scrollView` and `delegate` properties to `nil`, and performs necessary cleanup.
    ///
    /// The `detach` method is useful when you want to stop pagination and release resources
    /// associated with the `Pagination`. It is recommended to call this method when the
    /// `Pagination` is no longer needed or when the associated `UIScrollView` is being deallocated.
    public func detach() {
        // Invalidate the observation token to stop observing scroll view changes.
        self.observationToken?.invalidate()
        // Set the observation token to nil to release any held resources.
        self.observationToken = nil
        // Set the scroll view to nil to break the reference to the associated scroll view.
        self.scrollView = nil
        // Set the delegate to nil to remove the reference to the delegate.
        self.delegate = nil
    }

    /// Starts observing the content offset changes of the provided `UIScrollView`.
    ///
    /// This method sets up Key-Value Observing (KVO) on the `contentOffset` property of the given `scrollView`.
    /// It allows the `Pagination` to monitor scrolling and trigger pagination when needed based on the scroll view's content offset.
    ///
    /// - Parameter scrollView: The `UIScrollView` instance whose content offset changes will be observed.
    ///   The method invalidates any existing observation token before setting up a new observer.
    ///
    /// The observation will monitor changes to the `contentOffset` of the `scrollView` and call the
    /// `requestNextPageIfNeeded(for:with:)` method to determine if a new page should be fetched based on the scroll position.
    func observeValues(for scrollView: UIScrollView) {
        let keyPath: KeyPath = \UIScrollView.contentOffset
        let options: NSKeyValueObservingOptions = [.old, .new]
        observationToken = scrollView.observe(keyPath, options: options) { [unowned self] scrollView, change in
            requestNextPageIfNeeded(for: scrollView, with: change)
        }
    }
    
    /// Determines if a new page should be requested based on the changes in the scroll view's content offset.
    ///
    /// This method evaluates whether a new page should be fetched based on the difference in content offset between
    /// the previous and current values. It uses the scroll direction and other parameters to decide if the batch
    /// fetching should be triggered. If the conditions for fetching are met, it notifies the delegate to perform the fetch.
    ///
    /// - Parameter scrollView: The `UIScrollView` instance whose content offset changes are being observed.
    /// - Parameter change: An `NSKeyValueObservedChange<CGPoint>` object containing the old and new values of the `contentOffset`.
    func requestNextPageIfNeeded(for scrollView: UIScrollView, with change: NSKeyValueObservedChange<CGPoint>) {
        // Check if delegate is set.
        guard let delegate else { return }
        // Check if prefetching enabled.
        guard isEnabled else { return }
        // Retrieve the old and new content offsets from the change dictionary.
        let newContentOffset = change.newValue!
        // Determine the scroll direction based on the change in content offset.
        let scrollDirection: ScrollDirection = {
            let oldContentOffset = change.oldValue!
            let scrollDirection = ScrollDirection()
            if oldContentOffset.x != newContentOffset.x {
                if oldContentOffset.x < newContentOffset.x {
                    scrollDirection.insert(.right)
                } else {
                    scrollDirection.insert(.left)
                }
            }
            if oldContentOffset.y != newContentOffset.y {
                if oldContentOffset.y < newContentOffset.y {
                    scrollDirection.insert(.down)
                } else {
                    scrollDirection.insert(.up)
                }
            }
            return scrollDirection
        }()
        
        // Check if the scroll view flips horizontally in opposite layout directions (only applicable to UICollectionView).
        let flipsHorizontallyInOppositeLayoutDirection: Bool = {
            if let collectionView = scrollView as? UICollectionView {
                return collectionView.collectionViewLayout.flipsHorizontallyInOppositeLayoutDirection
            }
            return false
        }()
        // Check if the scroll view is visible in the window.
        let isVisible = scrollView.window != nil
        // Determine if the layout direction is right-to-left.
        let semanticContentAttribute = scrollView.semanticContentAttribute
        let shouldRenderRTLLayout = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        // If a new page should be requested, notify the delegate to perform the batch fetch.
        if shouldRequestNextPage(
            context: context,
            scrollDirection: scrollDirection,
            scrollableDirections: scrollableDirections,
            bounds: scrollView.bounds,
            contentSize: scrollView.contentSize,
            targetOffset: newContentOffset,
            leadingScreens: leadingScreensForBatching,
            visible: isVisible,
            shouldRenderRTLLayout: shouldRenderRTLLayout,
            flipsHorizontallyInOppositeLayoutDirection: flipsHorizontallyInOppositeLayoutDirection) {
            delegate.pagination(self, prefetchNextPageWith: context)
        }
    }

    /// Determines whether a new page should be requested based on various scroll view attributes and the current pagination context.
    ///
    /// This function evaluates if a batch fetch should be triggered based on the current state of the scroll view and the pagination context. It considers the visibility of the scroll view, the scroll direction, and other relevant factors.
    ///
    /// - Parameters:
    ///   - context: The `PaginationContext` that contains information about the current pagination state.
    ///   - scrollDirection: The direction in which the user is scrolling.
    ///   - scrollableDirections: The scroll directions that are enabled for pagination.
    ///   - bounds: The bounds of the scroll view's visible area.
    ///   - contentSize: The total content size of the scroll view.
    ///   - targetOffset: The current content offset of the scroll view.
    ///   - leadingScreens: The number of screens' worth of content distance that should trigger a batch fetch.
    ///   - visible: A boolean indicating whether the scroll view is visible in the window.
    ///   - shouldRenderRTLLayout: A boolean indicating whether the layout direction should be rendered right-to-left.
    ///   - flipsHorizontallyInOppositeLayoutDirection: A boolean indicating whether the scroll view's layout flips horizontally in the opposite layout direction.
    /// - Returns: A boolean indicating whether a new page should be requested.
    func shouldRequestNextPage(
        context: PaginationContext,
        scrollDirection: ScrollDirection,
        scrollableDirections: ScrollDirection,
        bounds: CGRect,
        contentSize: CGSize,
        targetOffset: CGPoint,
        leadingScreens: CGFloat,
        visible: Bool,
        shouldRenderRTLLayout: Bool,
        flipsHorizontallyInOppositeLayoutDirection: Bool) -> Bool {
        
        // If the scroll view is not visible, do not batch fetch.
        guard visible else {
            return false
        }
        
        // Do not allow fetching if a batch is already in-flight and hasn't been completed or cancelled.
        if context.isFetching {
            return false
        }
        
        // No fetching if leadingScreens is less than or equal to 0 or if bounds are empty.
        if leadingScreens <= 0.0 || bounds.isEmpty {
            return false
        }
        
        // Do not allow fetching if scroll direction is not observed.
        guard scrollableDirections.contains(scrollDirection) else {
            return false
        }
        
        let viewLength: CGFloat
        let offset: CGFloat
        let contentLength: CGFloat
        
        // Determine the dimensions and offset based on the scroll direction (vertical or horizontal).
        if scrollableDirections.contains(.vertical) {
            viewLength = bounds.size.height
            offset = targetOffset.y
            contentLength = contentSize.height
        } else { // horizontal
            viewLength = bounds.size.width
            offset = targetOffset.x
            contentLength = contentSize.width
        }
        
        // If content length is smaller than the view length, always request a new page.
        if contentLength < viewLength {
            return true
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
        
        // If scrolling towards the head of the content (up or left), do not request a new page.
        if isScrollingTowardHead {
            return false
        }
        
        // Calculate the distance remaining to the end of the content.
        let triggerDistance = viewLength * leadingScreens
        var remainingDistance: CGFloat = 0
        
        // If the scroll view flips horizontally in the opposite layout direction and RTL layout is enabled, calculate remaining distance accordingly.
        if !flipsHorizontallyInOppositeLayoutDirection && shouldRenderRTLLayout && scrollableDirections.contains(.horizontal) {
            remainingDistance = offset
        } else {
            remainingDistance = contentLength - viewLength - offset
        }
        
        // Determine if the remaining distance is within the trigger distance to request a new page.
        return remainingDistance <= triggerDistance
    }

}
