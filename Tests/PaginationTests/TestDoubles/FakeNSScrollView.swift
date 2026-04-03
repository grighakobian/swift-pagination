#if canImport(AppKit)
import AppKit

final class FakeNSScrollView: NSScrollView {
  var isVisible: Bool = true

  override var window: NSWindow? {
    isVisible ? NSWindow() : nil
  }

  /// Simulates scrolling to the given content offset by updating the clip view bounds.
  func simulateScroll(to offset: CGPoint) {
    contentView.scroll(to: offset)
    reflectScrolledClipView(contentView)
  }
}
#endif
