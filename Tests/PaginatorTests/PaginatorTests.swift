import XCTest
@testable import Paginator

final class PaginatorTests: XCTestCase {

    var paginator: Paginator!
    var mockWindow: UIWindow!
    var mockViewController: UITableViewController!
    var mockScrollView: UIScrollView!
    var mockDelegate: MockPaginationDelegate!

    override func setUp() {
        super.setUp()
        paginator = Paginator()
        paginator.leadingScreensForBatching = 0.5
        paginator.scrollableDirections = .vertical
        mockWindow = UIWindow()
        mockViewController = UITableViewController(style: .plain)
        mockScrollView = mockViewController.tableView
        mockWindow.rootViewController = mockViewController
        mockWindow.makeKeyAndVisible()
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
        XCTAssertNil(paginator.observationToken, "observationToken token should be nil")
        XCTAssertNil(paginator.scrollView, "scrollView should be nil")
        XCTAssertNil(paginator.delegate, "delegate should be nil")
    }

    func testScrollDirection() {
        paginator.scrollableDirections = .horizontal
        XCTAssertEqual(paginator.scrollableDirections, .horizontal, "Scroll directions should be horizontal")
    }

    func testDelegateCalledOnFetchRequest() {
        paginator.delegate = mockDelegate
        paginator.attach(to: mockScrollView)
        // Simulate scroll to trigger pagination
        mockScrollView.setContentOffset(CGPoint(x: 0, y: 1000), animated: false)
        XCTAssertTrue(mockDelegate.didRequestNextPageCalled, "Delegate method didRequestNextPageWith should be called")
    }
    
    func testDelegateNotSet() {
        paginator.attach(to: mockScrollView)
        // Simulate scroll to trigger pagination
        mockScrollView.setContentOffset(CGPoint(x: 0, y: 1000), animated: false)
        XCTAssertFalse(mockDelegate.didRequestNextPageCalled, "Delegate method didRequestNextPageWith shouldn't be called")
    }
}

// Mocking the PaginationDelegate for testing
class MockPaginationDelegate: PaginationDelegate {
    var didRequestNextPageCalled = false
    var shouldRequestNextPageResult = true

    func paginator(_ paginator: Paginator, shouldRequestNextPageWith context: PaginationContext) -> Bool {
        return shouldRequestNextPageResult
    }

    func paginator(_ paginator: Paginator, didRequestNextPageWith context: PaginationContext) {
        didRequestNextPageCalled = true
    }
}
