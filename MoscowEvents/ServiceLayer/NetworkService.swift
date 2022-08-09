//
//  NetworkService.swift
//  MoscowEvents
//
//  Created by Diana Princess on 02.08.2022.
//

import Foundation
import UIKit
protocol NetworkServiceProtocol {
    func requestEventList(urlString: String) async -> Result<EventCollectionModel?, HTTPError>
    func getImage(text: String) async -> Result<Data?, Error>
    func requestOneEvent(id: String, secondPart: String) async -> Result<EventModel?, Error>
}
class NetworkService: NetworkServiceProtocol {
    func requestEventList(urlString: String) async -> Result<EventCollectionModel?, HTTPError> {
        await withCheckedContinuation{ continuation in
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request){ data, response, error in
            if let error = error {
                continuation.resume(returning: .failure(HTTPError.transportError(error)))
                return
            }
            let resp = response as! HTTPURLResponse
            let status = resp.statusCode
            guard (200...299).contains(status) else {
                continuation.resume(returning: .failure(HTTPError.httpError(status)))
                return
            }
            let correctResponse: EventCollectionModel? = try? JSONDecoder().decode(EventCollectionModel.self, from: data!)
            continuation.resume(returning: .success(correctResponse))
        }.resume()
        }
    }
    
    func getImage(text: String) async -> Result<Data?, Error>{
        await withCheckedContinuation{ continuation in
            guard let photoUrl = URL(string: text) else { return }
            let request = URLRequest(url: photoUrl)
            URLSession.shared.dataTask(with: request){ data, response, error in
                if let error = error {
                    continuation.resume(returning: .failure(HTTPError.transportError(error)))
                    return
                }
                let resp = response as! HTTPURLResponse
                let status = resp.statusCode
                guard (200...299).contains(status) else {
                    continuation.resume(returning: .failure(HTTPError.httpError(status)))
                    return
                }
                continuation.resume(returning: .success(data))
            }.resume()
        }
    }
    
    func requestOneEvent(id: String, secondPart: String) async -> Result<EventModel?, Error>{
        await withCheckedContinuation{ continuation in
        let urlString = "https://kudago.com/public-api/v1.4/events/"+id+secondPart
        print(urlString)
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request){ data, response, error in
            if let error = error {
                continuation.resume(returning: .failure(HTTPError.transportError(error)))
                return
            }
            let resp = response as! HTTPURLResponse
            let status = resp.statusCode
            guard (200...299).contains(status) else {
                continuation.resume(returning: .failure(HTTPError.httpError(status)))
                return
            }
            let correctResponse: EventModel? = try? JSONDecoder().decode(EventModel.self, from: data!)
            continuation.resume(returning: .success(correctResponse))
        }.resume()
        }
    }
}
