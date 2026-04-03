import PlaygroundSupport
import UIKit

let viewController = ColorsViewController()
viewController.title = "Colors"

let navigationController = UINavigationController(rootViewController: viewController)
navigationController.navigationBar.prefersLargeTitles = true
navigationController.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)

PlaygroundPage.current.liveView = navigationController
PlaygroundPage.current.needsIndefiniteExecution = true
