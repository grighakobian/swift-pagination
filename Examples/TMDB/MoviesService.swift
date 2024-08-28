import Foundation

public protocol MoviesService: AnyObject {
  /// Get a list of the current popular movies on TMDB.
  /// - Parameter page: Specify which page to query.
  ///                   Validation: minimum: 1, maximum: 1000, default: 1
  func getPopularMovies(page: Int) async throws -> MoviesResult
}

final class MoviesServiceImpl: MoviesService {
  private let baseURL: URL
  private let apiKey: String
  private let decoder: JSONDecoder
  private let urlSession: URLSession

  public init(urlSession: URLSession = .shared) {
    self.urlSession = urlSession
    self.decoder = JSONDecoder()
    self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    self.apiKey = ProcessInfo.processInfo.environment["API_KEY"]!
    self.baseURL = URL(string: ProcessInfo.processInfo.environment["BASE_URL"]!)!
  }

  public func getPopularMovies(page: Int) async throws -> MoviesResult {
    let url = baseURL.appendingPathComponent("tv/popular")
    var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    urlComponents.queryItems = [
      URLQueryItem(name: "page", value: "\(page)"),
      URLQueryItem(name: "api_key", value: apiKey),
      URLQueryItem(name: "language", value: "en-US"),
      URLQueryItem(name: "sort_by", value: "popularity.desc"),
    ]
    guard let url = urlComponents.url else {
      throw URLError(.badURL)
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.timeoutInterval = 10
    request.allHTTPHeaderFields = ["accept": "application/json"]
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw URLError(.badServerResponse)
    }
    return try decoder.decode(MoviesResult.self, from: data)
  }
}

// MARk: - Models

public struct Movie: Codable {
  public let id: Int?
  public let name: String?
  public let backdropPath: String?
  public let firstAirDate: String?
  public let genreIds: [Int]?
  public let originCountry: [String]?
  public let originalLanguage: String?
  public let originalName: String?
  public let overview: String?
  public let popularity: Double?
  public let posterPath: String?
  public let voteAverage: Double?
  public let voteCount: Int?
}

public struct MoviesResult: Codable {
  public let page: Int?
  public let totalPages: Int?
  public let totalResults: Int?
  public let results: [Movie]?
}
