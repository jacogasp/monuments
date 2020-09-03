//
//  DbHandler.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 31/08/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import SQLite3
import UIKit
import MapKit

class DatabaseHandler {
    
    // MARK: - Properties
    
    var db: OpaquePointer?
    
    // MARK: - Init
    init() {
        db = openDatabase()
    }
    
    // MARK: - Helpers
    func openDatabase() -> OpaquePointer? {
        let filePath = Bundle.main.path(forResource: "monuments", ofType: "sqlite")
        
        var db: OpaquePointer? = nil
        
        if sqlite3_open(filePath!, &db) != SQLITE_OK {
            logger.error("Error opening database")
            return nil
        } else {
            logger.verbose("Successfully opened connection to database at \(filePath!)")
            return db
        }
    }
    
    func read(queryStatementString: String) -> [Monument] {
        
        var queryStatement: OpaquePointer? = nil
        var monuments: [Monument] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                /*
                id
                latitude
                longitude
                tags
                name
                wiki
                category
                elevation
                */
                
                let id = sqlite3_column_int(queryStatement, 0)
                let latitude = sqlite3_column_double(queryStatement, 1)
                let longitude = sqlite3_column_double(queryStatement, 2)
                // let tags = sqlite3_column_text(queryStatement, 3)
                let name = String(cString: sqlite3_column_text(queryStatement, 4))
                
                var wiki: String? = nil
                if let cWiki = sqlite3_column_text(queryStatement, 5) {
                    wiki = String(cString: cWiki)
                }
                
                let category = String(cString: sqlite3_column_text(queryStatement, 6))
                let elevation = sqlite3_column_double(queryStatement, 7)
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let location =  CLLocation(coordinate: coordinate, altitude: elevation)
                
                let monument = Monument(
                    id: Int(id), title: name, subtitle: category,
                    location: location, wiki: wiki
                )
                monuments.append(monument)
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            logger.error("Error preparing getting data: \(errmsg)")
        }
        sqlite3_finalize(queryStatement)
        return monuments
    }
    
    func searchPointsOfInterest(region: MKCoordinateRegion) -> [Monument] {
        let minLatitude = region.center.latitude - region.span.latitudeDelta
              let maxLatitude = region.center.latitude + region.span.latitudeDelta
              let minLongitude = region.center.longitude - region.span.longitudeDelta
              let maxLongitude = region.center.longitude + region.span.longitudeDelta
        
        let query = """
        SELECT * FROM monuments
        WHERE latitude BETWEEN \(minLatitude) AND \(maxLatitude)
        AND longitude BETWEEN \(minLongitude) AND \(maxLongitude)
        AND wiki IS NOT NULL
        LIMIT 100
        """
        return self.read(queryStatementString: query)
    }
    
    func fetchMonumentsAroundLocation(location: CLLocation, radius: CLLocationDistance) -> [Monument]? {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius * 2, longitudinalMeters: radius * 2)
        return self.searchPointsOfInterest(region: region)
    }
    
    func fetchMonumentsFor(region: MKCoordinateRegion) -> [Monument]? {
        return self.searchPointsOfInterest(region: region)
    }
}
