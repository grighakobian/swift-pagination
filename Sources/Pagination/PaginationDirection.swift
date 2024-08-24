import Foundation
/// Represents the pagination direction.
@objcMembers public class PaginationDirection: NSObject {
    /// The raw value used to store the pagination direction options.
    var rawValue: Int8

    /// Creates a new `PaginationDirection` instance with the specified raw value.
    /// - Parameter rawValue: The raw value representing the paginatio directions.
    init(rawValue: Int8) {
        self.rawValue = rawValue
    }

    /// Pagination direction to the right.
    internal static let right = PaginationDirection(rawValue: 1 << 0)

    /// Pagination direction to the left.
    internal static let left = PaginationDirection(rawValue: 1 << 1)

    /// Pagination direction upward.
    internal static let up = PaginationDirection(rawValue: 1 << 2)

    /// Pagination direction downward.
    internal static let down = PaginationDirection(rawValue: 1 << 3)

    /// The horizontal pagination direction.
    public static let horizontal: PaginationDirection = PaginationDirection(rawValue: right.rawValue | left.rawValue)

    /// The vertical pagination direction.
    public static let vertical: PaginationDirection = PaginationDirection(rawValue: up.rawValue | down.rawValue)

    /// Checks if the current pagination direction contains a specific direction.
    /// - Parameter paginationDirection: The `PaginationDirection` to check for.
    /// - Returns: A boolean value indicating whether the current direction includes the specified direction.
    func contains(_ paginationDirection: PaginationDirection) -> Bool {
        return rawValue & paginationDirection.rawValue != 0
    }

    /// Adds a specific paginationDirection direction to the current direction.
    /// - Parameter paginationDirection: The `PaginationDirection` to add.
    func insert(_ paginationDirection: PaginationDirection) {
        self.rawValue |= paginationDirection.rawValue
    }

    /// Determines if two `PaginationDirection` instances are equal based on their raw values.
    ///
    /// This method is used to compare two `PaginationDirection` instances for equality.
    /// - Parameter object: The object to compare with the current instance.
    /// - Returns: A boolean value indicating whether the two objects are equal.
    public override func isEqual(_ object: Any?) -> Bool {
        guard let scrollDirection = object as? PaginationDirection else {
            return false
        }
        return self.rawValue == scrollDirection.rawValue
    }
}

// MARK: - Convenience

extension PaginationDirection {
    /// Initializes a new `PaginationDirection` instance based on changes in content offset.
    /// 
    /// This initializer creates a `PaginationDirection` instance by comparing the old and new content offset values of a scroll view.
    /// - Parameters:
    ///   - oldOffset: The old content offset.
    ///   - newOffset: The new content offset
    convenience init(oldOffset: CGPoint, newOffset: CGPoint) {
        self.init(rawValue: 0)
        if oldOffset.x != newOffset.x {
            if oldOffset.x < newOffset.x {
                self.insert(.right)
            } else {
                self.insert(.left)
            }
        }
        if oldOffset.y != newOffset.y {
            if oldOffset.y < newOffset.y {
                self.insert(.down)
            } else {
                self.insert(.up)
            }
        }
    }
}
