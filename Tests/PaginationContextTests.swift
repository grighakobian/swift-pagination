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

  @Test("Update to started transitions to started state")
  func updateStarted() {
    let context = PaginationContext()
    context.update(state: .started)
    #expect(context.isStarted)
    #expect(!context.isCancelled)
    #expect(!context.isCompleted)
    #expect(!context.isFailed)
  }

  @Test("Update to cancelled transitions to cancelled state")
  func updateCancelled() {
    let context = PaginationContext()
    context.update(state: .started)
    context.update(state: .cancelled)
    #expect(!context.isStarted)
    #expect(context.isCancelled)
    #expect(!context.isCompleted)
    #expect(!context.isFailed)
  }

  @Test("Update to completed transitions to completed state")
  func updateCompleted() {
    let context = PaginationContext()
    context.update(state: .started)
    context.update(state: .completed)
    #expect(!context.isStarted)
    #expect(!context.isCancelled)
    #expect(context.isCompleted)
    #expect(!context.isFailed)
  }

  @Test("Update to failed transitions to failed state")
  func updateFailed() {
    let context = PaginationContext()
    context.update(state: .started)
    context.update(state: .failed)
    #expect(!context.isStarted)
    #expect(!context.isCancelled)
    #expect(!context.isCompleted)
    #expect(context.isFailed)
  }
}
