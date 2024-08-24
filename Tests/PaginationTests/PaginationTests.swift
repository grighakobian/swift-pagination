import XCTest
@testable import Pagination

final class PaginatorTests: XCTestCase {

    var paginator: Pagination!
    var mockWindow: UIWindow!
    var mockViewController: UIViewController!
    var mockScrollView: UIScrollView!
    var mockDelegate: MockPaginationDelegate!

    override func setUp() {
        super.setUp()
        paginator = Pagination()
        paginator.leadingScreensForPrefetching = 0.5
        paginator.direction = .vertical
        mockWindow = UIWindow()
        mockViewController = UIViewController()
        mockScrollView = UIScrollView()
        mockViewController.view = mockScrollView
        mockWindow.rootViewController = mockViewController
        mockDelegate = MockPaginationDelegate()
    }

    override func tearDown() {
        paginator = nil
        mockDelegate = nil
        mockWindow = nil
        mockViewController = nil
        mockScrollView = nil
        super.tearDown()
    }
    
    func testAttachScrollView() {
        paginator.attach(to: mockScrollView)
        XCTAssertNotNil(paginator.scrollView, "ScrollView should be attached")
    }
    
    func testDetach() {
        paginator.delegate = mockDelegate
        paginator.attach(to: mockScrollView)
        paginator.detach()
        XCTAssertNil(paginator.observation, "observation token should be nil")
        XCTAssertNil(paginator.scrollView, "scrollView should be nil")
        XCTAssertNil(paginator.delegate, "delegate should be nil")
    }
    
    func testScrollDirection() {
        paginator.direction = .horizontal
        XCTAssertEqual(paginator.direction, .horizontal, "Scroll directions should be horizontal")
    }
    
    func testNotVisible() {
        paginator.direction = .vertical
        paginator.delegate = mockDelegate
        paginator.attach(to: mockScrollView)
        // Simulate scroll to trigger pagination
        mockScrollView.setContentOffset(CGPoint(x: 0, y: 1000), animated: false)
        XCTAssertFalse(mockDelegate.didRequestNextPageCalled, "Delegate method didRequestNextPageWith shouldn't be called if scroll view is not visible")
    }
    
    func testIsFetching() {
        mockWindow.makeKeyAndVisible()
        paginator.direction = .vertical
        paginator.delegate = mockDelegate
        paginator.attach(to: mockScrollView)
        paginator.context.start()
        mockScrollView.setContentOffset(CGPoint(x: 0, y: 1000), animated: false)
        XCTAssertFalse(mockDelegate.didRequestNextPageCalled, "Delegate method didRequestNextPageWith shouldn't be called if the context is already fetching")
    }
    
    func testLeadingScreensIsEmpty() {
        mockWindow.makeKeyAndVisible()
        paginator.direction = .vertical
        paginator.leadingScreensForPrefetching = 0
        paginator.delegate = mockDelegate
        paginator.attach(to: mockScrollView)
        mockScrollView.setContentOffset(CGPoint(x: 0, y: 1000), animated: false)
        XCTAssertFalse(mockDelegate.didRequestNextPageCalled, "Delegate method didRequestNextPageWith shouldn't be called if the leadingScreensForBatching is 0")
    }

    func testDelegateCalledVerticalScrollDirection() {
        mockWindow.makeKeyAndVisible()
        paginator.direction = .vertical
        paginator.delegate = mockDelegate
        paginator.attach(to: mockScrollView)
        // Simulate scroll to trigger pagination
        mockScrollView.setContentOffset(CGPoint(x: 0, y: 1000), animated: false)
        XCTAssertTrue(mockDelegate.didRequestNextPageCalled, "Delegate method didRequestNextPageWith should be called")
    }
    
    func testDelegateCalledHorizontalScrollDirection() {
        mockWindow.makeKeyAndVisible()
        paginator.direction = .horizontal
        paginator.delegate = mockDelegate
        paginator.attach(to: mockScrollView)
        // Simulate scroll to trigger pagination
        mockScrollView.setContentOffset(CGPoint(x: 1000, y: 0), animated: false)
        XCTAssertTrue(mockDelegate.didRequestNextPageCalled, "Delegate method didRequestNextPageWith should be called")
    }
    
    func testDelegateNotCalledWhenScrollingHorizontalDirection() {
        mockWindow.makeKeyAndVisible()
        mockScrollView.contentSize = CGSize(width: 400, height: 1200)
        paginator.direction = .vertical
        paginator.delegate = mockDelegate
        paginator.attach(to: mockScrollView)
        // Simulate scroll to trigger pagination
        mockScrollView.setContentOffset(CGPoint(x: 1000, y: 0), animated: false)
        XCTAssertFalse(mockDelegate.didRequestNextPageCalled, "Delegate method didRequestNextPageWith shouldn't be called")
    }
    
    func testDelegateNotCalledWhenScrollingVerticalDirection() {
        mockWindow.makeKeyAndVisible()
        mockScrollView.contentSize = CGSize(width: 400, height: 1200)
        paginator.direction = .horizontal
        paginator.delegate = mockDelegate
        paginator.attach(to: mockScrollView)
        // Simulate scroll to trigger pagination
        mockScrollView.setContentOffset(CGPoint(x: 0, y: 1000), animated: false)
        XCTAssertFalse(mockDelegate.didRequestNextPageCalled, "Delegate method didRequestNextPageWith shouldn't be called")
    }
    
    func testDelegateNotCalledWhenScrollingTowardHeadInVerticalScrollDirection() {
        mockWindow.makeKeyAndVisible()
        mockScrollView.contentSize = CGSize(width: 400, height: 1200)
        paginator.direction = .vertical
        paginator.delegate = mockDelegate
        paginator.attach(to: mockScrollView)
        // Simulate scroll to trigger pagination
        mockScrollView.setContentOffset(CGPoint(x: 0, y: -100), animated: false)
        XCTAssertFalse(mockDelegate.didRequestNextPageCalled, "Delegate method didRequestNextPageWith shouldn't be called")
    }
    
    func testDelegateNotCalledWhenScrollingTowardHeadInHorizontalScrollDirection() {
        mockWindow.makeKeyAndVisible()
        mockScrollView.contentSize = CGSize(width: 400, height: 1200)
        paginator.direction = .horizontal
        paginator.delegate = mockDelegate
        paginator.attach(to: mockScrollView)
        // Simulate scroll to trigger pagination
        mockScrollView.setContentOffset(CGPoint(x: -100, y: 0), animated: false)
        XCTAssertFalse(mockDelegate.didRequestNextPageCalled, "Delegate method didRequestNextPageWith shouldn't be called")
    }
    
    func testDelegateNotSet() {
        paginator.attach(to: mockScrollView)
        // Simulate scroll to trigger pagination
        mockScrollView.setContentOffset(CGPoint(x: 0, y: 1000), animated: false)
        XCTAssertFalse(mockDelegate.didRequestNextPageCalled, "Delegate method didRequestNextPageWith shouldn't be called")
    }
}

class MockPaginationDelegate: PaginationDelegate {
    var didRequestNextPageCalled = false
    var shouldRequestNextPageResult = true

    func pagination(_ paginator: Pagination, shouldRequestNextPageWith context: PaginationContext) -> Bool {
        return shouldRequestNextPageResult
    }

    func pagination(_ paginator: Pagination, prefetchNextPageWith context: PaginationContext) {
        context.start()
        didRequestNextPageCalled = true
        context.finish(true)
    }
}
