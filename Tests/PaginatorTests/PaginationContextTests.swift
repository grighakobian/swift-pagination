import XCTest
@testable import Paginator

final class PaginationContextTests: XCTestCase {

    func testInitialState() {
        let context = PaginationContext()
        XCTAssertTrue(context.isCompleted, "Initial state should be completed")
        XCTAssertFalse(context.isFetching, "Initial state should not be fetching")
        XCTAssertFalse(context.isCancelled, "Initial state should not be cancelled")
        XCTAssertFalse(context.isFailed, "Initial state should not be failed")
    }

    func testStartFetching() {
        let context = PaginationContext()
        context.start()
        XCTAssertTrue(context.isFetching, "State should be fetching after start()")
    }

    func testCancelFetching() {
        let context = PaginationContext()
        context.start()
        context.cancel()
        XCTAssertTrue(context.isCancelled, "State should be cancelled after cancel()")
    }

    func testFinishFetchingSuccess() {
        let context = PaginationContext()
        context.start()
        context.finish(true)
        XCTAssertTrue(context.isCompleted, "State should be completed after finish(true)")
    }

    func testFinishFetchingFailure() {
        let context = PaginationContext()
        context.start()
        context.finish(false)
        XCTAssertTrue(context.isFailed, "State should be failed after finish(false)")
    }
}
