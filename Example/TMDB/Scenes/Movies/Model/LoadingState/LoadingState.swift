//
//  LoadingState.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 09.11.21.
//

import Foundation

enum LoadingState {
    case loading
    case failed(with: Error)
}
