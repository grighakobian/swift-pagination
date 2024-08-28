import Foundation

protocol MoviesService: AnyObject {
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

  init(urlSession: URLSession = .shared) {
    self.urlSession = urlSession
    self.decoder = JSONDecoder()
    self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    self.apiKey = ProcessInfo.processInfo.environment["API_KEY"]!
    self.baseURL = URL(string: ProcessInfo.processInfo.environment["BASE_URL"]!)!
  }

  func getPopularMovies(page: Int) async throws -> MoviesResult {
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
