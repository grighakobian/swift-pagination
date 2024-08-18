//
//  PopularMovies.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 09.11.21.
//

import Foundation
import UIKit

enum PopularMovies {
    
    struct ViewModel: Hashable {
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
    
    enum Section: Hashable {
        case main
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ViewModel>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, ViewModel>
}
