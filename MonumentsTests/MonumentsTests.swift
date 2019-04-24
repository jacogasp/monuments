//
//  MonumentsTests.swift
//  MonumentsTests
//
//  Created by Jacopo Gasparetto on 19/04/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//

import XCTest
@testable import Monuments

class MonumentsTests: XCTestCase {
   
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEnvironmentConfigurationn() {
      
        let config = EnvironmentConfiguration()
        
        XCTAssertNotNil(config.defaultColor)
        XCTAssertNotNil(config.defaultFont)
        XCTAssertNotNil(config.defaultFontName)
        XCTAssertNotNil(config.maxDistance)
        XCTAssertNotNil(config.maxNumberOfVisibleMonuments)
        XCTAssertNotNil(config.mkRegionSpanMeters)
    }
    
    func testReadFromDatabase() {
        let dataCollection = DataCollection()

        XCTAssertNoThrow(dataCollection.readFromDatabase())
        XCTAssertGreaterThan(quadTree.annotations.count, 0)
        print("Annotation in quadTree: \(quadTree.annotations.count)")
    }
}
