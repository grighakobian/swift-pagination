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

/// Represents the possible scroll directions as an option set.
public struct ScrollDirection: OptionSet {
    
    /// Scroll direction to the right.
    public static let right = ScrollDirection(rawValue: 1 << 0)
    
    /// Scroll direction to the left.
    public static let left = ScrollDirection(rawValue: 1 << 1)
    
    /// Scroll direction upward.
    public static let up = ScrollDirection(rawValue: 1 << 2)
    
    /// Scroll direction downward.
    public static let down = ScrollDirection(rawValue: 1 << 3)
    
    /// The combined horizontal scroll directions (left and right).
    public static let horizontal: ScrollDirection = [.left, .right]
    
    /// The combined vertical scroll directions (up and down).
    public static let vertical: ScrollDirection = [.up, .down]
    
    /// The raw value used to store the scroll direction options.
    public let rawValue: Int8
    
    /// Creates a new `ScrollDirection` instance with the specified raw value.
    /// - Parameter rawValue: The raw value representing the scroll directions.
    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }
}
