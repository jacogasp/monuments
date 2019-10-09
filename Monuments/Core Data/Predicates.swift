//
//  Predicates.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 08/10/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//

import CoreData
import MapKit

struct Predicates {
    
    static func searchPointsOfInterest(center: CLLocationCoordinate2D, radius: CLLocationDistance) -> NSPredicate {
        let region = MKCoordinateRegion(center: center, latitudinalMeters: radius * 2, longitudinalMeters: radius * 2)
        
        let minLatitude = center.latitude - region.span.latitudeDelta
        let maxLatitude = center.latitude + region.span.latitudeDelta
        let minLongitude = center.longitude - region.span.longitudeDelta
        let maxLongitude = center.longitude + region.span.longitudeDelta
        
        let predicate = NSPredicate(format: "(%@ <= latitude) AND (latitude <= %@)" +
            "AND (%@ <= longitude) AND (longitude <= %@)",
                                    argumentArray: [minLatitude, maxLatitude, minLongitude, maxLongitude])
        
        return predicate
    }
    
    
}

