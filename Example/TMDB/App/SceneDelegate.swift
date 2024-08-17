//
//  SceneDelegate.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 07.11.21.
//

import UIKit
import RxSwift
import RxFlow

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    internal var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        
        let resolver = Dependency.shared.resolver
        let appFlow = resolver.resolve(AppFlow.self)!
        let coordinator = resolver.resolve(FlowCoordinator.self)!
        let stepper = OneStepper(withSingleStep: AppStep.popularMovies)
        coordinator.coordinate(flow: appFlow, with: stepper)
        Flows.use(appFlow, when: .created) { [weak self] viewController in
            self?.window?.rootViewController = viewController
            self?.window?.makeKeyAndVisible()
        }
    }
}

