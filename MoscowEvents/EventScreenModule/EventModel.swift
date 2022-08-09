//
//  EventModel.swift
//  MoscowEvents
//
//  Created by Diana Princess on 04.08.2022.
//

import UIKit

struct EventModel: Codable {
    var dates: [EventDate]?
    var title: String
    var description: String
    var images: [ImageModel]
}

struct EventDate: Codable {
    var start: Int?
    var end: Int?
}

struct ImageModel: Codable {
    var image: String
    var source: ImageSource
}
struct ImageSource: Codable {
    var name: String
    var link: String
}
