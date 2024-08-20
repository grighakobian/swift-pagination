import Foundation
/// Represents the possible scroll directions.
///
/// This class provides a way to define and work with scroll directions using bitwise operations. It is designed to be compatible with both Swift and Objective-C.
///
/// > Note: Since the module fully supports Objective-C, it is not possible to use `OptionSet` in Objective-C. Therefore, this class serves as a workaround to allow similar functionality in a way that is compatible with both languages.
@objcMembers public class ScrollDirection: NSObject, ExpressibleByArrayLiteral {
    /// The raw value used to store the scroll direction options.
    var rawValue: Int8

    /// Creates a new `ScrollDirection` instance with the specified raw value.
    /// - Parameter rawValue: The raw value representing the scroll directions.
    init(rawValue: Int8) {
        self.rawValue = rawValue
    }

    /// Initializes a new instance of `ScrollDirection` from an array literal of directions.
    ///
    /// This initializer allows you to create a `ScrollDirection` instance using an array literal.
    /// # Usage
    /// ```swift
    ///   let scrollDirection: ScrollDirection = [.left, .right]
    /// ```
    ///
    /// - Parameter elements: A list of `ScrollDirection` instances to be combined.
    public required init(arrayLiteral elements: ScrollDirection...) {
        self.rawValue = elements.reduce(into: 0, { $0 |= $1.rawValue })
    }

    /// Scroll direction to the right.
    public static let right = ScrollDirection(rawValue: 1 << 0)

    /// Scroll direction to the left.
    public static let left = ScrollDirection(rawValue: 1 << 1)

    /// Scroll direction upward.
    public static let up = ScrollDirection(rawValue: 1 << 2)

    /// Scroll direction downward.
    public static let down = ScrollDirection(rawValue: 1 << 3)

    /// The combined horizontal scroll directions (left and right).
    public static let horizontal: ScrollDirection = ScrollDirection(rawValue: right.rawValue | left.rawValue)

    /// The combined vertical scroll directions (up and down).
    public static let vertical: ScrollDirection = ScrollDirection(rawValue: up.rawValue | down.rawValue)

    /// Checks if the current scroll direction contains a specific direction.
    ///
    /// - Parameter scrollDirection: The `ScrollDirection` to check for.
    /// - Returns: A boolean value indicating whether the current direction includes the specified direction.
    public func contains(_ scrollDirection: ScrollDirection) -> Bool {
        return rawValue & scrollDirection.rawValue != 0
    }

    /// Adds a specific scroll direction to the current direction.
    ///
    /// This method updates the current direction by including the specified direction.
    ///
    /// - Parameter scrollDirection: The `ScrollDirection` to add.
    public func insert(_ scrollDirection: ScrollDirection) {
        self.rawValue |= scrollDirection.rawValue
    }

    /// Determines if two `ScrollDirection` instances are equal based on their raw values.
    ///
    /// - Parameter object: The object to compare with the current instance.
    /// - Returns: A boolean value indicating whether the two objects are equal.
    public override func isEqual(_ object: Any?) -> Bool {
        guard let scrollDirection = object as? ScrollDirection else {
            return false
        }
        return self.rawValue == scrollDirection.rawValue
    }
}
