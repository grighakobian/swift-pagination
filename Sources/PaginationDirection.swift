/// Represents the pagination direction.
@objc public enum PaginationDirection: Int {
  /// The vertical pagination direction.
  case vertical
  /// The horizontal pagination direction.
  case horizontal
}

extension PaginationDirection: CustomStringConvertible {
  public var description: String {
    switch self {
    case .vertical:
      return "vertical"
    case .horizontal:
      return "horizontal"
    }
  }
}

extension PaginationDirection {
  func contains(_ direction: ScrollDirection) -> Bool {
    switch self {
    case .vertical:
      switch direction {
      case .up, .down, .vertical:
        return true
      default:
        return false
      }
    case .horizontal:
      switch direction {
      case .left, .right, .horizontal:
        return true
      default:
        return false
      }
    }
  }
}
