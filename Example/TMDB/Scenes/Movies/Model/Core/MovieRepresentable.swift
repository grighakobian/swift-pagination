//
//  MovieRepresentable.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 08.11.21.
//

import Foundation

public protocol MovieRepresentable {
    var id: Int { get } 
    var title: String? { get }
    var posterImageUrl: URL? { get }
    var averageRating: String? { get }
    var overview: String? { get }
}
