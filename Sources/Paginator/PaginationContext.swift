//    Copyright (c) 2021 Grigor Hakobyan <grighakobian@gmail.com>
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.


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
