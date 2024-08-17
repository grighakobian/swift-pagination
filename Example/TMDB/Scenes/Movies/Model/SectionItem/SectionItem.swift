//
//  SectionItem.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 09.11.21.
//

import Foundation

enum SectionItem {
    case state(LoadingState)
    case movie(MovieItemViewModel)
}

// MARK: - movie item view model getter

extension SectionItem {
    
    var movieViewModel: MovieItemViewModel? {
        switch self {
        case .movie(let viewModel):
            return viewModel
        default:
            return nil
        }
    }
}
