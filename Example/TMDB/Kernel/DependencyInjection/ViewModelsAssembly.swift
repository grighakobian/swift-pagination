//
//  ViewModelsAssembly.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 07.11.21.
//

import Domain
import Swinject

public final class ViewModelsAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        container.register(PopularMoviesViewModel.self) { resolver in
            let moviesService = resolver.resolve(Domain.MoviesService.self)!
            return PopularMoviesViewModel(moviesService: moviesService)
        }

        container.register(MovieDetailViewModel.self) { (resolver: Resolver, movie: MovieRepresentable) in
            let moviesService = resolver.resolve(Domain.MoviesService.self)!
            return MovieDetailViewModel(movie: movie, moviesSevice: moviesService)
        }
    }
}

