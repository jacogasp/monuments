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
    var description: String
    var descriptionPlural: String
    
    var isSelected = false
    
    var mapIcon: UIImage {
        switch key {
        case .archaeological_site:
            return UIImage(named: "MapArchaeologicalSite")!
        case .artwork:
            return UIImage(named: "MapArtwork")!
        case .castle:
            return UIImage(systemName: "questionmark")!
//        case .cemetery:
//            return UIImage(named: "MapCemetery")!
        case .fountain:
            return UIImage(named: "MapFountain")!
        case .memorial:
            return UIImage(named: "MapMemorial")!
        case .monument:
            return UIImage(named: "MapMonument")!
        case .museum:
            return UIImage(named: "MapMuseum")!
        case .palace:
            return UIImage(named: "MapPalace")!
        case .place_of_worship:
            return UIImage(named: "MapPlaceOfWorship")!
        case .ruins:
            return UIImage(named: "MapArchaeologicalSite")!
        case .statue:
            return UIImage(named: "MapStatue")!
        case .theatre:
            return UIImage(named: "MapTheatre")!
        case .tomb:
            return UIImage(named: "MapCemetery")!
        case .tower:
            return UIImage(systemName: "questionmark")!
        case .villa:
            return UIImage(named: "MapVilla")!
        case .unknown:
            return UIImage(systemName: "questionmark")!
        }
    }
}

public enum CategoryKey: String, CaseIterable {
    case archaeological_site = "archaeological_site"
    case artwork = "artwork"
    // case cemetery = "cemetery"
    case castle = "castle"
    case fountain = "fountain"
    case memorial = "memorial"
    case monument = "monument"
    case museum = "museum"
    case palace = "palace"
    case place_of_worship = "place_of_worship"
    case ruins = "ruins"
    case statue = "statue"
    case theatre = "theatre"
    case tomb = "tomb"
    case tower = "tower"
    case villa = "villa"
    case unknown = "unknown"
}
