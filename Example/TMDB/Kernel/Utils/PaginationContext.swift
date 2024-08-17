//
//  Pagination.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 08.11.21.
//

import Foundation

public enum PaginationState {
    case fetching
    case cancelled
    case completed
}

open class PaginationContext {
    
    private var state: PaginationState
    private let lock = NSRecursiveLock()
    
    public init() {
        lock.lock()
        state = .completed
        lock.unlock()
    }
    
    public var isFetching: Bool {
        lock.lock(); defer { lock.unlock() }
        return state == .fetching
    }
    
    public var isCancelled: Bool {
        lock.lock(); defer { lock.unlock() }
        return state == .cancelled
    }
    
    public func start() {
        lock.lock()
        state = .fetching
        lock.unlock()
    }
    
    public func cancel() {
        lock.lock()
        state = .cancelled
        lock.unlock()
    }
    
    public func finish(_ isFinished: Bool) {
        if (isFinished) {
            lock.lock()
            state = .completed
            lock.unlock()
        }
    }
}
