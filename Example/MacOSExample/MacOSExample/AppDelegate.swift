import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow!

  func applicationDidFinishLaunching(_ notification: Notification) {
    let colorsVC = ColorsViewController()

    window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 800, height: 500),
      styleMask: [.titled, .closable, .resizable, .miniaturizable],
      backing: .buffered,
      defer: false)
    window.title = "Colors"
    window.contentViewController = colorsVC
    window.center()
    window.makeKeyAndOrderFront(nil)

    NSApp.activate(ignoringOtherApps: true)
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}
