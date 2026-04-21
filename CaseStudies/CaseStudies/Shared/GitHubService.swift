import Foundation

/// A service that fetches popular GitHub repositories (stars > 1000).
public final class GitHubService: Sendable {
  private let baseURL = URL(string: "https://api.github.com/search/repositories")!
  private let session: URLSession

  /// GitHub caps the search API at 100 results per page.
  public let pageSize: Int = 30

  public init(session: URLSession = .shared) {
    self.session = session
  }

  /// Fetches a page of popular repositories sorted by stars.
  /// - Parameter page: 1-indexed page number.
  /// - Returns: A `RepositorySearchResponse` containing the page of results.
  func fetchPopularRepositories(page: Int) async throws -> RepositorySearchResponse {
    var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
    components.queryItems = [
      URLQueryItem(name: "q", value: "stars:>1000"),
      URLQueryItem(name: "sort", value: "stars"),
      URLQueryItem(name: "order", value: "desc"),
      URLQueryItem(name: "per_page", value: "\(pageSize)"),
      URLQueryItem(name: "page", value: "\(page)"),
    ]

    var request = URLRequest(url: components.url!)
    request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
    request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

    let (data, _) = try await session.data(for: request)
    let decoder = JSONDecoder()
    return try decoder.decode(RepositorySearchResponse.self, from: data)
  }
}

/// A sample response with static data for previews.
extension RepositorySearchResponse {
  static let preview = RepositorySearchResponse(
    totalCount: 3,
    items: [
      Repository(
        id: 1,
        name: "swift",
        fullName: "apple/swift",
        description: "The Swift Programming Language",
        stargazersCount: 68_000,
        language: "C++",
        htmlURL: URL(string: "https://github.com/apple/swift")!),
      Repository(
        id: 2,
        name: "swift-pagination",
        fullName: "grighakobian/swift-pagination",
        description: "A flexible pagination framework.",
        stargazersCount: 1_200,
        language: "Swift",
        htmlURL: URL(string: "https://github.com/grighakobian/swift-pagination")!),
      Repository(
        id: 3,
        name: "SwiftUI",
        fullName: "apple/SwiftUI",
        description: "Declarative UI framework.",
        stargazersCount: 50_000,
        language: "Swift",
        htmlURL: URL(string: "https://github.com/apple/SwiftUI")!),
    ])
}
