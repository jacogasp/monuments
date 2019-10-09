//
//  Monument+CoreDataProperties.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 09/10/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation

extension Monument {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Monument> {
        return NSFetchRequest<Monument>(entityName: "Monument")
    }

    @NSManaged public var category: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var wikiUrl: String?
    
    @objc dynamic var location: CLLocation{
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String>{
        let keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case "location":
            return keyPaths.union(Set(["latitude", "longitude"]))
        default:
            return keyPaths
        }
    }
}
