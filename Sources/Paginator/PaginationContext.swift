import Foundation

/// A pagination context to manage and track the state of pagination.
public final class PaginationContext: NSObject {
    
    /// The various states of the pagination context.
    public enum State {
        /// The context is currently fetching.
        case fetching
        /// The context has been cancelled.
        case cancelled
        /// The context has completed its operation.
        case completed
        /// The context has failed during operation.
        case failed
    }

    private(set) var state: State
    internal let lock: NSRecursiveLock
    
    public override init() {
        self.state = .completed
        self.lock = NSRecursiveLock()
        super.init()
    }
    
    /// Indicates whether the ongoing context is fetching.
    public var isFetching: Bool {
        lock.lock()
        defer { lock.unlock() }
        return state == .fetching
    }
    
    /// Indicates whether the ongoing context is cancelled.
    public var isCancelled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return state == .cancelled
    }
    
    /// Indicates whether the ongoing context is failed.
    public var isFailed: Bool {
        lock.lock()
        defer { lock.unlock() }
        return state == .failed
    }
    
    /// Start the pagination context.
    public func start() {
        lock.lock()
        state = .fetching
        lock.unlock()
    }
    
    /// Cancel the ongoing pagination context.
    public func cancel() {
        lock.lock()
        state = .cancelled
        lock.unlock()
    }
    
    /// Marks the pagination context as completed or failed.
    /// - Parameter isCompleted: A boolean value indicating if the pagination operation is completed (`true`) or failed (`false`).
    public func finish(_ isCompleted: Bool) {
        lock.lock()
        state = isCompleted ? .completed : .failed
        lock.unlock()
    }
}
