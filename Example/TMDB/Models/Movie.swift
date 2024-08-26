//
//  Movie.swift
//  Domain
//
//  Created by Grigor Hakobyan on 07.11.21.
//

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
