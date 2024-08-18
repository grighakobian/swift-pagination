//
//  SceneDelegate.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 07.11.21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        let moviesService = MoviesServiceImpl()
        let viewController = PopularMoviesViewController(moviesService: moviesService)
        let navigationController = UINavigationController(rootViewController: viewController)
//        navigationController.navigationBar.prefersLargeTitles = true
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
}
