import XCTest
@testable import Pagination

final class PaginationContextTests: XCTestCase {

    func testInitialState() {
        let context = PaginationContext()
        XCTAssertFalse(context.isFetching)
    }

    func testStartPrefetching() {
        let context = PaginationContext()
        context.start()
        XCTAssertTrue(context.isFetching)
    }

    func testCancelPrefetching() {
        let context = PaginationContext()
        context.start()
        context.cancel()
        XCTAssertFalse(context.isFetching)
        XCTAssertTrue(context.isCancelled)
    }

    func testFinishPrefetchingSuccessfully() {
        let context = PaginationContext()
        context.start()
        context.finish(true)
        XCTAssertFalse(context.isFetching)
        XCTAssertTrue(context.isCompleted)
        XCTAssertFalse(context.isFailed)
    }

    func testPrefetchingFailed() {
        let context = PaginationContext()
        context.start()
        context.finish(false)
        XCTAssertFalse(context.isFetching)
        XCTAssertFalse(context.isCompleted)
        XCTAssertTrue(context.isFailed)
    }
}
