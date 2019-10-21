//
//  MonumentInterface.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 02/10/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//


public struct MonumentInterface: Decodable {
    var name: String
    var latitude: Double
    var longitude: Double
    var category: String
    var wikiUrl: String?
}

public struct MonumentData: Decodable {
    public var monuments: [MonumentInterface]
}
