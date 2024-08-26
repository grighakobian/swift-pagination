import Dispatch

@testable import Pagination

final class MockPaginationDelegate: PaginationDelegate {
  var didPrefetchNextPageCalled = false

  func pagination(_ pagination: Pagination, prefetchNextPageWith context: PaginationContext) {
    context.start()
    self.didPrefetchNextPageCalled = true
    context.finish(true)
  }
}
