import AppKit

struct ColorItem: Hashable {
  let name: String
  let color: NSColor

  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }

  static func == (lhs: ColorItem, rhs: ColorItem) -> Bool {
    lhs.name == rhs.name
  }
}

enum ColorPalette {
  static let entries: [(name: String, color: NSColor)] = [
    ("Red", NSColor(red: 0.90, green: 0.22, blue: 0.21, alpha: 1)),
    ("Blue", NSColor(red: 0.13, green: 0.59, blue: 0.95, alpha: 1)),
    ("Green", NSColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1)),
    ("Orange", NSColor(red: 1.00, green: 0.60, blue: 0.00, alpha: 1)),
    ("Purple", NSColor(red: 0.61, green: 0.15, blue: 0.69, alpha: 1)),
    ("Teal", NSColor(red: 0.00, green: 0.59, blue: 0.53, alpha: 1)),
    ("Pink", NSColor(red: 0.91, green: 0.12, blue: 0.39, alpha: 1)),
    ("Indigo", NSColor(red: 0.25, green: 0.32, blue: 0.71, alpha: 1)),
    ("Mint", NSColor(red: 0.00, green: 0.78, blue: 0.55, alpha: 1)),
    ("Cyan", NSColor(red: 0.00, green: 0.74, blue: 0.83, alpha: 1)),
  ]

  static func page(_ page: Int, pageSize: Int = 20) -> [ColorItem] {
    (0..<pageSize).map { index in
      let globalIndex = (page - 1) * pageSize + index
      let entry = entries[globalIndex % entries.count]
      return ColorItem(name: "\(entry.name) \(globalIndex + 1)", color: entry.color)
    }
  }
}
