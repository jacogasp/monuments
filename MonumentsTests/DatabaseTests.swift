//
//  MonumentsTests.swift
//  MonumentsTests
//
//  Created by Jacopo Gasparetto on 18/08/21.
//  Copyright © 2021 Jacopo Gasparetto. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Monuments

class DatabaseTests: XCTestCase {
    let db = DatabaseHandler()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testItalianCategories() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let categories = db.getLocalizedCategories(lang: "it")
        
        XCTAssert(categories[.archaeological_site]?.description == "Sito Archeologico")
        XCTAssert(categories[.archaeological_site]?.descriptionPlural == "Siti Archeologici")
        XCTAssert(categories[.artwork]?.description == "Opera d'Arte")
        XCTAssert(categories[.artwork]?.descriptionPlural == "Opere d'Arte")
        XCTAssert(categories[.castle]?.description == "Castello")
        XCTAssert(categories[.castle]?.descriptionPlural == "Castelli")
        XCTAssert(categories[.fountain]?.description == "Fontana")
        XCTAssert(categories[.fountain]?.descriptionPlural == "Fontane")
        XCTAssert(categories[.memorial]?.description == "Memoriale")
        XCTAssert(categories[.memorial]?.descriptionPlural == "Memoriali")
        XCTAssert(categories[.monument]?.description == "Monumento")
        XCTAssert(categories[.monument]?.descriptionPlural == "Monumenti")
        XCTAssert(categories[.museum]?.description == "Museo")
        XCTAssert(categories[.museum]?.descriptionPlural == "Musei")
        XCTAssert(categories[.place_of_worship]?.description == "Luogo di Preghiera")
        XCTAssert(categories[.place_of_worship]?.descriptionPlural == "Luoghi di Preghiera")
        XCTAssert(categories[.ruins]?.description == "Rovine")
        XCTAssert(categories[.ruins]?.descriptionPlural == "Rovine")
        XCTAssert(categories[.statue]?.description == "Statua")
        XCTAssert(categories[.statue]?.descriptionPlural == "Statue")
        XCTAssert(categories[.theatre]?.description == "Teatro")
        XCTAssert(categories[.theatre]?.descriptionPlural == "Teatri")
        XCTAssert(categories[.tomb]?.description == "Cimitero - Tomba")
        XCTAssert(categories[.tomb]?.descriptionPlural == "Cimiteri - Tombe")
        XCTAssert(categories[.tower]?.description == "Torre")
        XCTAssert(categories[.tower]?.descriptionPlural == "Torri")
        XCTAssert(categories[.villa]?.description == "Villa")
        XCTAssert(categories[.villa]?.descriptionPlural == "Ville")
    }
    
    func testfetchMonumentsAroundLocation() {
        let nettunoOsmID = 7205401086
        let nettunoLocation = CLLocation(latitude: 44.4942646, longitude: 11.3426603)
        let radius:CLLocationDistance = 1000
        
        let monuments = db.fetchMonumentsAroundLocation(location: nettunoLocation, radius: radius)!
        
        XCTAssertEqual(monuments.count, 97)
        XCTAssert(monuments.contains(where: { m in
            return m.id == nettunoOsmID
        }))
        
        let catKeys: [CategoryKey] = [.museum, .tower]
        let categories = catKeys.map{MNCategory(key: $0, description: "", descriptionPlural: "")}
        let monuments2 = db.fetchMonumentsAroundLocation(location: nettunoLocation, radius: radius, categories: categories)!
        
        XCTAssertEqual(monuments2.count, 33)
        XCTAssert(monuments2.contains(where: { m in
            return m.title == "Asinelli"
        }))
        XCTAssert(monuments2.contains(where: { m in
            return m.title == "Garisenda"
        }))
        
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//            let _ = db.getLocalizedCategories(lang: "it")
//        }
//    }

}
