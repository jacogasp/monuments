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
    
    var category: String {
        self.subtitle ?? "unknown_category"
    }
    
    init(id: Int, title: String, subtitle: String?, location: CLLocation, wiki: String?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.location = location
        self.wiki = wiki
        self.coordinate = location.coordinate
    }
}
