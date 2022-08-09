//
//  HTTPError.swift
//  MoscowEvents
//
//  Created by Diana Princess on 03.08.2022.
//

public enum HTTPError: Error{
    case transportError(Error)
    case httpError(Int)
}
