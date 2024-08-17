//
//  LoadingState+Differentiable.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 10.11.21.
//

import DifferenceKit

extension LoadingState: Differentiable {
    
    public typealias DifferenceIdentifier = String
    
    public var differenceIdentifier: String {
        switch self {
        case .loading:
            return "item-loading"
        case .failed:
            return "item-failed"
        }
    }
    
    public func isContentEqual(to source: LoadingState) -> Bool {
        switch (self, source) {
        case (.loading, .loading):
            return true
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}
