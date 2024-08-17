//
//  AppStep.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 07.11.21.
//

import Domain
import RxFlow

public enum AppStep: Step {
    case popularMovies
    case movieDetail(MovieRepresentable)
    case pop
}

