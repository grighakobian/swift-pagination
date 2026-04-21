import SwiftUI

@main
struct CaseStudiesApp: App {
  var body: some Scene {
    WindowGroup {
      RootView()
    }
  }
}

struct RootView: View {
  var body: some View {
    #if canImport(UIKit)
    NavigationStack {
      UIKitCaseStudy()
        .navigationTitle("UIKit — Popular Repositories")
    }
    #elseif canImport(AppKit)
    NavigationStack {
      AppKitCaseStudy()
        .navigationTitle("AppKit — Popular Repositories")
    }
    #endif
  }
}

#Preview {
  RootView()
}
