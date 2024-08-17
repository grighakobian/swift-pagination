//
//  ServicesAssembly.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 07.11.21.
//

import Domain
import Foundation
import Swinject
import Networking

public final class ServicesAssembly: Assembly {
    
    public func assemble(container: Container) {
        container.register(NetworkProviderType.self) { resolver in
            let configuration = URLSessionConfiguration.default
            configuration.headers = .default
            configuration.timeoutIntervalForRequest = 30.0
            configuration.timeoutIntervalForResource = 30.0
            return NetworkProvider(configuration: configuration)
        }.inObjectScope(.weak)
        
        container.register(Domain.MoviesService.self) { resolver in
            let networkProvider = resolver.resolve(NetworkProviderType.self)!
            let moyaProvider = networkProvider.provideDefaultNetworkProvider()
            return Networking.MoviesService(moyaProvider: moyaProvider)
        }
    }
}
