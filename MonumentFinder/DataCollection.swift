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

class Monumento: NSObject, MKAnnotation {
    var cluster: CKCluster?
    
    let title: String?
	lazy var subtitle: String? = categoria
	var categoria: String? {
		for filtro in filtri where osmtag == filtro.osmtag {
			return filtro.categoria
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
		return CLLocation(coordinate: coordinate, altitude: altitude)
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
    
//    var isActive: Bool {
//        let activeFilters = filtri.filter {$0.selected}.map {$0.osmtag}
//        // TODO: could be better?
//        for filter in activeFilters where osmtag == filter {
//            return true
//        }
//        return false
//    }
//
//    func checkIfIsActive() {
//
//        let activeFilters = filtri.filter{$0.selected}.map{$0.osmtag}
//        print("\(title) \(osmtag)")
//        for filter in activeFilters {
//            self.isActive = (osmtag == filter) ? true : false
//        }
//    }

}

struct DataCollection {
    
    func readFromDatabase() {
        
        print("Starting reading database...")
        let startTime = Date()
        
        var title: String?
        var location: CLLocation
        var osmtag: String?
        var wikiUrl: String?
        
        var monumenti = [Monumento]()
        
        if let url = Bundle.main.url(forResource: "Monuments", withExtension: "csv") {
            do {
                let data = try String(contentsOf: url, encoding: String.Encoding.utf8)
                let lines = data.components(separatedBy: "\n")
                
                for line in lines {
                    let components = line.components(separatedBy: ";")
                    var monumento: Monumento
                    if components.count == 4 {
                        title = components[0]
                        let altitude = 0.0
                        let coordinate = CLLocationCoordinate2D(latitude: Double(components[1])!,
																longitude: Double(components[2])!)
                        location = CLLocation(coordinate: coordinate, altitude: altitude)
                        osmtag = components[3]
                        monumento = Monumento(title: title!, location: location, osmtag: osmtag!)
                        monumenti.append(monumento)

                    }
                    if components.count > 4 {
                        title = components[0]
                        let coordinate = CLLocationCoordinate2D(latitude: Double(components[1])!,
																longitude: Double(components[2])!)
                        osmtag = components[3]
                        wikiUrl = components[4]
                        monumento = Monumento(title: title!, coordinate: coordinate, osmtag: osmtag!, wikiUrl: wikiUrl)
                        monumenti.append(monumento)

                    }
                }
                let endTime = Date()
                let elapsedTime = round(endTime.timeIntervalSince(startTime) * 100) / 100
                quadTree = CKQuadTree(annotations: monumenti)
                print("\(monumenti.count) entries succesfully read and quadTree set in \(elapsedTime) seconds.\n")
            } catch {
                print("ERROR: Unable to read monuments database.")
            }
        } else {
            print("ERROR: Mounuments database not found.")
        }
        
    } // End readFromDatabase()
    
} // End MonumentiClass
