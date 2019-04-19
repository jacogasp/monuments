//
//  DataCollection.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 10/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import CoreLocation
import ClusterKit

var quadTree = CKQuadTree()

class MNMonument: NSObject, MKAnnotation {
    var cluster: CKCluster?
    let title: String?
	var subtitle: String? {
		for category in global.categories where osmtag == category.osmtag {
			return category.description
		}
		return nil
	}

    let coordinate: CLLocationCoordinate2D
    var altitude: CLLocationDistance?
    let osmtag: String
    var wikiUrl: String?
    var distanceFromUser = 0.0
    var isActive = false
    
    var location: CLLocation {
		guard let altitude = altitude else {
			return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		}
//        return CLLocation(coordinate: coordinate, altitude: altitude)
        return CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: .distantPast)
    }
    
    init(title: String, coordinate: CLLocationCoordinate2D, osmtag: String, wikiUrl: String?) {
        self.title = title
        self.osmtag = osmtag
        self.wikiUrl = wikiUrl
        self.coordinate = coordinate
        super.init()
    }
    
    init(title: String, location: CLLocation, osmtag: String) {
        self.title = title
        self.osmtag = osmtag
        self.coordinate = location.coordinate
        super.init()
    }
}

struct DataCollection {
    func readFromDatabase() {
        print("Starting reading database...")
        let startTime = Date()
        
        var title: String?
        var location: CLLocation
        var osmtag: String?
        var wikiUrl: String?
        
        var monuments = [MNMonument]()
        
        if let url = Bundle.main.url(forResource: "Monuments", withExtension: "csv") {
            do {
                let data = try String(contentsOf: url, encoding: String.Encoding.utf8)
                let lines = data.components(separatedBy: "\n")
                
                for line in lines {
                    let components = line.components(separatedBy: ";")
                    var monument: MNMonument
                    if components.count == 4 {
                        title = components[0]
                        let altitude = 0.0
                        let coordinate = CLLocationCoordinate2D(latitude: Double(components[1])!,
																longitude: Double(components[2])!)
//                        location = CLLocation(coordinate: coordinate, altitude: altitude)
                        location = CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: .distantPast)
                        osmtag = components[3]
                        monument = MNMonument(title: title!, location: location, osmtag: osmtag!)
                        monuments.append(monument)

                    }
                    if components.count > 4 {
                        title = components[0]
                        let coordinate = CLLocationCoordinate2D(latitude: Double(components[1])!,
																longitude: Double(components[2])!)
                        osmtag = components[3]
                        wikiUrl = components[4]
                        monument = MNMonument(title: title!, coordinate: coordinate, osmtag: osmtag!, wikiUrl: wikiUrl)
                        monuments.append(monument)

                    }
                }
                let endTime = Date()
                let elapsedTime = round(endTime.timeIntervalSince(startTime) * 100) / 100
                quadTree = CKQuadTree(annotations: monuments)
                print("\(monuments.count) entries succesfully read and quadTree set in \(elapsedTime) seconds.\n")
            } catch {
                print("ERROR: Unable to read monuments database.")
            }
        } else {
            print("ERROR: Mounuments database not found.")
        }
        
    } // End readFromDatabase()
    
} // End MonumentiClass
