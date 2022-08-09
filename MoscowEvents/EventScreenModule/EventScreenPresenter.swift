//
//  EventPresenter.swift
//  MoscowEvents
//
//  Created by Diana Princess on 03.08.2022.
//

import Foundation
import UIKit

protocol EventScreenViewProtocol: class {
    func fillData(title: String, description: String, dateStart: Int, dateEnd: Int)
    func requestFailure(error: Error)
    func createImageView(image: UIImage)
    func displayImages()
}

protocol EventScreenPresenterProtocol: class {
    init(view: EventScreenViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol, id: String)
}

class EventScreenPresenter: EventScreenPresenterProtocol {
    weak var view: EventScreenViewProtocol?
    let networkService: NetworkServiceProtocol!
    var router: RouterProtocol?
    var id: String?
    required init(view: EventScreenViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol, id: String) {
        self.view = view
        self.networkService = networkService
        self.router = router
        self.id = id
        
        Task{
            await requestEvent(string: id)
        }
    }
    
    func requestEvent(string: String) async{
        guard let id = string as? String else { return }
        let result = await networkService.requestOneEvent(id: id, secondPart: "/?lang=ru&fields=dates,title,description,body_text,images")
        if case .failure(let error) = result {
            view?.requestFailure(error: error)
        }
        if case .success(let requestResponse) = result{
            for item in requestResponse!.images{
                guard let string = item.image as? String else {return}
                await try? downloadImage(string: string)
            }
            guard let title = requestResponse?.title else { return }
            guard let description = requestResponse?.description else { return }
            guard let startDate = requestResponse?.dates![0].start else { return }
            guard let endDate = requestResponse?.dates![0].end else { return }
            let dates = (startDate, endDate)
            view?.fillData(title: title, description: description, dateStart: startDate, dateEnd: endDate)
            view?.displayImages()
        }
    }
    func downloadImage(string: String) async throws {
        guard let imageUrlString = string as? String else { return }
        let result = await self.networkService.getImage(text: imageUrlString)
        if case .failure(let error) = result {
            guard let errorImg = UIImage(named: "Error") else { return }
            view?.createImageView(image: errorImg)
        }
        if case .success(let data) = result{
            let image = UIImage(data: data!)
            let resizedImage = image?.resizeImage(200, opaque: false)
            let errorImg = UIImage(named: "Error")!
            view?.createImageView(image: resizedImage ?? errorImg)
        }
    }
    
}

