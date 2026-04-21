import SwiftUI

@main
struct ExamplesApp: App {
  var body: some Scene {
    WindowGroup {
      RootView()
    }
  }
}

private struct RootView: View {
  var body: some View {
    #if canImport(UIKit) && !os(watchOS)
    NavigationStack {
      RepositoriesView()
        .ignoresSafeArea()
    }
    #elseif canImport(AppKit)
    RepositoriesView()
      .frame(minWidth: 480, minHeight: 600)
    #endif
  }
}

#if canImport(UIKit) && !os(watchOS)
private struct RepositoriesView: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> RepositoriesViewController {
    RepositoriesViewController()
  }
  func updateUIViewController(_ uiViewController: RepositoriesViewController, context: Context) {}
}
#elseif canImport(AppKit)
private struct RepositoriesView: NSViewControllerRepresentable {
  func makeNSViewController(context: Context) -> RepositoriesViewController {
    RepositoriesViewController()
  }
  func updateNSViewController(_ nsViewController: RepositoriesViewController, context: Context) {}
}
#endif

#Preview {
    RootView()
}
