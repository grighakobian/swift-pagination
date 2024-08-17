//
//  Dependency.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 07.11.21.
//

import Swinject

public final class Dependency {
    
    private let assembler: Assembler
    
    private init() {
        let servicesAssembly = ServicesAssembly()
        let viewModelsAssembly = ViewModelsAssembly()
        let viewControllersAssembly = ViewControllersAssembly()
        let coordinatorsAssembly = CoordinatorsAssembly()
        
        let assemblies: [Assembly] = [
            servicesAssembly,
            viewModelsAssembly,
            viewControllersAssembly,
            coordinatorsAssembly
        ]
        
        self.assembler = Assembler(assemblies)
    }
    
    public var resolver: Resolver {
        return assembler.resolver
    }
    
    // MARK: Shared instance
    
    static var shared: Dependency = {
        return Dependency()
    }()
}

