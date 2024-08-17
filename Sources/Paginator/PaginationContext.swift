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


/// A pagination context to track pagination state.
public final class PaginationContext {
    /// The pagination context state.
    public enum State {
        /// State fetching.
        case fetching
        /// State cancelled.
        case cancelled
        /// State completed.
        case completed
        /// State failed.
        case failed
    }

    /// The pagination context state.
    ///
    /// Defaults to `.completed`.
    @Protected
    private var state: PaginationContext.State = .completed
    
    /// Indicates wheter the ongoing context is fetching.
    public var isFetching: Bool {
        return state == .fetching
    }
    
    /// Indicates wheter the ongoing context is cancelled.
    public var isCancelled: Bool {
        return state == .cancelled
    }
    
    /// Indicates wheter the ongoing context is failed.
    public var isFailed: Bool {
        return state == .failed
    }
    
    /// Start the pagination context.
    public func start() {
        state = .fetching
    }
    
    /// Cancel the ongoing pagination context.
    public func cancel() {
        state = .cancelled
    }
    
    /// Finish the ongoing pagination.
    /// - Parameter isCompleted: A boolean value that indicates wheter the
    ///                          ongoing pagination is completed or failed.
    public func finish(_ isCompleted: Bool) {
        if (isCompleted) {
            state = .completed
        } else {
            state = .failed
        }
    }
}
