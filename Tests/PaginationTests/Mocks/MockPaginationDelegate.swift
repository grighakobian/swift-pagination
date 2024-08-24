@testable import Pagination

final class MockPaginationDelegate: PaginationDelegate {
    var didRequestNextPageCalled = false

    func pagination(_ paginator: Pagination, prefetchNextPageWith context: PaginationContext) {
        context.start()
        self.didRequestNextPageCalled = true
        context.finish(true)
    }
}
