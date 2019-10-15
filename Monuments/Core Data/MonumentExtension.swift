//
//  MonumentExtension.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 09/10/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//

import CoreLocation

extension Monument {
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
