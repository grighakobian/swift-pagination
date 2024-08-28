import Foundation

struct Movie: Codable {
  let id: Int?
  let name: String?
  let backdropPath: String?
  let firstAirDate: String?
  let genreIds: [Int]?
  let originCountry: [String]?
  let originalLanguage: String?
  let originalName: String?
  let overview: String?
  let popularity: Double?
  let posterPath: String?
  let voteAverage: Double?
  let voteCount: Int?
}

struct MoviesResult: Codable {
  let page: Int?
  let totalPages: Int?
  let totalResults: Int?
  let results: [Movie]?
}

struct MovieViewModel: Hashable {
  let id: Int
  let title: String?
  let posterImageUrl: URL?
  let averageRating: String?
  let overview: String?

  init(movie: Movie) {
    self.id = movie.id ?? 0
    self.title = movie.name ?? ""
    self.overview = movie.overview
    if let voteAverage = movie.voteAverage {
      self.averageRating = String(format: "%.1f", voteAverage)
    } else {
      self.averageRating = nil
    }
    if let posterPath = movie.posterPath {
      let posterPath = "https://image.tmdb.org/t/p/w500/\(posterPath)"
      self.posterImageUrl = URL(string: posterPath)!
    } else {
      self.posterImageUrl = nil
    }
  }
}
