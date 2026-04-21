import SwiftUI

@main
struct SwiftUIExampleApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        RepositoriesView()
          .navigationTitle("Popular Repositories")
          #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
          #endif
      }
    }
    #if os(macOS)
      .windowStyle(.titleBar)
    #endif
  }
}
