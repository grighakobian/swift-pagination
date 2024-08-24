import XCTest
@testable import Pagination

final class UIScrollViewPaginationTests: XCTestCase {

    var mockScrollView: UIScrollView!
    var mockDelegate: MockPaginationDelegate!

    override func setUp() {
        super.setUp()

        mockScrollView = UIScrollView()
        mockDelegate = MockPaginationDelegate()
    }

    override func tearDown() {
        super.tearDown()

        mockScrollView = nil
        mockDelegate = nil
    }

    func testGetPagination() {
        let pagination = mockScrollView.pagination
        XCTAssertNotNil(pagination.scrollView)
    }

    func testSetPagination() {
        let pagination = Pagination()
        mockScrollView.pagination = pagination
        XCTAssertTrue(mockScrollView.pagination === pagination)
    }

    func testTogglePaginationEnabled() {
        mockScrollView.pagination.isEnabled = false
        XCTAssertFalse(mockScrollView.pagination.isEnabled)
        mockScrollView.pagination.isEnabled = true
        XCTAssertTrue(mockScrollView.pagination.isEnabled == true)
    }

    func testSetPaginationDelegate() {
        mockScrollView.pagination.delegate = mockDelegate
        XCTAssertNotNil(mockScrollView.pagination.delegate)
        mockScrollView.pagination.delegate = nil
        XCTAssertNil(mockScrollView.pagination.delegate)
    }

    func testSetPaginationDirection() {
        mockScrollView.pagination.direction = .horizontal
        XCTAssertTrue(mockScrollView.pagination.direction == .horizontal)
        mockScrollView.pagination.direction = .vertical
        XCTAssertTrue(mockScrollView.pagination.direction == .vertical)
    }

    func testSetPaginationLeadingScreens() {
        mockScrollView.pagination.leadingScreensForPrefetching = 3
        XCTAssertTrue(mockScrollView.pagination.leadingScreensForPrefetching == 3)
        mockScrollView.pagination.leadingScreensForPrefetching = 1
        XCTAssertTrue(mockScrollView.pagination.leadingScreensForPrefetching == 1)
    }
}
