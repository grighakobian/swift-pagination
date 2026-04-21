import Foundation

/// A GitHub repository model.
struct Repository: Decodable, Hashable, Identifiable, Sendable {
  let id: Int
  let name: String
  let fullName: String
  let description: String?
  let stargazersCount: Int
  let language: String?
  let htmlURL: URL

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case fullName = "full_name"
    case description
    case stargazersCount = "stargazers_count"
    case language
    case htmlURL = "html_url"
  }
}

/// Envelope for GitHub's repository search response.
struct RepositorySearchResponse: Decodable {
  let totalCount: Int
  let items: [Repository]

  enum CodingKeys: String, CodingKey {
    case totalCount = "total_count"
    case items
  }
}
