//
//  Monument.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 03/09/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import MapKit.MKAnnotation

class Monument: NSObject, MKAnnotation, Identifiable {
    var id: Int
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var category: MNCategory?
    var location: CLLocation
    var isActive = false
    
    private var wiki: String?
    
    var wikiUrl: [String:String]? {
        if let wiki = self.wiki?.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: wiki, options: []) as? [String:String]
            } catch {
                logger.error(error.localizedDescription + " - \(self.wiki!)")
            }
        }
        return nil
    }
    
    var name: String {
        title ?? "unknown_name"
    }
    
    
    init(id: Int, title: String, category: MNCategory?, location: CLLocation, wiki: String?) {
        self.id = id
        self.title = title
        self.category = category
        self.subtitle = category?.description
        self.location = location
        self.wiki = wiki
        self.coordinate = location.coordinate
    }
}
