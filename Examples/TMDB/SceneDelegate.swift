import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {

    guard let windowScene = (scene as? UIWindowScene) else { return }
    self.window = UIWindow(windowScene: windowScene)
    let moviesService = MoviesServiceImpl()
    let popularMoviesViewController = MoviesViewController(moviesService: moviesService)
    popularMoviesViewController.title = "TMDB"
    let navigationController = UINavigationController(
      rootViewController: popularMoviesViewController)
    navigationController.navigationBar.prefersLargeTitles = true
    self.window?.rootViewController = navigationController
    self.window?.makeKeyAndVisible()
  }
}
