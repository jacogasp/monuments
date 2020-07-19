//
//  Monument+CoreDataProperties.swift
//  
//
//  Created by Jacopo Gasparetto on 07/07/2020.
//
//

import Foundation
import CoreData


extension Monument {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Monument> {
        return NSFetchRequest<Monument>(entityName: "Monument")
    }

    @NSManaged public var category: String
    @NSManaged public var id: UUID
    @NSManaged public var isActive: Bool
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String
    @NSManaged public var wikiUrl: String?
}
