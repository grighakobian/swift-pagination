import Foundation

/// A service that fetches popular GitHub repositories (stars > 1000).
///
/// Exposes two entry points:
/// - `fetchPopularRepositories(page:)` — Swift-native `async throws`, non-isolated.
/// - `fetchPopularRepositoriesAtPage:completion:` — Obj-C selector whose completion fires on
///   the main queue.
@objcMembers
public final class GitHubService: NSObject, Sendable {
  private let baseURL = URL(string: "https://api.github.com/search/repositories")!
  private let session: URLSession

  /// GitHub caps the search API at 100 results per page; this service requests 30.
  public let pageSize: Int = 30

  public init(session: URLSession = .shared) {
    self.session = session
    super.init()
  }

  public override convenience init() {
    self.init(session: .shared)
  }

  /// Fetches a page of popular repositories sorted by stars.
  /// - Parameter page: 1-indexed page number.
  public func fetchPopularRepositories(page: Int) async throws -> RepositorySearchResponse {
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
    return try JSONDecoder().decode(RepositorySearchResponse.self, from: data)
  }

  /// Obj-C completion-handler overload. The completion fires on the main queue; on success
  /// `error` is `nil`, on failure `response` is `nil`.
  @objc(fetchPopularRepositoriesAtPage:completion:)
  public func fetchPopularRepositories(
    page: Int,
    completion: @escaping @MainActor @Sendable (RepositorySearchResponse?, Error?) -> Void
  ) {
    Task {
      do {
        let response = try await fetchPopularRepositories(page: page)
        await completion(response, nil)
      } catch {
        await completion(nil, error)
      }
    }
  }
}


@objcMembers
public final class Repository: NSObject, Decodable, @unchecked Sendable {
  public let identifier: Int
  public let name: String
  public let fullName: String
  public let repositoryDescription: String?
  public let stargazersCount: Int
  public let language: String?
  public let htmlURL: URL

  public init(
    identifier: Int,
    name: String,
    fullName: String,
    repositoryDescription: String?,
    stargazersCount: Int,
    language: String?,
    htmlURL: URL
  ) {
    self.identifier = identifier
    self.name = name
    self.fullName = fullName
    self.repositoryDescription = repositoryDescription
    self.stargazersCount = stargazersCount
    self.language = language
    self.htmlURL = htmlURL
    super.init()
  }

  private enum CodingKeys: String, CodingKey {
    case identifier = "id"
    case name
    case fullName = "full_name"
    case repositoryDescription = "description"
    case stargazersCount = "stargazers_count"
    case language
    case htmlURL = "html_url"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.identifier = try container.decode(Int.self, forKey: .identifier)
    self.name = try container.decode(String.self, forKey: .name)
    self.fullName = try container.decode(String.self, forKey: .fullName)
    self.repositoryDescription = try container.decodeIfPresent(String.self, forKey: .repositoryDescription)
    self.stargazersCount = try container.decode(Int.self, forKey: .stargazersCount)
    self.language = try container.decodeIfPresent(String.self, forKey: .language)
    self.htmlURL = try container.decode(URL.self, forKey: .htmlURL)
    super.init()
  }

  public override func isEqual(_ object: Any?) -> Bool {
    guard let other = object as? Repository else { return false }
    return identifier == other.identifier
  }

  public override var hash: Int { identifier }
}

// MARK: - RepositorySearchResponse

@objcMembers
public final class RepositorySearchResponse: NSObject, Decodable, @unchecked Sendable {
  public let totalCount: Int
  public let items: [Repository]

  public init(totalCount: Int, items: [Repository]) {
    self.totalCount = totalCount
    self.items = items
    super.init()
  }

  private enum CodingKeys: String, CodingKey {
    case totalCount = "total_count"
    case items
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.totalCount = try container.decode(Int.self, forKey: .totalCount)
    self.items = try container.decode([Repository].self, forKey: .items)
    super.init()
  }
}
