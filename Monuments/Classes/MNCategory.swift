//
//  MonumentTag.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 02/10/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//

import UIKit

public enum MNCategory: String {
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
    case `default` = "uknown_category"
    
    public init(rawValue: RawValue) {
        switch rawValue {
        case MNCategory.archaelogical_site.rawValue: self = .archaelogical_site
        case MNCategory.artwork.rawValue: self = .artwork
        case MNCategory.cemetery.rawValue: self = .cemetery
        case MNCategory.fountain.rawValue: self = .fountain
        case MNCategory.memorial.rawValue: self = .memorial
        case MNCategory.monument.rawValue: self = .monument
        case MNCategory.museum.rawValue: self = .museum
        case MNCategory.palace.rawValue: self = .palace
        case MNCategory.place_of_worship.rawValue: self = .place_of_worship
        case MNCategory.ruins.rawValue: self = .ruins
        case MNCategory.statue.rawValue: self = .statue
        case MNCategory.theatre.rawValue: self = .theatre
        case MNCategory.villa.rawValue: self = .villa
        default: self = .default
        }
    }
}
