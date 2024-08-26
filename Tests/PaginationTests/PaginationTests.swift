import XCTest

@testable import Pagination

final class PaginatorTests: XCTestCase {

  var sut: Pagination!

  override func setUp() {
    super.setUp()

    sut = Pagination()
  }

  override func tearDown() {
    super.tearDown()

    sut = nil
  }

  func testBatchNullState() {
    // Test with default settings
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
    XCTAssertFalse(shouldFetch, "Should not fetch in the null state")

    // Test RTL
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
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
    XCTAssertFalse(shouldFetchRTL, "Should not fetch in the null state with RTL layout")

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
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
    XCTAssertFalse(shouldFetchRTLFlip, "Should not fetch in the null state with RTL flip layout")
  }

  func testBatchAlreadyFetching() {
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
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertFalse(shouldFetch, "Should not fetch when context is already fetching")

    // Test RTL
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertFalse(
      shouldFetchRTL, "Should not fetch when context is already fetching in RTL layout")

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertFalse(
      shouldFetchRTLFlip, "Should not fetch when context is already fetching in RTL flip layout")
  }

  func testIsNotVisible() {
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
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertFalse(shouldFetch, "Should not fetch when scroll view is not visible")

    // Test RTL
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: false,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertFalse(
      shouldFetchRTL, "Should not fetch when scroll view is not visible in RTL layout")

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: false,
      scrollViewBounds: .passingRect,
      scrollViewContentSize: .passingSize,
      scrollViewContentOffset: .passingPoint,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertFalse(
      shouldFetchRTLFlip, "Should not fetch when scroll view is not visible in RTL flip layout")
  }

  func testScrollDirection() {
    let directionUp = sut.detectScrollDirection(
      oldOffset: .verticalOffset(y: 1),
      newOffset: .zero
    )
    XCTAssertTrue(directionUp == .up, "Scroll direction should be up")

    let directionDown = sut.detectScrollDirection(
      oldOffset: .zero,
      newOffset: .verticalOffset(y: 1)
    )
    XCTAssertTrue(directionDown == .down, "Scroll direction should be down")

    let directionRight = sut.detectScrollDirection(
      oldOffset: .zero,
      newOffset: .horizontalOffset(x: 1)
    )
    XCTAssertTrue(directionRight == .right, "Scroll direction should be right")

    let directionLeft = sut.detectScrollDirection(
      oldOffset: .horizontalOffset(x: 1),
      newOffset: .zero
    )
    XCTAssertTrue(directionLeft == .left, "Scroll direction should be left")
  }

  func testUnsupportedScrollDirections() {
    let context = PaginationContext()
    // Test scrolling right
    let fetchRight = sut.shouldPrefetchNextPage(
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
    XCTAssertTrue(fetchRight, "Should fetch for scrolling right")

    // Test scrolling down
    let fetchDown = sut.shouldPrefetchNextPage(
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
    XCTAssertTrue(fetchDown, "Should fetch for scrolling down")

    // Test scrolling up
    let fetchUp = sut.shouldPrefetchNextPage(
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
    XCTAssertFalse(fetchUp, "Should not fetch for scrolling up")

    // Test scrolling left
    let fetchLeft = sut.shouldPrefetchNextPage(
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
    XCTAssertFalse(fetchLeft, "Should not fetch for scrolling left")

    // Test RTL layout for scrolling right
    let fetchRightRTL = sut.shouldPrefetchNextPage(
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
    XCTAssertFalse(fetchRightRTL, "Should not fetch for scrolling right in RTL layout")

    // Test RTL layout for scrolling down
    let fetchDownRTL = sut.shouldPrefetchNextPage(
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
    XCTAssertTrue(fetchDownRTL, "Should fetch for scrolling down in RTL layout")

    // Test RTL layout for scrolling up
    let fetchUpRTL = sut.shouldPrefetchNextPage(
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
    XCTAssertFalse(fetchUpRTL, "Should not fetch for scrolling up in RTL layout")

    // Test RTL layout for scrolling left
    let fetchLeftRTL = sut.shouldPrefetchNextPage(
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
    XCTAssertTrue(fetchLeftRTL, "Should fetch for scrolling left in RTL layout")

    // Test RTL layout with automatic flipping for scrolling right
    let fetchRightRTLFlip = sut.shouldPrefetchNextPage(
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
    XCTAssertFalse(fetchRightRTLFlip, "Should not fetch for scrolling right with RTL flip layout")

    // Test RTL layout with automatic flipping for scrolling down
    let fetchDownRTLFlip = sut.shouldPrefetchNextPage(
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
    XCTAssertTrue(fetchDownRTLFlip, "Should fetch for scrolling down with RTL flip layout")

    // Test RTL layout with automatic flipping for scrolling up
    let fetchUpRTLFlip = sut.shouldPrefetchNextPage(
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
    XCTAssertFalse(fetchUpRTLFlip, "Should not fetch for scrolling up with RTL flip layout")

    // Test RTL layout with automatic flipping for scrolling left
    let fetchLeftRTLFlip = sut.shouldPrefetchNextPage(
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
    XCTAssertTrue(fetchLeftRTLFlip, "Should fetch for scrolling left with RTL flip layout")
  }

  func testVerticalScrollToExactLeading() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    // Scroll to 1-screen top offset, height is 1 screen, so bottom is 1 screen away from the end of content
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
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetch, "Fetch should begin when vertically scrolling to exactly 1 leading screen away")

    // Test RTL
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen * 3),
      scrollViewContentSize: .verticalSize(height: screen),
      scrollViewContentOffset: .verticalOffset(y: screen * 1.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetchRTL,
      "Fetch should begin when vertically scrolling to exactly 1 leading screen away in RTL layout")

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen * 3),
      scrollViewContentSize: .verticalSize(height: screen),
      scrollViewContentOffset: .verticalOffset(y: screen * 1.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertTrue(
      shouldFetchRTLFlip,
      "Fetch should begin when vertically scrolling to exactly 1 leading screen away in RTL flip layout"
    )
  }

  func testVerticalScrollToLessThanLeading() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    // 3 screens of content, scroll only 1/2 of one screen
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
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertFalse(
      shouldFetch,
      "Fetch should not begin when vertically scrolling less than the leading distance away")

    // Test RTL
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen),
      scrollViewContentSize: .verticalSize(height: screen * 3),
      scrollViewContentOffset: .verticalOffset(y: screen * 0.5),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertFalse(
      shouldFetchRTL,
      "Fetch should not begin when vertically scrolling less than the leading distance away")

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen),
      scrollViewContentSize: .verticalSize(height: screen * 3),
      scrollViewContentOffset: .verticalOffset(y: screen * 0.5),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertFalse(
      shouldFetchRTLFlip,
      "Fetch should not begin when vertically scrolling less than the leading distance away")
  }

  func testVerticalScrollingPastContentSize() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    // 3 screens of content, top offset to 3-screens, height 1 screen, so it's 1 screen past the leading
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
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(shouldFetch, "Fetch should begin when vertically scrolling past the content size")

    // Test RTL
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen * 3),
      scrollViewContentSize: .verticalSize(height: screen),
      scrollViewContentOffset: .verticalOffset(y: screen * 3.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetchRTL,
      "Fetch should begin when vertically scrolling past the content size in RTL layout")

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen * 3),
      scrollViewContentSize: .verticalSize(height: screen),
      scrollViewContentOffset: .verticalOffset(y: screen * 3.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertTrue(
      shouldFetchRTLFlip,
      "Fetch should begin when vertically scrolling past the content size in RTL flip layout")
  }

  func testHorizontalScrollToExactLeading() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    // Scroll to 1-screen left offset, width is 1 screen, so right is 1 screen away from end of content
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
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetch, "Fetch should begin when horizontally scrolling to exactly 1 leading screen away"
    )

    // Test RTL
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 3.0),
      scrollViewContentOffset: .horizontalOffset(x: screen * 1.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetchRTL,
      "Fetch should begin when horizontally scrolling to exactly 1 leading screen away in RTL layout"
    )
    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 3.0),
      scrollViewContentOffset: .horizontalOffset(x: screen * 1.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertTrue(
      shouldFetchRTLFlip,
      "Fetch should begin when horizontally scrolling to exactly 1 leading screen away in RTL flip layout"
    )
  }

  func testHorizontalScrollToLessThanLeading() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    // 3 screens of content, scroll only 1/2 of one screen
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
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertFalse(
      shouldFetch,
      "Fetch should not begin when horizontally scrolling less than the leading distance away")

    // In RTL since scrolling is reversed, our remaining distance is actually our offset (0.5) which is less than our leading screen (1). So we do want to fetch
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 3.0),
      scrollViewContentOffset: .horizontalOffset(x: screen * 0.5),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetchRTL,
      "Fetch should begin when horizontally scrolling less than the leading distance away in RTL layout"
    )

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 3.0),
      scrollViewContentOffset: .horizontalOffset(x: screen * 0.5),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertFalse(
      shouldFetchRTLFlip,
      "Fetch should not begin when horizontally scrolling less than the leading distance away")
  }

  func testHorizontalScrollingPastContentSize() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    // 3 screens of content, offset 3 screens, width 1 screen, so it's 1 screen past the leading
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
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetch, "Fetch should begin when horizontally scrolling past the content size")

    // In RTL scrolling is reversed, remaining distance is actually our offset (3) which is more than our leading screen (1). So we do not fetch
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 3.0),
      scrollViewContentOffset: .horizontalOffset(x: screen * 3.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertFalse(
      shouldFetchRTL,
      "Fetch should not begin when horizontally scrolling past the content size in RTL layout")

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchFlipRTL = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 3.0),
      scrollViewContentOffset: .horizontalOffset(x: screen * 3.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertTrue(
      shouldFetchFlipRTL,
      "Fetch should begin when horizontally scrolling past the content size with flipped RTL layout"
    )
  }

  func testVerticalScrollingSmallContentSize() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    // When the content size is smaller than the screen size, the target offset will always be 0
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
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetch,
      "Fetch should begin when the content size is smaller than the screen and the target offset is 0"
    )

    // Test RTL layout
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen * 3),
      scrollViewContentSize: .verticalSize(height: screen * 0.5),
      scrollViewContentOffset: .verticalOffset(y: 0.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetchRTL,
      "Fetch should begin when the content size is smaller than the screen in RTL layout")

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: .verticalRect(height: screen * 3),
      scrollViewContentSize: .verticalSize(height: screen * 0.5),
      scrollViewContentOffset: .verticalOffset(y: 0.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertTrue(
      shouldFetchRTLFlip,
      "Fetch should begin when the content size is smaller than the screen with flipped RTL layout")
  }

  func testHorizontalScrollingSmallContentSize() {
    let context = PaginationContext()
    let screen: CGFloat = 1.0
    // When the content size is smaller than the screen size, the target offset will always be 0
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
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetch,
      "Fetch should begin when the content size is smaller than the screen and the target offset is 0"
    )

    // Test RTL layout
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 0.5),
      scrollViewContentOffset: .horizontalOffset(x: 0.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetchRTL,
      "Fetch should begin when the content size is smaller than the screen in RTL layout")

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
      context: context,
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: .horizontalRect(width: screen),
      scrollViewContentSize: .horizontalSize(width: screen * 0.5),
      scrollViewContentOffset: .horizontalOffset(x: 0.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertTrue(
      shouldFetchRTLFlip,
      "Fetch should begin when the content size is smaller than the screen with flipped RTL layout")
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
