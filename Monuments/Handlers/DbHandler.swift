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


    // MARK: - Helpers

    func openDatabase() -> OpaquePointer? {
        let filePath = Bundle.main.path(forResource: "monuments", ofType: "sqlite")

        var db: OpaquePointer? = nil

        if sqlite3_open(filePath!, &db) != SQLITE_OK {
            logger.error("Error opening database")
            sqlite3_close(db)
            db = nil
            return nil
        } else {
            return db
        }
    }

    func closeDatabase() {
        if sqlite3_close(db) != SQLITE_OK {
            logger.error("error closing database")
        }
        db = nil
    }
    
    // MARK: - Monuments Table
    
    func read(queryStatementString: String) -> [Monument] {

        db = openDatabase()

        var queryStatement: OpaquePointer? = nil
        var monuments: [Monument] = []

        // Table columns: id, latitude, longitude, tags, name, wiki, category, elevation
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {

                let id = sqlite3_column_int(queryStatement, 0)
                let name = String(cString: sqlite3_column_text(queryStatement, 1))
                let category = CategoryKey(rawValue: String(cString: sqlite3_column_text(queryStatement, 2))) ?? .unknown
                let longitude = sqlite3_column_double(queryStatement,3)
                let latitude = sqlite3_column_double(queryStatement, 4)
                var wiki: String? = nil

                if let cWiki = sqlite3_column_text(queryStatement, 5) {
                    wiki = String(cString: cWiki)
                }

//                let elevation = sqlite3_column_double(queryStatement, 7)
                let elevation = 0.0
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let location = CLLocation(coordinate: coordinate, altitude: elevation)

                let monument = Monument(
                    id: Int(id), title: name, category: global.categories[category],
                        location: location, wiki: wiki
                )
                monuments.append(monument)
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            logger.error("Error preparing getting data: \(errmsg)")
        }
        sqlite3_finalize(queryStatement)

        queryStatement = nil
        closeDatabase()
        return monuments
    }

    func searchPointsOfInterest(region: MKCoordinateRegion) -> [Monument] {
        let minLatitude = region.center.latitude - region.span.latitudeDelta
        let maxLatitude = region.center.latitude + region.span.latitudeDelta
        let minLongitude = region.center.longitude - region.span.longitudeDelta
        let maxLongitude = region.center.longitude + region.span.longitudeDelta

        let query = """
                    SELECT 
                        osm_id,
                        name,
                        category,
                        longitude,
                        latitude,
                        wiki
                        FROM monuments
                    WHERE latitude BETWEEN \(minLatitude) AND \(maxLatitude)
                    AND longitude BETWEEN \(minLongitude) AND \(maxLongitude)
                    AND wiki IS NOT NULL
                    LIMIT 100
                    """
        return read(queryStatementString: query)
    }

    func fetchMonumentsAroundLocation(location: CLLocation, radius: CLLocationDistance) -> [Monument]? {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius * 2, longitudinalMeters: radius * 2)
        return searchPointsOfInterest(region: region)
    }

    func fetchMonumentsFor(region: MKCoordinateRegion) -> [Monument]? {
        return searchPointsOfInterest(region: region)
    }
    
    
    // MARK: - Categories Table
    func getLocalizedCategories(lang: String?) -> [CategoryKey:MNCategory] {
        db = openDatabase()
        var queryStatement: OpaquePointer? = nil
        var categoriesDict = [CategoryKey:MNCategory]()
        
        let language = (lang != nil) ? lang! : Locale.current.languageCode!
        let query = "SELECT category, \(language), \(language)_pl FROM categories"
        
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let category = CategoryKey(rawValue: String(cString: sqlite3_column_text(queryStatement, 0)))!
                let singular = String(cString: sqlite3_column_text(queryStatement, 1))
                let plural = String(cString: sqlite3_column_text(queryStatement, 2))
                
                categoriesDict[category] = MNCategory(key: category, description: singular, descriptionPlural: plural)
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            logger.error("Error preparing getting data: \(errmsg)")
        }
        sqlite3_finalize(queryStatement)
        
        queryStatement = nil
        closeDatabase()
        global.categories = categoriesDict
        return categoriesDict.isEmpty ? getLocalizedCategories(lang: "en") : categoriesDict
    }
}
