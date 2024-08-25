import Foundation

/// Represents the pagination direction.
@objcMembers public class ScrollDirection: NSObject, ExpressibleByArrayLiteral {
  /// The raw value used to store the pagination direction options.
  internal var rawValue: Int8

  /// Creates a new `ScrollDirection` instance with the specified raw value.
  /// - Parameter rawValue: The raw value representing the paginatio directions.
  internal init(rawValue: Int8) {
    self.rawValue = rawValue
  }

  public required init(arrayLiteral elements: ScrollDirection...) {
    self.rawValue = elements.reduce(into: 0, { $0 |= $1.rawValue })
  }

  /// Pagination direction to the right.
  internal static let right = ScrollDirection(rawValue: 1 << 0)

  /// Pagination direction to the left.
  internal static let left = ScrollDirection(rawValue: 1 << 1)

  /// Pagination direction upward.
  internal static let up = ScrollDirection(rawValue: 1 << 2)

  /// Pagination direction downward.
  internal static let down = ScrollDirection(rawValue: 1 << 3)

  /// The horizontal pagination direction.
  public static let horizontal: ScrollDirection = ScrollDirection(
    rawValue: right.rawValue | left.rawValue)

  /// The vertical pagination direction.
  public static let vertical: ScrollDirection = ScrollDirection(
    rawValue: up.rawValue | down.rawValue)

  /// Checks if the current pagination direction contains a specific direction.
  /// - Parameter paginationDirection: The `ScrollDirection` to check for.
  /// - Returns: A boolean value indicating whether the current direction includes the specified direction.
  func contains(_ paginationDirection: ScrollDirection) -> Bool {
    return rawValue & paginationDirection.rawValue != 0
  }

  /// Adds a specific paginationDirection direction to the current direction.
  /// - Parameter paginationDirection: The `ScrollDirection` to add.
  func insert(_ paginationDirection: ScrollDirection) {
    self.rawValue |= paginationDirection.rawValue
  }

  /// Determines if two `ScrollDirection` instances are equal based on their raw values.
  ///
  /// This method is used to compare two `ScrollDirection` instances for equality.
  /// - Parameter object: The object to compare with the current instance.
  /// - Returns: A boolean value indicating whether the two objects are equal.
  public override func isEqual(_ object: Any?) -> Bool {
    guard let scrollDirection = object as? ScrollDirection else {
      return false
    }
    return self.rawValue == scrollDirection.rawValue
  }
}

// MARK: - CustomStringConvertible

extension ScrollDirection {
  public override var description: String {
    if self == .left {
      return "left"
    } else if self == .right {
      return "right"
    } else if self == .up {
      return "up"
    } else if self == .down {
      return "down"
    } else if self == .vertical {
      return "vertical"
    } else if self == .horizontal {
      return "horizontal"
    } else {
      return ""
    }
  }
}
