import Combine
import Foundation

@MainActor
final class RepositoriesViewModel {
  @Published private(set) var repositories: [RepositoryViewModel] = []
  @Published private(set) var hasMorePages = true
  private(set) var currentPage = 0

  private let service: GitHubService

  init(service: GitHubService = GitHubService()) {
    self.service = service
  }

  /// Fetches the next page and appends it to `repositories`. Subscribers re-render when it changes.
  func fetchNextPage() async throws {
    let nextPage = currentPage + 1
    let response = try await service.fetchPopularRepositories(page: nextPage)
    repositories.append(contentsOf: response.items.map(RepositoryViewModel.init))
    currentPage = nextPage
    hasMorePages = repositories.count < response.totalCount
  }
}

struct RepositoryViewModel: Hashable, Sendable {
  let id: Int
  let title: String
  let subtitle: String

  init(_ repository: Repository) {
    self.id = repository.identifier
    self.title = repository.fullName
    self.subtitle = "★ \(repository.stargazersCount.formatted()) · \(repository.language ?? "—")"
  }
}
