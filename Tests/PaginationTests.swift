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
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .zero,
      scrollViewContentSize: .zero,
      scrollViewContentOffset: .zero,
      leadingScreens: 0.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(!shouldFetch)
  }

  @Test("Should not fetch in null state with RTL layout")
  func batchNullStateRTL() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .zero,
      scrollViewContentSize: .zero,
      scrollViewContentOffset: .zero,
      leadingScreens: 0.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(!shouldFetch)
  }

  @Test("Should not fetch in null state with RTL flip layout")
  func batchNullStateRTLFlip() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .zero,
      scrollViewContentSize: .zero,
      scrollViewContentOffset: .zero,
      leadingScreens: 0.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    #expect(!shouldFetch)
  }

  // MARK: - Already Fetching

  @Test("Should not fetch when context is already fetching")
  func batchAlreadyFetching() {
    let sut = Pagination()
    let context = PaginationContext()
    context.start()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(!shouldFetch)
  }

  @Test("Should not fetch when context is already fetching in RTL layout")
  func batchAlreadyFetchingRTL() {
    let sut = Pagination()
    let context = PaginationContext()
    context.start()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(!shouldFetch)
  }

  @Test("Should not fetch when context is already fetching in RTL flip layout")
  func batchAlreadyFetchingRTLFlip() {
    let sut = Pagination()
    let context = PaginationContext()
    context.start()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    #expect(!shouldFetch)
  }

  // MARK: - Not Visible

  @Test("Should not fetch when scroll view is not visible")
  func isNotVisible() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: false,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(!shouldFetch)
  }

  @Test("Should not fetch when scroll view is not visible in RTL layout")
  func isNotVisibleRTL() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: false,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(!shouldFetch)
  }

  @Test("Should not fetch when scroll view is not visible in RTL flip layout")
  func isNotVisibleRTLFlip() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: false,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    #expect(!shouldFetch)
  }

  // MARK: - Scroll Direction Detection

  @Test("Detects upward scroll direction")
  func scrollDirectionUp() {
    let sut = Pagination()
    let direction = sut.detectScrollDirection(
      oldOffset: .verticalOffset(y: 1),
      newOffset: .zero)
    #expect(direction == .up)
  }

  @Test("Detects downward scroll direction")
  func scrollDirectionDown() {
    let sut = Pagination()
    let direction = sut.detectScrollDirection(
      oldOffset: .zero,
      newOffset: .verticalOffset(y: 1))
    #expect(direction == .down)
  }

  @Test("Detects rightward scroll direction")
  func scrollDirectionRight() {
    let sut = Pagination()
    let direction = sut.detectScrollDirection(
      oldOffset: .zero,
      newOffset: .horizontalOffset(x: 1))
    #expect(direction == .right)
  }

  @Test("Detects leftward scroll direction")
  func scrollDirectionLeft() {
    let sut = Pagination()
    let direction = sut.detectScrollDirection(
      oldOffset: .horizontalOffset(x: 1),
      newOffset: .zero)
    #expect(direction == .left)
  }

  // MARK: - Supported Scroll Directions

  @Test("Should fetch for scrolling right in horizontal direction")
  func fetchScrollingRight() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  @Test("Should fetch for scrolling down in vertical direction")
  func fetchScrollingDown() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  @Test("Should not fetch for scrolling up in vertical direction")
  func noFetchScrollingUp() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .up,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(!shouldFetch)
  }

  @Test("Should not fetch for scrolling left in horizontal direction")
  func noFetchScrollingLeft() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(!shouldFetch)
  }

  // MARK: - RTL Scroll Directions

  @Test("Should not fetch for scrolling right in RTL layout")
  func noFetchScrollingRightRTL() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(!shouldFetch)
  }

  @Test("Should fetch for scrolling down in RTL layout")
  func fetchScrollingDownRTL() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  @Test("Should not fetch for scrolling up in RTL layout")
  func noFetchScrollingUpRTL() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .up,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(!shouldFetch)
  }

  @Test("Should fetch for scrolling left in RTL layout")
  func fetchScrollingLeftRTL() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  // MARK: - RTL Flip Scroll Directions

  @Test("Should not fetch for scrolling right with RTL flip layout")
  func noFetchScrollingRightRTLFlip() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    #expect(!shouldFetch)
  }

  @Test("Should fetch for scrolling down with RTL flip layout")
  func fetchScrollingDownRTLFlip() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    #expect(shouldFetch)
  }

  @Test("Should not fetch for scrolling up with RTL flip layout")
  func noFetchScrollingUpRTLFlip() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .up,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    #expect(!shouldFetch)
  }

  @Test("Should fetch for scrolling left with RTL flip layout")
  func fetchScrollingLeftRTLFlip() {
    let sut = Pagination()
    let context = PaginationContext()
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    #expect(shouldFetch)
  }

  // MARK: - Vertical Scroll to Exact Leading

  @Test("Fetch begins when vertically scrolling to exactly 1 leading screen away")
  func verticalScrollToExactLeading() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen * 3),
      scrollViewContentSize: .verticalSize(height: screen),
      scrollViewContentOffset: .verticalOffset(y: screen * 1.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  @Test("Fetch begins when vertically scrolling to exactly 1 leading screen away in RTL layout")
  func verticalScrollToExactLeadingRTL() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen * 3),
      scrollViewContentSize: .verticalSize(height: screen),
      scrollViewContentOffset: .verticalOffset(y: screen * 1.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  @Test(
    "Fetch begins when vertically scrolling to exactly 1 leading screen away in RTL flip layout")
  func verticalScrollToExactLeadingRTLFlip() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen * 3),
      scrollViewContentSize: .verticalSize(height: screen),
      scrollViewContentOffset: .verticalOffset(y: screen * 1.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    #expect(shouldFetch)
  }

  // MARK: - Vertical Scroll Less Than Leading

  @Test("Should not fetch when vertically scrolling less than the leading distance away")
  func verticalScrollToLessThanLeading() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen),
      scrollViewContentSize: .verticalSize(height: screen * 3),
      scrollViewContentOffset: .verticalOffset(y: screen * 0.5),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(!shouldFetch)
  }

  @Test(
    "Should not fetch when vertically scrolling less than the leading distance away in RTL layout")
  func verticalScrollToLessThanLeadingRTL() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen),
      scrollViewContentSize: .verticalSize(height: screen * 3),
      scrollViewContentOffset: .verticalOffset(y: screen * 0.5),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(!shouldFetch)
  }

  @Test(
    "Should not fetch when vertically scrolling less than the leading distance away in RTL flip layout"
  )
  func verticalScrollToLessThanLeadingRTLFlip() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen),
      scrollViewContentSize: .verticalSize(height: screen * 3),
      scrollViewContentOffset: .verticalOffset(y: screen * 0.5),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    #expect(!shouldFetch)
  }

  // MARK: - Vertical Scrolling Past Content Size

  @Test("Fetch begins when vertically scrolling past the content size")
  func verticalScrollingPastContentSize() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen * 3),
      scrollViewContentSize: .verticalSize(height: screen),
      scrollViewContentOffset: .verticalOffset(y: screen * 3.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  @Test("Fetch begins when vertically scrolling past the content size in RTL layout")
  func verticalScrollingPastContentSizeRTL() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen * 3),
      scrollViewContentSize: .verticalSize(height: screen),
      scrollViewContentOffset: .verticalOffset(y: screen * 3.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  @Test("Fetch begins when vertically scrolling past the content size in RTL flip layout")
  func verticalScrollingPastContentSizeRTLFlip() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen * 3),
      scrollViewContentSize: .verticalSize(height: screen),
      scrollViewContentOffset: .verticalOffset(y: screen * 3.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    #expect(shouldFetch)
  }

  // MARK: - Horizontal Scroll to Exact Leading

  @Test("Fetch begins when horizontally scrolling to exactly 1 leading screen away")
  func horizontalScrollToExactLeading() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 3.0),
      scrollViewContentOffset: .horizontalOffset(x: screen * 1.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  @Test("Fetch begins when horizontally scrolling to exactly 1 leading screen away in RTL layout")
  func horizontalScrollToExactLeadingRTL() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 3.0),
      scrollViewContentOffset: .horizontalOffset(x: screen * 1.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  @Test(
    "Fetch begins when horizontally scrolling to exactly 1 leading screen away in RTL flip layout")
  func horizontalScrollToExactLeadingRTLFlip() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 3.0),
      scrollViewContentOffset: .horizontalOffset(x: screen * 1.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    #expect(shouldFetch)
  }

  // MARK: - Horizontal Scroll Less Than Leading

  @Test("Should not fetch when horizontally scrolling less than the leading distance away")
  func horizontalScrollToLessThanLeading() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 3.0),
      scrollViewContentOffset: .horizontalOffset(x: screen * 0.5),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(!shouldFetch)
  }

  @Test(
    "Should fetch when horizontally scrolling less than the leading distance away in RTL layout")
  func horizontalScrollToLessThanLeadingRTL() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 3.0),
      scrollViewContentOffset: .horizontalOffset(x: screen * 0.5),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  @Test(
    "Should not fetch when horizontally scrolling less than the leading distance away in RTL flip layout"
  )
  func horizontalScrollToLessThanLeadingRTLFlip() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 3.0),
      scrollViewContentOffset: .horizontalOffset(x: screen * 0.5),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    #expect(!shouldFetch)
  }

  // MARK: - Horizontal Scrolling Past Content Size

  @Test("Fetch begins when horizontally scrolling past the content size")
  func horizontalScrollingPastContentSize() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 3.0),
      scrollViewContentOffset: .horizontalOffset(x: screen * 3.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  @Test("Should not fetch when horizontally scrolling past the content size in RTL layout")
  func horizontalScrollingPastContentSizeRTL() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 3.0),
      scrollViewContentOffset: .horizontalOffset(x: screen * 3.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(!shouldFetch)
  }

  @Test(
    "Fetch begins when horizontally scrolling past the content size with flipped RTL layout")
  func horizontalScrollingPastContentSizeRTLFlip() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 3.0),
      scrollViewContentOffset: .horizontalOffset(x: screen * 3.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    #expect(shouldFetch)
  }

  // MARK: - Vertical Small Content Size

  @Test("Fetch begins when vertical content size is smaller than the screen")
  func verticalScrollingSmallContentSize() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen * 3),
      scrollViewContentSize: .verticalSize(height: screen * 0.5),
      scrollViewContentOffset: .verticalOffset(y: 0.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  @Test("Fetch begins when vertical content size is smaller than the screen in RTL layout")
  func verticalScrollingSmallContentSizeRTL() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen * 3),
      scrollViewContentSize: .verticalSize(height: screen * 0.5),
      scrollViewContentOffset: .verticalOffset(y: 0.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  @Test("Fetch begins when vertical content size is smaller than the screen in RTL flip layout")
  func verticalScrollingSmallContentSizeRTLFlip() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen * 3),
      scrollViewContentSize: .verticalSize(height: screen * 0.5),
      scrollViewContentOffset: .verticalOffset(y: 0.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    #expect(shouldFetch)
  }

  // MARK: - Horizontal Small Content Size

  @Test("Fetch begins when horizontal content size is smaller than the screen")
  func horizontalScrollingSmallContentSize() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 0.5),
      scrollViewContentOffset: .horizontalOffset(x: 0.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  @Test("Fetch begins when horizontal content size is smaller than the screen in RTL layout")
  func horizontalScrollingSmallContentSizeRTL() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 0.5),
      scrollViewContentOffset: .horizontalOffset(x: 0.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    #expect(shouldFetch)
  }

  @Test("Fetch begins when horizontal content size is smaller than the screen in RTL flip layout")
  func horizontalScrollingSmallContentSizeRTLFlip() {
    let sut = Pagination()
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    let shouldFetch = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 0.5),
      scrollViewContentOffset: .horizontalOffset(x: 0.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
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
