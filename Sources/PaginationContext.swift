import Foundation

/// A `PaginationContext` is responsible for managing and tracking the state of a pagination operation in a scrollable view.
///
/// This class ensures thread safety and provides methods to control the state of pagination, making it suitable for use in complex, asynchronous operations that require reliable state management.
/// Concurrency safety is enforced via `NSLock`, so it is safe to pass across actors.
@objcMembers public final class PaginationContext: NSObject, @unchecked Sendable {

  /// A lock to ensure thread safety when accessing or modifying the state.
  internal let lock: NSLock

  /// The current state of the pagination context, reflecting its progress through the pagination lifecycle.
  ///
  /// A `nil` value indicates that no pagination operation has been started yet.
  public private(set) var state: PaginationState?

  /// Initializes a new `PaginationContext` instance with no active state.
  ///
  /// This initializer sets up the pagination context and ensures it is ready for use in managing pagination operations.
  public override init() {
    self.state = nil
    self.lock = NSLock()
    super.init()
  }

  /// A Boolean value indicating whether a pagination operation has been started and is in progress.
  ///
  /// This property is useful for checking the context's status before initiating a new fetch operation.
  public var isStarted: Bool {
    var started: Bool
    lock.lock()
    started = state == .started
    lock.unlock()
    return started
  }

  /// A Boolean value indicating whether the context's operation has been cancelled.
  ///
  /// This property helps determine if a pagination operation was intentionally stopped before completion.
  public var isCancelled: Bool {
    var cancelled: Bool
    lock.lock()
    cancelled = state == .cancelled
    lock.unlock()
    return cancelled
  }

  /// A Boolean value indicating whether the context's operation has completed.
  ///
  /// Use this property to check if the pagination operation has successfully finished.
  public var isCompleted: Bool {
    var completed: Bool
    lock.lock()
    completed = state == .completed
    lock.unlock()
    return completed
  }

  /// A Boolean value indicating whether the context's operation has failed.
  ///
  /// This property helps identify if an error occurred during the pagination process.
  public var isFailed: Bool {
    var failed: Bool
    lock.lock()
    failed = state == .failed
    lock.unlock()
    return failed
  }

  /// Starts the pagination context, transitioning it to a started state.
  ///
  /// This method should be called when a new page of data is being requested, marking the beginning of the pagination process.
  public func start() {
    lock.lock()
    state = .started
    lock.unlock()
  }

  /// Cancels the ongoing pagination context.
  ///
  /// Use this method to stop the pagination operation if it's no longer needed, such as when a user navigates away from the current view.
  public func cancel() {
    lock.lock()
    state = .cancelled
    lock.unlock()
  }

  /// Marks the pagination context as either completed or failed, based on the provided parameter.
  ///
  /// - Parameter isCompleted: A Boolean value indicating whether the pagination operation was successful (`true`) or if it failed (`false`).
  ///
  /// This method should be called once the pagination operation concludes, ensuring the context accurately reflects its final state.
  public func finish(_ isCompleted: Bool) {
    lock.lock()
    state = isCompleted ? .completed : .failed
    lock.unlock()
  }
}
