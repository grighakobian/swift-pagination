import CoreGraphics
import Testing

@testable import Pagination

#if canImport(UIKit)
  import UIKit

  @Suite("UIKit Integration")
  @MainActor
  struct UIKitIntegrationTests {

    @Test("Scroll view triggers delegate when scrolled past threshold")
    func scrollViewIntegration() {
      let scrollView = FakeScrollView()
      let delegate = SpyPaginationDelegate()
      let screenHeight: CGFloat = 100
      scrollView.bounds = .verticalRect(height: screenHeight)
      scrollView.contentSize = .verticalSize(height: 3 * screenHeight)
      scrollView.pagination.delegate = delegate
      scrollView.pagination.direction = .vertical
      scrollView.pagination.leadingScreensForPrefetching = 1
      scrollView.setContentOffset(.verticalOffset(y: screenHeight * 2.5), animated: false)
      #expect(delegate.didPrefetchNextPageCalled)
    }

    @Test("Table view triggers delegate when scrolled past threshold")
    func tableViewIntegration() {
      let tableView = FakeTableView()
      let delegate = SpyPaginationDelegate()
      let screenHeight: CGFloat = 100
      tableView.bounds = .verticalRect(height: screenHeight)
      tableView.contentSize = .verticalSize(height: 3 * screenHeight)
      tableView.pagination.delegate = delegate
      tableView.pagination.direction = .vertical
      tableView.pagination.leadingScreensForPrefetching = 1
      tableView.setContentOffset(.verticalOffset(y: screenHeight * 2), animated: false)
      #expect(delegate.didPrefetchNextPageCalled)
    }

    @Test("Collection view triggers delegate when scrolled past threshold")
    func collectionViewIntegration() {
      let screenHeight: CGFloat = 100
      let collectionView = FakeCollectionView(
        frame: .horizontalRect(width: screenHeight),
        collectionViewLayout: StubCollectionViewLayout())
      let delegate = SpyPaginationDelegate()
      collectionView.contentSize = .horizontalSize(width: screenHeight * 3)
      collectionView.pagination.delegate = delegate
      collectionView.pagination.direction = .horizontal
      collectionView.pagination.leadingScreensForPrefetching = 1
      collectionView.setContentOffset(.horizontalOffset(x: screenHeight * 2.5), animated: false)
      #expect(delegate.didPrefetchNextPageCalled)
    }
  }
#endif

@Suite("Pagination")
@MainActor
struct PaginationTests {

  // MARK: - Batch Null State

  @Test("Should not fetch in null state")
  func batchNullState() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 0.0,
      snapshot: ScrollViewSnapshot(
        bounds: .zero,
        contentSize: .zero,
        contentOffset: .zero,
        isVisible: true,
        shouldRenderRTLLayout: false,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(!shouldFetch)
  }

  @Test("Should not fetch in null state with RTL layout")
  func batchNullStateRTL() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 0.0,
      snapshot: ScrollViewSnapshot(
        bounds: .zero,
        contentSize: .zero,
        contentOffset: .zero,
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(!shouldFetch)
  }

  @Test("Should not fetch in null state with RTL flip layout")
  func batchNullStateRTLFlip() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 0.0,
      snapshot: ScrollViewSnapshot(
        bounds: .zero,
        contentSize: .zero,
        contentOffset: .zero,
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: true))
    #expect(!shouldFetch)
  }

  // MARK: - Already Fetching

  @Test("Should not fetch when context is already fetching")
  func batchAlreadyFetching() {
    let context = PaginationContext()
    context.start()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: true,
        shouldRenderRTLLayout: false,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(!shouldFetch)
  }

  @Test("Should not fetch when context is already fetching in RTL layout")
  func batchAlreadyFetchingRTL() {
    let context = PaginationContext()
    context.start()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(!shouldFetch)
  }

  @Test("Should not fetch when context is already fetching in RTL flip layout")
  func batchAlreadyFetchingRTLFlip() {
    let context = PaginationContext()
    context.start()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: true))
    #expect(!shouldFetch)
  }

  // MARK: - Not Visible

  @Test("Should not fetch when scroll view is not visible")
  func isNotVisible() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: false,
        shouldRenderRTLLayout: false,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(!shouldFetch)
  }

  @Test("Should not fetch when scroll view is not visible in RTL layout")
  func isNotVisibleRTL() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: false,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(!shouldFetch)
  }

  @Test("Should not fetch when scroll view is not visible in RTL flip layout")
  func isNotVisibleRTLFlip() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: false,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: true))
    #expect(!shouldFetch)
  }

  // MARK: - Scroll Direction Detection

  @Test("Detects upward scroll direction")
  func scrollDirectionUp() {
    let direction = detectScrollDirection(
      oldOffset: .verticalOffset(y: 1),
      newOffset: .zero)
    #expect(direction == .up)
  }

  @Test("Detects downward scroll direction")
  func scrollDirectionDown() {
    let direction = detectScrollDirection(
      oldOffset: .zero,
      newOffset: .verticalOffset(y: 1))
    #expect(direction == .down)
  }

  @Test("Detects rightward scroll direction")
  func scrollDirectionRight() {
    let direction = detectScrollDirection(
      oldOffset: .zero,
      newOffset: .horizontalOffset(x: 1))
    #expect(direction == .right)
  }

  @Test("Detects leftward scroll direction")
  func scrollDirectionLeft() {
    let direction = detectScrollDirection(
      oldOffset: .horizontalOffset(x: 1),
      newOffset: .zero)
    #expect(direction == .left)
  }

  // MARK: - Supported Scroll Directions

  @Test("Should fetch for scrolling right in horizontal direction")
  func fetchScrollingRight() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: true,
        shouldRenderRTLLayout: false,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  @Test("Should fetch for scrolling down in vertical direction")
  func fetchScrollingDown() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: true,
        shouldRenderRTLLayout: false,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  @Test("Should not fetch for scrolling up in vertical direction")
  func noFetchScrollingUp() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .up,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: true,
        shouldRenderRTLLayout: false,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(!shouldFetch)
  }

  @Test("Should not fetch for scrolling left in horizontal direction")
  func noFetchScrollingLeft() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: true,
        shouldRenderRTLLayout: false,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(!shouldFetch)
  }

  // MARK: - RTL Scroll Directions

  @Test("Should not fetch for scrolling right in RTL layout")
  func noFetchScrollingRightRTL() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(!shouldFetch)
  }

  @Test("Should fetch for scrolling down in RTL layout")
  func fetchScrollingDownRTL() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  @Test("Should not fetch for scrolling up in RTL layout")
  func noFetchScrollingUpRTL() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .up,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(!shouldFetch)
  }

  @Test("Should fetch for scrolling left in RTL layout")
  func fetchScrollingLeftRTL() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  // MARK: - RTL Flip Scroll Directions

  @Test("Should not fetch for scrolling right with RTL flip layout")
  func noFetchScrollingRightRTLFlip() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: true))
    #expect(!shouldFetch)
  }

  @Test("Should fetch for scrolling down with RTL flip layout")
  func fetchScrollingDownRTLFlip() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: true))
    #expect(shouldFetch)
  }

  @Test("Should not fetch for scrolling up with RTL flip layout")
  func noFetchScrollingUpRTLFlip() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .up,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: true))
    #expect(!shouldFetch)
  }

  @Test("Should fetch for scrolling left with RTL flip layout")
  func fetchScrollingLeftRTLFlip() {
    let context = PaginationContext()
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .passingRect,
        contentSize: .passingSize,
        contentOffset: .passingPoint,
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: true))
    #expect(shouldFetch)
  }

  // MARK: - Vertical Scroll to Exact Leading

  @Test("Fetch begins when vertically scrolling to exactly 1 leading screen away")
  func verticalScrollToExactLeading() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .verticalRect(height: screen * 3),
        contentSize: .verticalSize(height: screen),
        contentOffset: .verticalOffset(y: screen * 1.0),
        isVisible: true,
        shouldRenderRTLLayout: false,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  @Test("Fetch begins when vertically scrolling to exactly 1 leading screen away in RTL layout")
  func verticalScrollToExactLeadingRTL() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .verticalRect(height: screen * 3),
        contentSize: .verticalSize(height: screen),
        contentOffset: .verticalOffset(y: screen * 1.0),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  @Test(
    "Fetch begins when vertically scrolling to exactly 1 leading screen away in RTL flip layout")
  func verticalScrollToExactLeadingRTLFlip() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .verticalRect(height: screen * 3),
        contentSize: .verticalSize(height: screen),
        contentOffset: .verticalOffset(y: screen * 1.0),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: true))
    #expect(shouldFetch)
  }

  // MARK: - Vertical Scroll Less Than Leading

  @Test("Should not fetch when vertically scrolling less than the leading distance away")
  func verticalScrollToLessThanLeading() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .verticalRect(height: screen),
        contentSize: .verticalSize(height: screen * 3),
        contentOffset: .verticalOffset(y: screen * 0.5),
        isVisible: true,
        shouldRenderRTLLayout: false,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(!shouldFetch)
  }

  @Test(
    "Should not fetch when vertically scrolling less than the leading distance away in RTL layout")
  func verticalScrollToLessThanLeadingRTL() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .verticalRect(height: screen),
        contentSize: .verticalSize(height: screen * 3),
        contentOffset: .verticalOffset(y: screen * 0.5),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(!shouldFetch)
  }

  @Test(
    "Should not fetch when vertically scrolling less than the leading distance away in RTL flip layout"
  )
  func verticalScrollToLessThanLeadingRTLFlip() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .verticalRect(height: screen),
        contentSize: .verticalSize(height: screen * 3),
        contentOffset: .verticalOffset(y: screen * 0.5),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: true))
    #expect(!shouldFetch)
  }

  // MARK: - Vertical Scrolling Past Content Size

  @Test("Fetch begins when vertically scrolling past the content size")
  func verticalScrollingPastContentSize() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .verticalRect(height: screen * 3),
        contentSize: .verticalSize(height: screen),
        contentOffset: .verticalOffset(y: screen * 3.0),
        isVisible: true,
        shouldRenderRTLLayout: false,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  @Test("Fetch begins when vertically scrolling past the content size in RTL layout")
  func verticalScrollingPastContentSizeRTL() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .verticalRect(height: screen * 3),
        contentSize: .verticalSize(height: screen),
        contentOffset: .verticalOffset(y: screen * 3.0),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  @Test("Fetch begins when vertically scrolling past the content size in RTL flip layout")
  func verticalScrollingPastContentSizeRTLFlip() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .verticalRect(height: screen * 3),
        contentSize: .verticalSize(height: screen),
        contentOffset: .verticalOffset(y: screen * 3.0),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: true))
    #expect(shouldFetch)
  }

  // MARK: - Horizontal Scroll to Exact Leading

  @Test("Fetch begins when horizontally scrolling to exactly 1 leading screen away")
  func horizontalScrollToExactLeading() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .horizontalRect(width: screen),
        contentSize: .horizontalSize(width: screen * 3.0),
        contentOffset: .horizontalOffset(x: screen * 1.0),
        isVisible: true,
        shouldRenderRTLLayout: false,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  @Test("Fetch begins when horizontally scrolling to exactly 1 leading screen away in RTL layout")
  func horizontalScrollToExactLeadingRTL() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .horizontalRect(width: screen),
        contentSize: .horizontalSize(width: screen * 3.0),
        contentOffset: .horizontalOffset(x: screen * 1.0),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  @Test(
    "Fetch begins when horizontally scrolling to exactly 1 leading screen away in RTL flip layout")
  func horizontalScrollToExactLeadingRTLFlip() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .horizontalRect(width: screen),
        contentSize: .horizontalSize(width: screen * 3.0),
        contentOffset: .horizontalOffset(x: screen * 1.0),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: true))
    #expect(shouldFetch)
  }

  // MARK: - Horizontal Scroll Less Than Leading

  @Test("Should not fetch when horizontally scrolling less than the leading distance away")
  func horizontalScrollToLessThanLeading() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .horizontalRect(width: screen),
        contentSize: .horizontalSize(width: screen * 3.0),
        contentOffset: .horizontalOffset(x: screen * 0.5),
        isVisible: true,
        shouldRenderRTLLayout: false,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(!shouldFetch)
  }

  @Test(
    "Should fetch when horizontally scrolling less than the leading distance away in RTL layout")
  func horizontalScrollToLessThanLeadingRTL() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .horizontalRect(width: screen),
        contentSize: .horizontalSize(width: screen * 3.0),
        contentOffset: .horizontalOffset(x: screen * 0.5),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  @Test(
    "Should not fetch when horizontally scrolling less than the leading distance away in RTL flip layout"
  )
  func horizontalScrollToLessThanLeadingRTLFlip() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .horizontalRect(width: screen),
        contentSize: .horizontalSize(width: screen * 3.0),
        contentOffset: .horizontalOffset(x: screen * 0.5),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: true))
    #expect(!shouldFetch)
  }

  // MARK: - Horizontal Scrolling Past Content Size

  @Test("Fetch begins when horizontally scrolling past the content size")
  func horizontalScrollingPastContentSize() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .horizontal,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .horizontalRect(width: screen),
        contentSize: .horizontalSize(width: screen * 3.0),
        contentOffset: .horizontalOffset(x: screen * 3.0),
        isVisible: true,
        shouldRenderRTLLayout: false,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  @Test("Should not fetch when horizontally scrolling past the content size in RTL layout")
  func horizontalScrollingPastContentSizeRTL() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .horizontal,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .horizontalRect(width: screen),
        contentSize: .horizontalSize(width: screen * 3.0),
        contentOffset: .horizontalOffset(x: screen * 3.0),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(!shouldFetch)
  }

  @Test(
    "Fetch begins when horizontally scrolling past the content size with flipped RTL layout")
  func horizontalScrollingPastContentSizeRTLFlip() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .horizontal,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .horizontalRect(width: screen),
        contentSize: .horizontalSize(width: screen * 3.0),
        contentOffset: .horizontalOffset(x: screen * 3.0),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: true))
    #expect(shouldFetch)
  }

  // MARK: - Vertical Small Content Size

  @Test("Fetch begins when vertical content size is smaller than the screen")
  func verticalScrollingSmallContentSize() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .verticalRect(height: screen * 3),
        contentSize: .verticalSize(height: screen * 0.5),
        contentOffset: .verticalOffset(y: 0.0),
        isVisible: true,
        shouldRenderRTLLayout: false,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  @Test("Fetch begins when vertical content size is smaller than the screen in RTL layout")
  func verticalScrollingSmallContentSizeRTL() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .verticalRect(height: screen * 3),
        contentSize: .verticalSize(height: screen * 0.5),
        contentOffset: .verticalOffset(y: 0.0),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  @Test("Fetch begins when vertical content size is smaller than the screen in RTL flip layout")
  func verticalScrollingSmallContentSizeRTLFlip() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .verticalRect(height: screen * 3),
        contentSize: .verticalSize(height: screen * 0.5),
        contentOffset: .verticalOffset(y: 0.0),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: true))
    #expect(shouldFetch)
  }

  // MARK: - Horizontal Small Content Size

  @Test("Fetch begins when horizontal content size is smaller than the screen")
  func horizontalScrollingSmallContentSize() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .horizontalRect(width: screen),
        contentSize: .horizontalSize(width: screen * 0.5),
        contentOffset: .horizontalOffset(x: 0.0),
        isVisible: true,
        shouldRenderRTLLayout: false,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  @Test("Fetch begins when horizontal content size is smaller than the screen in RTL layout")
  func horizontalScrollingSmallContentSizeRTL() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .horizontalRect(width: screen),
        contentSize: .horizontalSize(width: screen * 0.5),
        contentOffset: .horizontalOffset(x: 0.0),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: false))
    #expect(shouldFetch)
  }

  @Test("Fetch begins when horizontal content size is smaller than the screen in RTL flip layout")
  func horizontalScrollingSmallContentSizeRTLFlip() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      leadingScreens: 1.0,
      snapshot: ScrollViewSnapshot(
        bounds: .horizontalRect(width: screen),
        contentSize: .horizontalSize(width: screen * 0.5),
        contentOffset: .horizontalOffset(x: 0.0),
        isVisible: true,
        shouldRenderRTLLayout: true,
        flipsHorizontallyInOppositeLayoutDirection: true))
    #expect(shouldFetch)
  }
}

// MARK: - Extensions

extension CGRect {
  static var passingRect: CGRect {
    return CGRect(x: 0, y: 0, width: 1, height: 1)
  }

  static func verticalRect(height: CGFloat) -> CGRect {
    return CGRect(x: 0, y: 0, width: 1, height: height)
  }

  static func horizontalRect(width: CGFloat) -> CGRect {
    return CGRect(x: 0, y: 0, width: width, height: 1)
  }
}

extension CGSize {
  static var passingSize: CGSize {
    return CGSize(width: 1, height: 1)
  }

  static func verticalSize(height: CGFloat) -> CGSize {
    return CGSize(width: 0, height: height)
  }

  static func horizontalSize(width: CGFloat) -> CGSize {
    return CGSize(width: width, height: 0)
  }
}

extension CGPoint {
  static var passingPoint: CGPoint {
    return CGPoint(x: 1, y: 1)
  }

  static func verticalOffset(y: CGFloat) -> CGPoint {
    return CGPoint(x: 0, y: y)
  }

  static func horizontalOffset(x: CGFloat) -> CGPoint {
    return CGPoint(x: x, y: 0)
  }
}
