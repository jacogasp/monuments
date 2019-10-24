//
//  MonumentTag.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 02/10/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//

import UIKit

struct MNCategory {
    var key: CategoryKey
    var isSelected = false
}

public enum CategoryKey: String, CaseIterable {
    case archaelogical_site = "archaeological_site"
    case artwork = "artwork"
    case cemetery = "cemetery"
    case fountain = "fountain"
    case memorial = "memorial"
    case monument = "monument"
    case museum = "museum"
    case palace = "palace"
    case place_of_worship = "place_of_worship"
    case ruins = "ruins"
    case statue = "statue"
    case theatre = "theatre"
    case villa = "villa"
//    case `default` = "unkown_category"
//
//    public init(rawValue: RawValue) {
//        switch rawValue {
//        case CategoryKey.archaelogical_site.rawValue: self = .archaelogical_site
//        case CategoryKey.artwork.rawValue: self = .artwork
//        case CategoryKey.cemetery.rawValue: self = .cemetery
//        case CategoryKey.fountain.rawValue: self = .fountain
//        case CategoryKey.memorial.rawValue: self = .memorial
//        case CategoryKey.monument.rawValue: self = .monument
//        case CategoryKey.museum.rawValue: self = .museum
//        case CategoryKey.palace.rawValue: self = .palace
//        case CategoryKey.place_of_worship.rawValue: self = .place_of_worship
//        case CategoryKey.ruins.rawValue: self = .ruins
//        case CategoryKey.statue.rawValue: self = .statue
//        case CategoryKey.theatre.rawValue: self = .theatre
//        case CategoryKey.villa.rawValue: self = .villa
//        default: self = .default
//        }
//    }
}
