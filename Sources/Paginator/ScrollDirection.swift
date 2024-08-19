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
