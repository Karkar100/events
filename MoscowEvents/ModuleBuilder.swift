//
//  ModuleBuilder.swift
//  MoscowEvents
//
//  Created by Diana Princess on 02.08.2022.
//

import UIKit

protocol ModuleBuilderProtocol {
    func buildEventCollection(router: RouterProtocol) -> UIViewController
    func buildEventScreen(id: String, router: RouterProtocol) -> UIViewController
}
class ModuleBuilder: ModuleBuilderProtocol {
    func buildEventCollection(router: RouterProtocol) -> UIViewController {
        let layout = UICollectionViewFlowLayout()
        let view = EventCollectionViewController(collectionViewLayout: layout)
        let networkService = NetworkService()
        let presenter = EventCollectionPresenter(view: view, networkService: networkService, router: router)
        view.presenter = presenter
        return view
    }
    
    func buildEventScreen(id: String, router: RouterProtocol) -> UIViewController {
        let view = EventScreenViewController()
        let networkService = NetworkService()
        let presenter = EventScreenPresenter(view: view, networkService: networkService, router: router, id: id)
        view.presenter = presenter
        return view
    }
}
