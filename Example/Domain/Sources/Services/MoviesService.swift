//
//  MoviesService.swift
//  Domain
//
//  Created by Grigor Hakobyan on 07.11.21.
//

import RxSwift

public protocol MoviesService: AnyObject {
    
    /// Get a list of the current popular movies on TMDB.
    /// - Parameter page: Specify which page to query.
    ///                   Validation: minimum: 1, maximum: 1000, default: 1
    func getPopularMovies(page: Int)->Single<MoviesResult>
    
    /// Get a list of similar TV shows. These items are assembled by looking at keywords and genres.
    /// - Parameter id: The id of target tv show.
    func getSimilarMovies(id: Int, page: Int)->Single<MoviesResult>
}
