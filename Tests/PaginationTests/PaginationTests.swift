import XCTest

@testable import Pagination

final class PaginatorTests: XCTestCase {

  let PASSING_RECT: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
  let PASSING_SIZE: CGSize = CGSize(width: 1, height: 1)
  let PASSING_POINT: CGPoint = CGPoint(x: 1, y: 1)

  func VERTICAL_RECT(_ h: CGFloat) -> CGRect {
    return CGRect(x: 0, y: 0, width: 1, height: h)
  }

  func VERTICAL_SIZE(_ h: CGFloat) -> CGSize {
    return CGSize(width: 0, height: h)
  }

  func VERTICAL_OFFSET(_ y: CGFloat) -> CGPoint {
    return CGPoint(x: 0, y: y)
  }

  func HORIZONTAL_RECT(_ w: CGFloat) -> CGRect {
    return CGRect(x: 0, y: 0, width: w, height: 1)
  }

  func HORIZONTAL_SIZE(_ w: CGFloat) -> CGSize {
    return CGSize(width: w, height: 0)
  }

  func HORIZONTAL_OFFSET(_ x: CGFloat) -> CGPoint {
    return CGPoint(x: x, y: 0)
  }

  var sut: Pagination!

  override func setUp() {
    super.setUp()

    sut = Pagination()
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  func testBatchNullState() {
    // Test with default settings
    let shouldFetch = sut.shouldPrefetchNextPage(
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
    sut.context.start()
    defer { sut.context.finish(true) }

    let shouldFetch = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: PASSING_RECT,
      scrollViewContentSize: PASSING_SIZE,
      scrollViewContentOffset: PASSING_POINT,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertFalse(shouldFetch, "Should not fetch when context is already fetching")

    // Test RTL
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: PASSING_RECT,
      scrollViewContentSize: PASSING_SIZE,
      scrollViewContentOffset: PASSING_POINT,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertFalse(
      shouldFetchRTL, "Should not fetch when context is already fetching in RTL layout")

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: PASSING_RECT,
      scrollViewContentSize: PASSING_SIZE,
      scrollViewContentOffset: PASSING_POINT,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertFalse(
      shouldFetchRTLFlip, "Should not fetch when context is already fetching in RTL flip layout")
  }

  //    func testIntegrationWithScrollView() {
  //        let window = UIWindow()
  //        let viewController = UIViewController()
  //        let scrollView = UIScrollView()
  //        viewController.view = scrollView
  //        window.makeKeyAndVisible()
  //        let delegate = MockPaginationDelegate()
  //        scrollView.bounds = CGRect(x: 0, y: 0, width: 400, height: 900)
  //        scrollView.pagination.isEnabled = true
  //        scrollView.pagination.scrollableDirections = .vertical
  //        scrollView.pagination.leadingScreensForPrefetching = 1
  //        scrollView.pagination.delegate = delegate
  //        scrollView.contentSize = CGSize(width: 400, height: 1500)
  //        scrollView.setContentOffset(CGPoint(x: 0, y: 1200), animated: false)
  //        XCTAssertTrue(delegate.didPrefetchNextPageCalled)
  //    }

  func testUnsupportedScrollDirections() {
    // Test scrolling right
    let fetchRight = sut.shouldPrefetchNextPage(
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: PASSING_RECT,
      scrollViewContentSize: PASSING_SIZE,
      scrollViewContentOffset: PASSING_POINT,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    XCTAssertTrue(fetchRight, "Should fetch for scrolling right")

    // Test scrolling down
    let fetchDown = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: PASSING_RECT,
      scrollViewContentSize: PASSING_SIZE,
      scrollViewContentOffset: PASSING_POINT,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    XCTAssertTrue(fetchDown, "Should fetch for scrolling down")

    // Test scrolling up
    let fetchUp = sut.shouldPrefetchNextPage(
      scrollDirection: .up,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: PASSING_RECT,
      scrollViewContentSize: PASSING_SIZE,
      scrollViewContentOffset: PASSING_POINT,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    XCTAssertFalse(fetchUp, "Should not fetch for scrolling up")

    // Test scrolling left
    let fetchLeft = sut.shouldPrefetchNextPage(
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: PASSING_RECT,
      scrollViewContentSize: PASSING_SIZE,
      scrollViewContentOffset: PASSING_POINT,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false)
    XCTAssertFalse(fetchLeft, "Should not fetch for scrolling left")

    // Test RTL layout for scrolling right
    let fetchRightRTL = sut.shouldPrefetchNextPage(
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: PASSING_RECT,
      scrollViewContentSize: PASSING_SIZE,
      scrollViewContentOffset: PASSING_POINT,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    XCTAssertFalse(fetchRightRTL, "Should not fetch for scrolling right in RTL layout")

    // Test RTL layout for scrolling down
    let fetchDownRTL = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: PASSING_RECT,
      scrollViewContentSize: PASSING_SIZE,
      scrollViewContentOffset: PASSING_POINT,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    XCTAssertTrue(fetchDownRTL, "Should fetch for scrolling down in RTL layout")

    // Test RTL layout for scrolling up
    let fetchUpRTL = sut.shouldPrefetchNextPage(
      scrollDirection: .up,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: PASSING_RECT,
      scrollViewContentSize: PASSING_SIZE,
      scrollViewContentOffset: PASSING_POINT,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    XCTAssertFalse(fetchUpRTL, "Should not fetch for scrolling up in RTL layout")

    // Test RTL layout for scrolling left
    let fetchLeftRTL = sut.shouldPrefetchNextPage(
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: PASSING_RECT,
      scrollViewContentSize: PASSING_SIZE,
      scrollViewContentOffset: PASSING_POINT,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false)
    XCTAssertTrue(fetchLeftRTL, "Should fetch for scrolling left in RTL layout")

    // Test RTL layout with automatic flipping for scrolling right
    let fetchRightRTLFlip = sut.shouldPrefetchNextPage(
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: PASSING_RECT,
      scrollViewContentSize: PASSING_SIZE,
      scrollViewContentOffset: PASSING_POINT,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    XCTAssertFalse(fetchRightRTLFlip, "Should not fetch for scrolling right with RTL flip layout")

    // Test RTL layout with automatic flipping for scrolling down
    let fetchDownRTLFlip = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: PASSING_RECT,
      scrollViewContentSize: PASSING_SIZE,
      scrollViewContentOffset: PASSING_POINT,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    XCTAssertTrue(fetchDownRTLFlip, "Should fetch for scrolling down with RTL flip layout")

    // Test RTL layout with automatic flipping for scrolling up
    let fetchUpRTLFlip = sut.shouldPrefetchNextPage(
      scrollDirection: .up,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: PASSING_RECT,
      scrollViewContentSize: PASSING_SIZE,
      scrollViewContentOffset: PASSING_POINT,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    XCTAssertFalse(fetchUpRTLFlip, "Should not fetch for scrolling up with RTL flip layout")

    // Test RTL layout with automatic flipping for scrolling left
    let fetchLeftRTLFlip = sut.shouldPrefetchNextPage(
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: PASSING_RECT,
      scrollViewContentSize: PASSING_SIZE,
      scrollViewContentOffset: PASSING_POINT,
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true)
    XCTAssertTrue(fetchLeftRTLFlip, "Should fetch for scrolling left with RTL flip layout")
  }

  func testVerticalScrollToExactLeading() {
    let screen: CGFloat = 1.0
    // Scroll to 1-screen top offset, height is 1 screen, so bottom is 1 screen away from the end of content
    let shouldFetch = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: VERTICAL_RECT(screen),
      scrollViewContentSize: VERTICAL_SIZE(screen * 3.0),
      scrollViewContentOffset: VERTICAL_OFFSET(screen * 1.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetch, "Fetch should begin when vertically scrolling to exactly 1 leading screen away")

    // Test RTL
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: VERTICAL_RECT(screen),
      scrollViewContentSize: VERTICAL_SIZE(screen * 3.0),
      scrollViewContentOffset: VERTICAL_OFFSET(screen * 1.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetchRTL,
      "Fetch should begin when vertically scrolling to exactly 1 leading screen away in RTL layout")

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: VERTICAL_RECT(screen),
      scrollViewContentSize: VERTICAL_SIZE(screen * 3.0),
      scrollViewContentOffset: VERTICAL_OFFSET(screen * 1.0),
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
    let screen: CGFloat = 1.0
    // 3 screens of content, scroll only 1/2 of one screen
    let shouldFetch = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: VERTICAL_RECT(screen),
      scrollViewContentSize: VERTICAL_SIZE(screen * 3.0),
      scrollViewContentOffset: VERTICAL_OFFSET(screen * 0.5),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertFalse(
      shouldFetch,
      "Fetch should not begin when vertically scrolling less than the leading distance away")

    // Test RTL
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: VERTICAL_RECT(screen),
      scrollViewContentSize: VERTICAL_SIZE(screen * 3.0),
      scrollViewContentOffset: VERTICAL_OFFSET(screen * 0.5),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertFalse(
      shouldFetchRTL,
      "Fetch should not begin when vertically scrolling less than the leading distance away")

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: VERTICAL_RECT(screen),
      scrollViewContentSize: VERTICAL_SIZE(screen * 3.0),
      scrollViewContentOffset: VERTICAL_OFFSET(screen * 0.5),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertFalse(
      shouldFetchRTLFlip,
      "Fetch should not begin when vertically scrolling less than the leading distance away")
  }

  func testVerticalScrollingPastContentSize() {
    let screen: CGFloat = 1.0
    // 3 screens of content, top offset to 3-screens, height 1 screen, so it's 1 screen past the leading
    let shouldFetch = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: VERTICAL_RECT(screen),
      scrollViewContentSize: VERTICAL_SIZE(screen * 3.0),
      scrollViewContentOffset: VERTICAL_OFFSET(screen * 3.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(shouldFetch, "Fetch should begin when vertically scrolling past the content size")

    // Test RTL
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: VERTICAL_RECT(screen),
      scrollViewContentSize: VERTICAL_SIZE(screen * 3.0),
      scrollViewContentOffset: VERTICAL_OFFSET(screen * 3.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetchRTL,
      "Fetch should begin when vertically scrolling past the content size in RTL layout")

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: VERTICAL_RECT(screen),
      scrollViewContentSize: VERTICAL_SIZE(screen * 3.0),
      scrollViewContentOffset: VERTICAL_OFFSET(screen * 3.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertTrue(
      shouldFetchRTLFlip,
      "Fetch should begin when vertically scrolling past the content size in RTL flip layout")
  }

  //    func testHorizontalScrollToExactLeading() {
  //        let screen: CGFloat = 1.0
  //        // Scroll to 1-screen left offset, width is 1 screen, so right is 1 screen away from end of content
  //        let shouldFetch = sut.shouldPrefetchNextPage(
  //            scrollDirection: .right,
  //            paginationDirection: .horizontal,
  //            isScrollViewVisible: true,
  //            scrollViewBounds: HORIZONTAL_RECT(screen),
  //            scrollViewContentSize: HORIZONTAL_SIZE(screen * 3.0),
  //            scrollViewContentOffset: HORIZONTAL_OFFSET(screen * 1.0),
  //            leadingScreens: 1.0,
  //            shouldRenderRTLLayout: false,
  //            flipsHorizontallyInOppositeLayoutDirection: false
  //        )
  //        XCTAssertTrue(shouldFetch, "Fetch should begin when horizontally scrolling to exactly 1 leading screen away")
  //
  //        // Test RTL
  //        let shouldFetchRTL = sut.shouldPrefetchNextPage(
  //            scrollDirection: .right,
  //            paginationDirection: .horizontal,
  //            isScrollViewVisible: true,
  //            scrollViewBounds: HORIZONTAL_RECT(screen),
  //            scrollViewContentSize: HORIZONTAL_SIZE(screen * 3.0),
  //            scrollViewContentOffset: HORIZONTAL_OFFSET(screen * 1.0),
  //            leadingScreens: 1.0,
  //            shouldRenderRTLLayout: true,
  //            flipsHorizontallyInOppositeLayoutDirection: false
  //        )
  //        XCTAssertTrue(shouldFetchRTL, "Fetch should begin when horizontally scrolling to exactly 1 leading screen away in RTL layout")
  //
  //        // Test RTL with a layout that automatically flips (should act the same as LTR)
  //        let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
  //            scrollDirection: .right,
  //            paginationDirection: .horizontal,
  //            isScrollViewVisible: true,
  //            scrollViewBounds: HORIZONTAL_RECT(screen),
  //            scrollViewContentSize: HORIZONTAL_SIZE(screen * 3.0),
  //            scrollViewContentOffset: HORIZONTAL_OFFSET(screen * 1.0),
  //            leadingScreens: 1.0,
  //            shouldRenderRTLLayout: true,
  //            flipsHorizontallyInOppositeLayoutDirection: true
  //        )
  //        XCTAssertTrue(shouldFetchRTLFlip, "Fetch should begin when horizontally scrolling to exactly 1 leading screen away in RTL flip layout")
  //    }

  func testHorizontalScrollToLessThanLeading() {
    let screen: CGFloat = 1.0
    // 3 screens of content, scroll only 1/2 of one screen
    let shouldFetch = sut.shouldPrefetchNextPage(
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: HORIZONTAL_RECT(screen),
      scrollViewContentSize: HORIZONTAL_SIZE(screen * 3.0),
      scrollViewContentOffset: HORIZONTAL_OFFSET(screen * 0.5),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: false,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertFalse(
      shouldFetch,
      "Fetch should not begin when horizontally scrolling less than the leading distance away")

    // In RTL since scrolling is reversed, our remaining distance is actually our offset (0.5) which is less than our leading screen (1). So we do want to fetch
    let shouldFetchRTL = sut.shouldPrefetchNextPage(
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: HORIZONTAL_RECT(screen),
      scrollViewContentSize: HORIZONTAL_SIZE(screen * 3.0),
      scrollViewContentOffset: HORIZONTAL_OFFSET(screen * 0.5),
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
      scrollDirection: .left,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: HORIZONTAL_RECT(screen),
      scrollViewContentSize: HORIZONTAL_SIZE(screen * 3.0),
      scrollViewContentOffset: HORIZONTAL_OFFSET(screen * 0.5),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertFalse(
      shouldFetchRTLFlip,
      "Fetch should not begin when horizontally scrolling less than the leading distance away")
  }

  //    func testHorizontalScrollingPastContentSize() {
  //        let screen: CGFloat = 1.0
  //        // 3 screens of content, offset 3 screens, width 1 screen, so it's 1 screen past the leading
  //        let shouldFetch = sut.shouldPrefetchNextPage(
  //            scrollDirection: .left,
  //            paginationDirection: .horizontal,
  //            isScrollViewVisible: true,
  //            scrollViewBounds: HORIZONTAL_RECT(screen),
  //            scrollViewContentSize: HORIZONTAL_SIZE(screen * 3.0),
  //            scrollViewContentOffset: HORIZONTAL_OFFSET(screen * 3.0),
  //            leadingScreens: 1.0,
  //            shouldRenderRTLLayout: false,
  //            flipsHorizontallyInOppositeLayoutDirection: false
  //        )
  //        XCTAssertTrue(shouldFetch, "Fetch should begin when horizontally scrolling past the content size")
  //
  //        // In RTL scrolling is reversed, remaining distance is actually our offset (3) which is more than our leading screen (1). So we do not fetch
  //        let shouldFetchRTL = sut.shouldPrefetchNextPage(
  //            scrollDirection: .left,
  //            paginationDirection: .horizontal,
  //            isScrollViewVisible: true,
  //            scrollViewBounds: HORIZONTAL_RECT(screen),
  //            scrollViewContentSize: HORIZONTAL_SIZE(screen * 3.0),
  //            scrollViewContentOffset: HORIZONTAL_OFFSET(screen * 3.0),
  //            leadingScreens: 1.0,
  //            shouldRenderRTLLayout: true,
  //            flipsHorizontallyInOppositeLayoutDirection: false
  //        )
  //        XCTAssertFalse(shouldFetchRTL, "Fetch should not begin when horizontally scrolling past the content size in RTL layout")
  //
  //        // Test RTL with a layout that automatically flips (should act the same as LTR)
  //        let shouldFetchFlipRTL = sut.shouldPrefetchNextPage(
  //            scrollDirection: .left,
  //            paginationDirection: .horizontal,
  //            isScrollViewVisible: true,
  //            scrollViewBounds: HORIZONTAL_RECT(screen),
  //            scrollViewContentSize: HORIZONTAL_SIZE(screen * 3.0),
  //            scrollViewContentOffset: HORIZONTAL_OFFSET(screen * 3.0),
  //            leadingScreens: 1.0,
  //            shouldRenderRTLLayout: true,
  //            flipsHorizontallyInOppositeLayoutDirection: true
  //        )
  //        XCTAssertTrue(shouldFetchFlipRTL, "Fetch should begin when horizontally scrolling past the content size with flipped RTL layout")
  //    }

  func testVerticalScrollingSmallContentSize() {
    let screen: CGFloat = 1.0
    // When the content size is smaller than the screen size, the target offset will always be 0
    let shouldFetch = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: VERTICAL_RECT(screen),
      scrollViewContentSize: VERTICAL_SIZE(screen * 0.5),
      scrollViewContentOffset: VERTICAL_OFFSET(0.0),
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
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: VERTICAL_RECT(screen),
      scrollViewContentSize: VERTICAL_SIZE(screen * 0.5),
      scrollViewContentOffset: VERTICAL_OFFSET(0.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetchRTL,
      "Fetch should begin when the content size is smaller than the screen in RTL layout")

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
      scrollDirection: .down,
      scrollableDirections: .vertical,
      isScrollViewVisible: true,
      scrollViewBounds: VERTICAL_RECT(screen),
      scrollViewContentSize: VERTICAL_SIZE(screen * 0.5),
      scrollViewContentOffset: VERTICAL_OFFSET(0.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertTrue(
      shouldFetchRTLFlip,
      "Fetch should begin when the content size is smaller than the screen with flipped RTL layout")
  }

  func testHorizontalScrollingSmallContentSize() {
    let screen: CGFloat = 1.0
    // When the content size is smaller than the screen size, the target offset will always be 0
    let shouldFetch = sut.shouldPrefetchNextPage(
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: HORIZONTAL_RECT(screen),
      scrollViewContentSize: HORIZONTAL_SIZE(screen * 0.5),
      scrollViewContentOffset: HORIZONTAL_OFFSET(0.0),
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
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: HORIZONTAL_RECT(screen),
      scrollViewContentSize: HORIZONTAL_SIZE(screen * 0.5),
      scrollViewContentOffset: HORIZONTAL_OFFSET(0.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: false
    )
    XCTAssertTrue(
      shouldFetchRTL,
      "Fetch should begin when the content size is smaller than the screen in RTL layout")

    // Test RTL with a layout that automatically flips (should act the same as LTR)
    let shouldFetchRTLFlip = sut.shouldPrefetchNextPage(
      scrollDirection: .right,
      scrollableDirections: .horizontal,
      isScrollViewVisible: true,
      scrollViewBounds: HORIZONTAL_RECT(screen),
      scrollViewContentSize: HORIZONTAL_SIZE(screen * 0.5),
      scrollViewContentOffset: HORIZONTAL_OFFSET(0.0),
      leadingScreens: 1.0,
      shouldRenderRTLLayout: true,
      flipsHorizontallyInOppositeLayoutDirection: true
    )
    XCTAssertTrue(
      shouldFetchRTLFlip,
      "Fetch should begin when the content size is smaller than the screen with flipped RTL layout")
  }

}
