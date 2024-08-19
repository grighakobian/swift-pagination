import Foundation

/// A pagination context to manage and track the state of pagination.
public final class PaginationContext: NSObject {
    
    /// The various states of the pagination context.
    public enum State {
        /// The context is currently in idle state.
        case idle
        /// The context is currently fetching.
        case fetching
        /// The context has completed its operation.
        case completed
    }

    private(set) var state: State
    internal let lock: NSLock
    
    public override init() {
        self.state = .completed
        self.lock = NSLock()
        super.init()
    }
    
    /// Indicates whether the ongoing context is fetching.
    public var isFetching: Bool {
        var fetching: Bool
        lock.lock()
        fetching = state == .fetching
        lock.unlock()
        return fetching
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
        state = .idle
        lock.unlock()
    }
    
    /// Marks the pagination context as completed or failed.
    /// - Parameter isCompleted: A boolean value indicating if the pagination operation is completed.
    public func finish(_ isCompleted: Bool) {
        lock.lock()
        state = isCompleted ? .completed : .idle
        lock.unlock()
    }
}
