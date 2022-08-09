//
//  Router.swift
//  MoscowEvents
//
//  Created by Diana Princess on 02.08.2022.
//

import Foundation
import UIKit

protocol RouterBasic {
    var navigationController: UINavigationController? { get set }
    var moduleBuilder: ModuleBuilderProtocol? { get set }
}

protocol RouterProtocol: RouterBasic {
    func initialViewController () async
    func openEvent(id: String)
    func popToRoot()
}
class Router: RouterProtocol {
    var navigationController: UINavigationController?
    var moduleBuilder: ModuleBuilderProtocol?
    init(navigationController: UINavigationController, moduleBuilder: ModuleBuilderProtocol) {
        self.navigationController = navigationController
        self.moduleBuilder = moduleBuilder
    }
    func initialViewController() {
        if let navigationController = navigationController {
            guard let eventCollectionViewController = moduleBuilder?.buildEventCollection(router: self) else { return }
            navigationController.viewControllers = [eventCollectionViewController]
        }
    }
    
    func openEvent(id: String) {
        if let navigationController = navigationController {
            guard let eventScreenViewController = moduleBuilder?.buildEventScreen(id: id, router: self) else { return }
            navigationController.pushViewController(eventScreenViewController, animated: true)
        }
    }
    
    func popToRoot() {
        if let navigationController = navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
}
