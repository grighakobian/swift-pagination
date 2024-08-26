/// Represents possible scroll direction.
struct ScrollDirection: OptionSet {
  let rawValue: UInt8
  /// Scroll direction to the left.
  static let left = ScrollDirection(rawValue: 1 << 0)
  /// Scroll direction to the right.
  static let right = ScrollDirection(rawValue: 1 << 1)
  /// Scroll direction upward.
  static let up = ScrollDirection(rawValue: 1 << 2)
  /// Scroll direction downward.
  static let down = ScrollDirection(rawValue: 1 << 3)
  /// Scroll direction vertical.
  static let vertical: ScrollDirection = [.up, .down]
  /// Scroll direction horizontal.
  static let horizontal: ScrollDirection = [.left, .right]
}
