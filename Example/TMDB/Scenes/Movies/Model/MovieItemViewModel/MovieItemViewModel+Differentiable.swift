//
//  MovieItemViewModel- Differentiable.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 10.11.21.
//

import DifferenceKit


extension MovieItemViewModel: Differentiable {
    
    typealias DifferenceIdentifier = String
    
    var differenceIdentifier: String {
        return id.description
    }
    
    func isContentEqual(to source: MovieItemViewModel) -> Bool {
        return self.id == source.id &&
            self.title == source.title &&
            self.posterImageUrl == source.posterImageUrl &&
            self.averageRating == source.averageRating
    }
}
