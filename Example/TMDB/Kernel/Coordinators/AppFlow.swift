//
//  AppFlow.swift
//  TMDB
//
//  Created by Grigor Hakobyan on 07.11.21.
//

import RxFlow
import UIKit

public final class AppFlow {
    
    private let navigationController: UINavigationController
    
    public init() {
        self.navigationController = UINavigationController()
        self.navigationController.navigationBar.prefersLargeTitles = true
    }
}


// MARK: - Flow

extension AppFlow: Flow {
    
    public var root: Presentable {
        return navigationController
    }
    
    public func navigate(to step: Step) -> FlowContributors {
        guard let appStep = step as? AppStep else { return .none }
        let resolver = Dependency.shared.resolver
        switch appStep {
        case .popularMovies:
            let viewController = resolver.resolve(PopularMoviesViewController.self)!
            navigationController.pushViewController(viewController, animated: true)
            return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewController.viewModel))
        case .movieDetail(let movie):
            let viewController = resolver.resolve(MovieDetailViewController.self, argument: movie)!
            navigationController.pushViewController(viewController, animated: true)
            return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewController.viewModel))
        case .pop:
            navigationController.popViewController(animated: true)
            return .none
        }
    }
}
