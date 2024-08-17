//
//  CoordinatorsAssembly.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 09.11.21.
//

import Swinject
import RxFlow

public final class CoordinatorsAssembly: Assembly {
    
    public func assemble(container: Container) {
        container.register(AppFlow.self) { resolver in
            return AppFlow()
        }
        
        container.register(FlowCoordinator.self) { resolver in
            return FlowCoordinator()
        }.inObjectScope(.container)
    }
}
