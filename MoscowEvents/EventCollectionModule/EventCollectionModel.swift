//
//  EventCollectionModel.swift
//  MoscowEvents
//
//  Created by Diana Princess on 02.08.2022.
//

import UIKit

struct EventCollectionModel: Codable {
    var count: Int
    var next: String
    var previous: String?
    var results: [OneEventModel]
}
struct OneEventModel: Codable{
    var id: Int
    var title: String
    var thumbnailData: Data?
    var images: [ThumbnailImageModel]
}
struct ThumbnailImageModel: Codable{
    var image: String
    var source: Source
}
struct Source: Codable{
    var name: String
    var link: String
}
