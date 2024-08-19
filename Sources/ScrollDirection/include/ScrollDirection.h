//
//  ScrollDirection.h
//
//
//  Created by Grigor Hakobyan on 19.08.24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Represents the possible scroll directions as an option set.
typedef NS_OPTIONS(int8_t, ScrollDirection) {
    /// Scroll direction to the right.
    ScrollDirectionRight     = 1 << 0,
    /// Scroll direction to the left.
    ScrollDirectionLeft      = 1 << 1,
    /// Scroll direction upward.
    ScrollDirectionUp        = 1 << 2,
    /// Scroll direction downward.
    ScrollDirectionDown      = 1 << 3,
    /// The horizontal scroll direction.
    ScrollDirectionHorizontal = ScrollDirectionLeft | ScrollDirectionRight,
    /// The vertical scroll direction.
    ScrollDirectionVertical   = ScrollDirectionUp | ScrollDirectionDown
};

NS_ASSUME_NONNULL_END
