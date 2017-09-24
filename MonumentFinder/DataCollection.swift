//
//  DataCollection.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 10/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import MapKit
import ClusterKit

var quadTree = CKQuadTree()

class Monumento: NSObject, CKAnnotation {
    var cluster: CKCluster?
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let osmtag: String
    var wikiUrl: String?
    
    var categoria: String? {
        for filtro in filtri {
            if osmtag == filtro.osmtag {
                return filtro.categoria
            }
        }
        return nil
    }
    
    var isActive = false
    
    init(title: String, coordinate: CLLocationCoordinate2D, osmtag: String, wikiUrl: String?) {
        self.title = title
        self.coordinate = coordinate
        self.osmtag = osmtag
        self.wikiUrl = wikiUrl
    }
    
    init(title: String, coordinate: CLLocationCoordinate2D, osmtag: String) {
        self.title = title
        self.coordinate = coordinate
        self.osmtag = osmtag
    }

}

struct DataCollection {
    
    func readFromDatabase() {
        
        print("Starting reading database...")
        let startTime = Date()
        
        var title: String?
        var coordinate: CLLocationCoordinate2D
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
                        coordinate = CLLocationCoordinate2D(latitude: Double(components[1])!, longitude: Double(components[2])!)
                        osmtag = components[3]
                        monumento = Monumento(title: title!, coordinate: coordinate, osmtag: osmtag!)
                        monumenti.append(monumento)

                    }
                    if components.count > 4 {
                        title = components[0]
                        coordinate = CLLocationCoordinate2D(latitude: Double(components[1])!, longitude: Double(components[2])!)
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

