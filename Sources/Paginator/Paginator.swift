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
import UIKit

public protocol PaginatorDelegate: AnyObject {
    func paginator(_ paginator: Paginator, willRequestNextPageWith context: PaginationContext)-> Bool
    func paginator(_ paginator: Paginator, didRequestNextPageWith context: PaginationContext)
}

open class Paginator: NSObject {
    /// The scroll view that in-flight fetches are happening.
    ///
    /// Defaults to nil.
    public private(set) weak var scrollView: UIScrollView?
    /// The scrollable directions for pagination.
    ///
    /// Defaults to `.vertical`.
    public var scrollableDirections: ScrollDirection
    /// The delegate to be consulted if needed.
    ///
    /// Defaults to nil.
    public weak var delegate: PaginatorDelegate?
    /// The batch fetching context that contains knowledge about in-flight fetches.
    public private(set) var context: PaginationContext
    /// How many screens in the remaining distance will trigger batch fetching.
    ///
    /// Defaults to 2.0.
    public var leadingScreensForBatching: CGFloat
    /// The obervation token.
    private var observationToken: NSKeyValueObservation?
    
    public init(scrollView: UIScrollView? = .none,
                scrollableDirections: ScrollDirection = .vertical,
                delegate: PaginatorDelegate? = .none,
                leadingScreensForBatching: CGFloat = 2.0) {
        
        self.scrollView = scrollView
        self.scrollableDirections = scrollableDirections
        self.context = PaginationContext()
        self.leadingScreensForBatching = leadingScreensForBatching
        self.delegate = delegate
        super.init()
    }
    
    deinit {
        observationToken?.invalidate()
    }
    
    public func attach(to scrollView: UIScrollView) {
        observationToken?.invalidate()
        observationToken = nil
        
        self.scrollView = scrollView
        observeValues(for: scrollView)
    }
    
    private func observeValues(for scrollView: UIScrollView) {
        let keyPath: KeyPath = \UIScrollView.contentOffset
        let options: NSKeyValueObservingOptions = [.old, .new]

        observationToken = scrollView.observe(keyPath, options: options) { [unowned self] scrollView, change in
            requestNextPageIfNeeded(for: scrollView, with: change)
        }
    }
    
    private func requestNextPageIfNeeded(for scrollView: UIScrollView, with change: NSKeyValueObservedChange<CGPoint>) {
        if delegate?.paginator(self, willRequestNextPageWith: context) == false {
            return
        }
                
        guard let oldContentOffset = change.oldValue,
              let newContentOffset = change.newValue else {
            return
        }
        
        var scrollDirection: ScrollDirection = []
        if (oldContentOffset.x == newContentOffset.x) {
            if (oldContentOffset.y < newContentOffset.y) {
                scrollDirection.insert(.down)
            } else {
                scrollDirection.insert(.up)
            }
        } else if oldContentOffset.y == newContentOffset.y {
            if (oldContentOffset.x < newContentOffset.x) {
                scrollDirection.insert(.right)
            } else {
                scrollDirection.insert(.left)
            }
        }
        
        var flipsHorizontallyInOppositeLayoutDirection = false
        if #available(iOS 11.0, *) {
            if let collectionView = scrollView as? UICollectionView {
                let layout = collectionView.collectionViewLayout
                flipsHorizontallyInOppositeLayoutDirection = layout.flipsHorizontallyInOppositeLayoutDirection
            }
        }
        
        let shouldRequestNextPage = shouldRequestNextPage(
            scrollView: scrollView,
            scrollDirection: scrollDirection,
            scrollableDirections: scrollableDirections,
            contentOffset: newContentOffset,
            flipsHorizontallyInOppositeLayoutDirection: flipsHorizontallyInOppositeLayoutDirection
        )
        
        if shouldRequestNextPage {
            // perform batch fetching
            delegate?.paginator(self, didRequestNextPageWith: context)
        }
    }
    
    private func shouldRequestNextPage(scrollView: UIScrollView,
                                       scrollDirection: ScrollDirection,
                                       scrollableDirections: ScrollDirection,
                                       contentOffset: CGPoint,
                                       flipsHorizontallyInOppositeLayoutDirection: Bool)-> Bool {
        
        // Check if we should batch fetch
        let bounds = scrollView.bounds
        let contentSize = scrollView.contentSize
        let isVisible = scrollView.window != nil
        let semanticContentAttribute = scrollView.semanticContentAttribute
        let shouldRenderRTLLayout = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft

        return shouldRequestNextPage(context: context,
                                     scrollDirection: scrollDirection,
                                     scrollableDirections: scrollableDirections,
                                     bounds: bounds,
                                     contentSize: contentSize,
                                     targetOffset: contentOffset,
                                     leadingScreens: leadingScreensForBatching,
                                     visible: isVisible,
                                     shouldRenderRTLLayout: shouldRenderRTLLayout,
                                     flipsHorizontallyInOppositeLayoutDirection: flipsHorizontallyInOppositeLayoutDirection)
    }
    
    private func shouldRequestNextPage(context: PaginationContext,
                                       scrollDirection: ScrollDirection,
                                       scrollableDirections: ScrollDirection,
                                       bounds: CGRect,
                                       contentSize: CGSize,
                                       targetOffset: CGPoint,
                                       leadingScreens: CGFloat,
                                       visible: Bool,
                                       shouldRenderRTLLayout: Bool,
                                       flipsHorizontallyInOppositeLayoutDirection: Bool) -> Bool {
        
        // Do not allow fetching if a batch is already in-flight and hasn't been completed or cancelled
        if (context.isFetching) {
            return false
        }
        
        // No fetching for null states
        if (leadingScreens <= 0.0 || bounds.isEmpty) {
            return false
        }
        
        let viewLength, offset, contentLength: CGFloat
        if scrollableDirections.contains(.vertical) {
            viewLength = bounds.size.height
            offset = targetOffset.y
            contentLength = contentSize.height
        } else { // horizontal / right
            viewLength = bounds.size.width
            offset = targetOffset.x
            contentLength = contentSize.width
        }
        
        let hasSmallContent = contentLength < viewLength
        if (hasSmallContent) {
            return true
        }
        
        // If we are not visible, but we do have enough content to fill visible area,
        // don't batch fetch.
        if (visible == false) {
            return false
        }
        
        // If they are scrolling toward the head of content, don't batch fetch.
        let isScrollingTowardHead = (scrollDirection.contains(.up) || (shouldRenderRTLLayout ? scrollDirection.contains(.right) : scrollDirection.contains(.left)))
        if (isScrollingTowardHead) {
            return false;
        }
        
        let triggerDistance = viewLength * leadingScreens
        var remainingDistance: CGFloat = 0
        let containsHorizontalDirection = scrollableDirections.contains(.left) && scrollableDirections.contains(.right)
        if (!flipsHorizontallyInOppositeLayoutDirection && shouldRenderRTLLayout && containsHorizontalDirection) {
            remainingDistance = offset
        } else {
            remainingDistance = contentLength - viewLength - offset
        }
        
        let result = remainingDistance <= triggerDistance;
        return result
    }
}
