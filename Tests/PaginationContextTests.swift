import Testing

@testable import Pagination

@Suite("PaginationContext")
struct PaginationContextTests {

  @Test("Initial state is nil")
  func initialState() {
    let context = PaginationContext()
    #expect(context.state == nil)
    #expect(!context.isStarted)
    #expect(!context.isCancelled)
    #expect(!context.isCompleted)
    #expect(!context.isFailed)
  }

  @Test("Start transitions to started state")
  func startPrefetching() {
    let context = PaginationContext()
    context.start()
    #expect(context.isStarted)
    #expect(!context.isCancelled)
    #expect(!context.isCompleted)
    #expect(!context.isFailed)
  }

  @Test("Cancel transitions to cancelled state")
  func cancelPrefetching() {
    let context = PaginationContext()
    context.start()
    context.cancel()
    #expect(!context.isStarted)
    #expect(context.isCancelled)
    #expect(!context.isCompleted)
    #expect(!context.isFailed)
  }

  @Test("Finish with true transitions to completed state")
  func finishPrefetchingSuccessfully() {
    let context = PaginationContext()
    context.start()
    context.finish(true)
    #expect(!context.isStarted)
    #expect(!context.isCancelled)
    #expect(context.isCompleted)
    #expect(!context.isFailed)
  }

  @Test("Finish with false transitions to failed state")
  func prefetchingFailed() {
    let context = PaginationContext()
    context.start()
    context.finish(false)
    #expect(!context.isStarted)
    #expect(!context.isCancelled)
    #expect(!context.isCompleted)
    #expect(context.isFailed)
  }
}
