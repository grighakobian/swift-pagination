import Foundation

/// A `PaginationContext` is responsible for managing and tracking the state of a pagination operation in a scrollable view.
///
/// This class ensures thread safety and provides methods to control the state of pagination, making it suitable for use in complex, asynchronous operations that require reliable state management.
/// Concurrency safety is enforced via `NSLock`, so it is safe to pass across actors.
@objcMembers public final class PaginationContext: NSObject, @unchecked Sendable {

  /// A lock to ensure thread safety when accessing or modifying the state.
  internal let lock: NSRecursiveLock

  /// The current state of the pagination context, reflecting its progress through the pagination lifecycle.
  ///
  /// A `nil` value indicates that no pagination operation has been started yet.
  public private(set) var state: PaginationState?

  /// Initializes a new `PaginationContext` instance with no active state.
  ///
  /// This initializer sets up the pagination context and ensures it is ready for use in managing pagination operations.
  public override init() {
    self.state = .none
    self.lock = NSRecursiveLock()
    super.init()
  }

  /// A Boolean value indicating whether a pagination operation has been started and is in progress.
  ///
  /// This property is useful for checking the context's status before initiating a new fetch operation.
  public var isStarted: Bool {
    lock.withLock {
      state == .started
    }
  }

  /// A Boolean value indicating whether the context's operation has been cancelled.
  ///
  /// This property helps determine if a pagination operation was intentionally stopped before completion.
  public var isCancelled: Bool {
    lock.withLock {
      state == .cancelled
    }
  }

  /// A Boolean value indicating whether the context's operation has completed.
  ///
  /// Use this property to check if the pagination operation has successfully finished.
  public var isCompleted: Bool {
    lock.withLock {
      state == .completed
    }
  }

  /// A Boolean value indicating whether the context's operation has failed.
  ///
  /// This property helps identify if an error occurred during the pagination process.
  public var isFailed: Bool {
    lock.withLock {
      state == .failed
    }
  }

  /// Updates the pagination context's state.
  ///
  /// - Parameter state: The new `PaginationState` to transition the context to.
  ///
  /// Use this method to drive the pagination lifecycle, e.g. `.started` when a new page is requested,
  /// `.completed` or `.failed` when the operation concludes, or `.cancelled` when it is aborted.
  public func update(state: PaginationState) {
    lock.withLock {
      self.state = state
    }
  }
}
