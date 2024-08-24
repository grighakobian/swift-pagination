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
///         context.start()
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
/// > Warning: It is mandatory to call `context.start()` when pagination begins and `context.finish(_:)` with either `true` or `false` once the data loading is complete, to accurately reflect the pagination state.
///
/// This class provides methods to monitor scroll view events and manage pagination state efficiently.
@objcMembers open class Pagination: NSObject {
    /// The scroll view associated with the paginator.
    ///
    /// This scroll view is monitored for scroll events to trigger pagination.
    ///
    /// Defaults to `nil`.
    weak var scrollView: UIScrollView? {
        didSet { togglePrefetcingEnabled() }
    }

    /// A Boolean value that determines whether the pagination is enabled.
    ///
    /// Defaults to `true`.
    public var isEnabled: Bool {
        didSet { togglePrefetcingEnabled() }
    }

    /// The delegate to notify about pagination events.
    public weak var delegate: PaginationDelegate? {
        didSet { togglePrefetcingEnabled() }
    }

    /// The context managing the current state of pagination.
    ///
    /// This property tracks the state of pagination, including in-flight fetches and their status.
    public private(set) var context: PaginationContext

    /// The scrollable directions supported by the paginator for triggering pagination.
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
    override init() {
        self.isEnabled = true
        self.direction = .down
        self.context = PaginationContext()
        self.leadingScreensForPrefetching = 2.0
        super.init()
    }

    /// Manages the observation of the scroll view’s content offset to trigger pagination.
    func togglePrefetcingEnabled() {
        guard let scrollView, let delegate, isEnabled else {
            self.observation = nil
            return
        }
        self.observation = scrollView.observe(\.contentOffset, options: [.old, .new]) { scrollView, change in
            DispatchQueue.main.async { [unowned self] in
                // If the scroll view is not visible, don't prefetch.
                guard scrollView.window != nil else { return }
                // Determine the scroll direction based on the change in content offset.
                let paginationDirection = PaginationDirection(change: change)
                // If a new page should be requested, notify the delegate to prefetch.
                if shouldPrefetchNextPage(for: scrollView, in: paginationDirection) {
                    delegate.pagination(self, prefetchNextPageWith: context)
                }
            }
        }
    }

    /// Determines whether the next page of data should be prefetched based on the scroll view’s current state.
    ///
    /// - Parameters:
    ///   - scrollView: The scroll view being monitored for pagination.
    ///   - paginationDirection: The detected direction of scrolling.
    /// - Returns: A Boolean value indicating whether the next page should be prefetched.
    func shouldPrefetchNextPage(for scrollView: UIScrollView, in paginationDirection: PaginationDirection) -> Bool {
        // Do not allow fetching if a batch is already in-flight and hasn't been completed or cancelled.
        if context.isFetching {
            return false
        }
        // No prefetching if leadingScreens is less than or equal to 0 or if bounds are empty.
        if leadingScreensForPrefetching <= 0.0 || scrollView.bounds.isEmpty {
            return false
        }
        let offset: CGFloat
        let viewLength: CGFloat
        let contentLength: CGFloat
        if self.direction.contains(.vertical) {
            offset = scrollView.contentOffset.y
            viewLength = scrollView.bounds.size.height
            contentLength = scrollView.contentSize.height
        } else {
            offset = scrollView.contentOffset.x
            viewLength = scrollView.bounds.size.width
            contentLength = scrollView.contentSize.width
        }
        // If content length is smaller than the view length, always request a new page.
        if contentLength < viewLength {
            return true
        }
        // Do not allow fetching if scroll direction is not observed.
        guard self.direction.contains(paginationDirection) else {
            return false
        }
        // Calculate the distance remaining to the end of the content.
        var remainingDistance: CGFloat = 0
        let triggerDistance = viewLength * leadingScreensForPrefetching
        // Check if the scroll view flips horizontally in opposite layout directions (only applicable to UICollectionView).
        let flipsHorizontallyInOppositeLayoutDirection: Bool = {
            if let collectionView = scrollView as? UICollectionView {
                return collectionView.collectionViewLayout.flipsHorizontallyInOppositeLayoutDirection
            }
            return false
        }()
        // Determine if the layout direction is right-to-left.
        let semanticContentAttribute = scrollView.semanticContentAttribute
        let isRTLLayout = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        // If the scroll view flips horizontally in the opposite layout direction and RTL layout is enabled, calculate remaining distance accordingly.
        if !flipsHorizontallyInOppositeLayoutDirection && isRTLLayout && direction.contains(.horizontal) {
            remainingDistance = offset
        } else {
            remainingDistance = contentLength - viewLength - offset
        }
        // Determine if the remaining distance is within the trigger distance to request a new page.
        return remainingDistance <= triggerDistance
    }
}
