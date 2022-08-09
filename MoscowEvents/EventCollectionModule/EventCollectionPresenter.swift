//
//  EventCollectionPresenter.swift
//  MoscowEvents
//
//  Created by Diana Princess on 02.08.2022.
//

import Foundation
import UIKit

protocol EventCollectionViewProtocol: class {
    func reload()
    func requestFailure(error: Error)
    func noInternet()
    func increaseCollection()
    func countCellWidth()->CGFloat
}

protocol EventCollectionPresenterProtocol: class, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    init(view: EventCollectionViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol)
    func additionalRequest()
    func repeatRequest()
}
class EventCollectionPresenter: NSObject, EventCollectionPresenterProtocol{
    weak var view: EventCollectionViewProtocol?
    let networkService: NetworkServiceProtocol!
    var router: RouterProtocol?
    var eventCollection = EventCollectionModel(count: 0, next: "", previous: "", results: [])
    var thumbnails: [UIImage] = []
    var reuseIdentifier = "EventCell"
    var isWaiting: Bool = true
    required init (view: EventCollectionViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol) {
        self.view = view
        self.networkService = networkService
        self.router = router
        super.init()
        Task{
            await requestEventList(string: "https://kudago.com/public-api/v1.4/events/?lang=ru&location=msk&fields=id,title,images")
        }
    }
    func requestEventList(string: String) async{
        guard let urlString = string as? String else { return }
        let result = await try! self.networkService.requestEventList(urlString: urlString)
        if case .failure(let error) = result {
            if error.localizedDescription == "The operation couldn’t be completed. (MoscowEvents.HTTPError error 0.)" {
                self.view?.noInternet()
            } else{
                self.view?.requestFailure(error: error)
            }
        }
        if case .success(let requestResp) = result{
            let count = requestResp?.results.count ?? 1
            for i in 0...count-1{
                await try? self.downloadThumbnail(string: (requestResp?.results[i].images[0].image)!)
                eventCollection.results.append((requestResp?.results[i])!)
            }
            eventCollection.next = requestResp?.next ?? ""
            self.view?.reload()
            self.isWaiting = false
        }
    }
    func downloadThumbnail(string: String) async throws {
        guard let imageUrlString = string as? String else {
            let imageUrlString = "https://icon-library.com/images/no-image-available-icon/no-image-available-icon-7.jpg"
            return}
        let result = await self.networkService.getImage(text: imageUrlString)
        if case .failure(let error) = result {
            guard let errorImg = UIImage(named: "Error") else { return }
            thumbnails.append(errorImg)
        }
        if case .success(let data) = result{
            let image = UIImage(data: data!)
            let squareImg = image?.squareImage((view?.countCellWidth())!, opaque: false)
            let errorImg = UIImage(named: "Error")!
            thumbnails.append(squareImg ?? errorImg)
        }
    }
    
    func openEventScreen(string: String){
        router?.openEvent(id: string)
    }

    func additionalRequest() {
        Task{
            await requestEventList(string: eventCollection.next)
        }
    }
    
    func repeatRequest() {
        Task{
            await requestEventList(string: "https://kudago.com/public-api/v1.4/events/?lang=ru&location=msk&fields=id,title,images")
        }
    }
}
extension EventCollectionPresenter: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var sum = eventCollection.results.count
        return sum
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCollectionViewCell.reuseId, for: indexPath) as! EventCollectionViewCell
        let title = eventCollection.results[indexPath.row].title ?? "Название мероприятия отсутствует"
        let errorImage = UIImage(named: "Error")
        let image = thumbnails[indexPath.row]
        cell.configure(title: title, image: image)
        return cell
    }
    
}
extension EventCollectionPresenter: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let string = String((eventCollection.results[indexPath.row].id)) as? String else { return }
        openEventScreen(string: string)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.eventCollection.results.count-1 && !isWaiting{
            isWaiting = true
            view?.increaseCollection()
        }
    }
}
extension EventCollectionPresenter: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view?.countCellWidth()
        return CGSize(width: width ?? 150, height: width ?? 150)
        }
}
