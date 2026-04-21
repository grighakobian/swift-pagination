import Dispatch

@testable import Pagination

final class SpyPaginationDelegate: PaginationDelegate {
  nonisolated(unsafe) var didPrefetchNextPageCalled = false

  func pagination(_ pagination: Pagination, prefetchNextPageWith context: PaginationContext) {
    context.update(state: .started)
    self.didPrefetchNextPageCalled = true
    context.update(state: .completed)
  }
}
