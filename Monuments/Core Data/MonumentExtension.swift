//
//  MonumentExtension.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 09/10/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//

import MapKit

extension Monument: MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var title: String? {
        return name
    }
    
    public var subtitle: String? {
        return String.localizedStringWithCounts(category, 1)
    }
    
    public var wikiUrls: [String: String]? {
        if let wikiUrl = wikiUrl?.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: wikiUrl, options: []) as? [String:String]
            } catch {
                print(error)
            }
        }
        return nil
    }
    
    @objc dynamic var location: CLLocation{
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
    // FIXME: It is necessary?
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
