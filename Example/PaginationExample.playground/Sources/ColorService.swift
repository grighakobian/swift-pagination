import UIKit

/// The response returned by a color service.
public struct ColorResponse {
  public let colors: [Color]
  public let page: Int
  public let totalPages: Int
}

/// A service that fetches pages of colors.
public protocol ColorService {
  /// Fetches a page of colors.
  /// - Parameter page: The page number to fetch (1-indexed).
  /// - Returns: A `ColorResponse` containing the colors, current page, and total pages.
  func fetchColors(page: Int) async throws -> ColorResponse
}

/// A color service implementation that generates random colors with a simulated network delay.
public final class ColorServiceImpl: ColorService {
  private let pageSize: Int
  private let totalPages: Int
  private let delay: TimeInterval

  public init(pageSize: Int = 20, totalPages: Int = 5, delay: TimeInterval = 1.0) {
    self.pageSize = pageSize
    self.totalPages = totalPages
    self.delay = delay
  }

  private static let palette: [(name: String, color: UIColor)] = [
    ("Red", UIColor(red: 0.90, green: 0.22, blue: 0.21, alpha: 1)),
    ("Blue", UIColor(red: 0.13, green: 0.59, blue: 0.95, alpha: 1)),
    ("Green", UIColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1)),
    ("Orange", UIColor(red: 1.00, green: 0.60, blue: 0.00, alpha: 1)),
    ("Purple", UIColor(red: 0.61, green: 0.15, blue: 0.69, alpha: 1)),
    ("Teal", UIColor(red: 0.00, green: 0.59, blue: 0.53, alpha: 1)),
    ("Pink", UIColor(red: 0.91, green: 0.12, blue: 0.39, alpha: 1)),
    ("Indigo", UIColor(red: 0.25, green: 0.32, blue: 0.71, alpha: 1)),
    ("Mint", UIColor(red: 0.00, green: 0.78, blue: 0.55, alpha: 1)),
    ("Cyan", UIColor(red: 0.00, green: 0.74, blue: 0.83, alpha: 1)),
    ("Yellow", UIColor(red: 1.00, green: 0.76, blue: 0.03, alpha: 1)),
    ("Brown", UIColor(red: 0.47, green: 0.33, blue: 0.28, alpha: 1)),
    ("Coral", UIColor(red: 1.00, green: 0.44, blue: 0.37, alpha: 1)),
    ("Lavender", UIColor(red: 0.68, green: 0.51, blue: 0.84, alpha: 1)),
    ("Magenta", UIColor(red: 0.83, green: 0.18, blue: 0.55, alpha: 1)),
    ("Crimson", UIColor(red: 0.77, green: 0.12, blue: 0.23, alpha: 1)),
    ("Emerald", UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1)),
    ("Sapphire", UIColor(red: 0.06, green: 0.32, blue: 0.73, alpha: 1)),
    ("Amber", UIColor(red: 1.00, green: 0.70, blue: 0.00, alpha: 1)),
    ("Violet", UIColor(red: 0.54, green: 0.23, blue: 0.78, alpha: 1)),
  ]

  public func fetchColors(page: Int) async throws -> ColorResponse {
    try await Task.sleep(for: .seconds(delay))

    let colors = (0..<pageSize).map { index in
      let globalIndex = (page - 1) * pageSize + index
      let entry = Self.palette[globalIndex % Self.palette.count]
      return Color(name: "\(entry.name) \(globalIndex + 1)", color: entry.color)
    }

    return ColorResponse(colors: colors, page: page, totalPages: totalPages)
  }
}
