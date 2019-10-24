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
    
    static func searchPointsOfInterest(region: MKCoordinateRegion) -> NSPredicate {
        
        let minLatitude = region.center.latitude - region.span.latitudeDelta
        let maxLatitude = region.center.latitude + region.span.latitudeDelta
        let minLongitude = region.center.longitude - region.span.longitudeDelta
        let maxLongitude = region.center.longitude + region.span.longitudeDelta
        
        let predicate = NSPredicate(format: "(%@ <= latitude) AND (latitude <= %@)" +
            "AND (%@ <= longitude) AND (longitude <= %@)",
                                    argumentArray: [minLatitude, maxLatitude, minLongitude, maxLongitude])
        
        return predicate
    }
}

struct FetchRequests {
    
    private static func fetchMonuments(by predicate: NSPredicate) -> [Monument]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not find AppDelegate")
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Monument")
        
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let monuments = try managedContext.fetch(fetchRequest) as! [Monument]
            return monuments
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    /// Fetch monuments within a circular area centered around the location with a given radius
    static func fetchMonumentsAroundLocation(location: CLLocation, radius: CLLocationDistance) -> [Monument]? {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius * 2, longitudinalMeters: radius * 2)
        let predicate = Predicates.searchPointsOfInterest(region: region)
        return self.fetchMonuments(by: predicate)
    }
    
    /// Fetch monuments for a given Region
    static func fetchMonumentsFor(region: MKCoordinateRegion) -> [Monument]? {
        let predicate = Predicates.searchPointsOfInterest(region: region)
        return self.fetchMonuments(by: predicate)
    }
}

