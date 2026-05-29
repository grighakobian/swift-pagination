import Pagination
import SwiftUI

/// A SwiftUI view that lists popular GitHub repositories using the `.pagination` modifier.
///
/// Demonstrates the SwiftUI-native surface of the Pagination library:
/// - `.paginationEnabled(_:)` is bound to `hasMorePages` so the library stops prefetching
///   once the final page has been loaded.
/// - `.pagination(state:action:)` wraps the async fetch and transitions the `state` binding
///   through `.started` → `.completed` / `.failed` automatically.
struct RepositoriesView: View {
  @StateObject private var viewModel = RepositoriesViewModel()
  @State private var state: PaginationState?

  var body: some View {
    List(viewModel.repositories) { item in
      VStack(alignment: .leading, spacing: 4) {
        Text(item.title)
          .font(.headline)
        Text(item.subtitle)
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      .padding(.vertical, 4)
    }
    .overlay {
      if viewModel.repositories.isEmpty, state == .started {
        ProgressView()
      }
    }
    .safeAreaInset(edge: .bottom) {
      if state == .started, !viewModel.repositories.isEmpty {
        ProgressView()
          .padding()
      }
    }
    .paginationDirection(.vertical)
    .paginationLeadingScreens(2.0)
    .paginationEnabled(viewModel.hasMorePages)
    .pagination(state: $state) {
      try await viewModel.fetchNextPage()
    }
  }
}

#Preview("Popular Repositories") {
  NavigationStack {
    RepositoriesView()
      .navigationTitle("Popular Repositories")
  }
}
