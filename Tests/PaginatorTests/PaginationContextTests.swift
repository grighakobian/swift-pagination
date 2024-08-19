import XCTest
@testable import Paginator

final class PaginationContextTests: XCTestCase {

    func testInitialState() {
        let context = PaginationContext()
        XCTAssertFalse(context.isFetching, "Initial state should not be fetching")
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
        XCTAssertFalse(context.isFetching, "State should be cancelled after cancel()")
    }

    func testFinishFetchingSuccess() {
        let context = PaginationContext()
        context.start()
        context.finish(true)
        XCTAssertFalse(context.isFetching, "State should be completed after finish(true)")
    }

    func testFinishFetchingFailure() {
        let context = PaginationContext()
        context.start()
        context.finish(false)
        XCTAssertFalse(context.isFetching, "State should be failed after finish(false)")
    }
}
