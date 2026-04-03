import UIKit

/// A simple model representing a named color.
public struct Color: Hashable {
  public let name: String
  public let color: UIColor

  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }

  public static func == (lhs: Color, rhs: Color) -> Bool {
    lhs.name == rhs.name
  }
}
