//
//  DataCollection.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 10/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import MapKit
import SwiftyJSON

class Monument: NSObject, NSCoding {

    let lat: String
    let lon: String
    let tags: [String: String]
    var isVisible: Bool
    
    var categoria: String? {
        var categorie: [Filtro] = []
        
        for tag in tags {
            for filtro in filtri {
                if tag.value == filtro.osmtag {
                    categorie.append(filtro)
                }
            }
        }
        categorie.sort(by: {$0.peso < $1.peso})

        return categorie.first?.categoria ?? nil
    }
    
    init(lat: String, lon: String, tags: [String: String]) {

        self.lat = lat
        self.lon = lon
        self.tags = tags
        self.isVisible = false
    }
    
    // MARK: NSCoding
    internal required init?(coder decoder: NSCoder) {
 
        self.lat = decoder.decodeObject(forKey: "lat") as! String
        self.lon = decoder.decodeObject(forKey: "lon") as! String
        self.tags = decoder.decodeObject(forKey: "tags") as! [String: String]
        self.isVisible = decoder.decodeBool(forKey: "isVisibile")

    }
    func encode(with coder: NSCoder) {
        coder.encode(self.lat, forKey: "lat")
        coder.encode(self.lon, forKey: "lon")
        coder.encode(self.tags, forKey: "tags")
        coder.encode(self.isVisible, forKey: "isVisible")
    }
}

class MonumentiClass {
    static let monumentiClass = MonumentiClass()
    
    var monumenti = [Monument]()
    
    func jsonToMonuments() {
        if let path = Bundle.main.path(forResource: fileMonumenti, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let json = JSON(data: data)
                if json != JSON.null {
                    for i in 0..<json["elements"].count {
                        var lat: String = ""
                        var lon: String = ""
                        if json["elements",i,"center"].exists() {
                             lat = json["elements",i,"center","lat"].stringValue
                             lon = json["elements",i,"center","lon"].stringValue
                        } else {
                            lat = json["elements",i,"lat"].stringValue
                            lon = json["elements",i,"lon"].stringValue
                        }
                        
                        let tagsJson = json["elements",i,"tags"].dictionaryValue
                        var tags: [String: String] = [String: String]()
                        
                        for element in tagsJson {
                            tags[element.key] = element.value.stringValue
                        }

                        let monumento = Monument(lat: lat, lon: lon, tags: tags)
                        monumenti.append(monumento)
                    }
                    
                    let monumentiZip = NSKeyedArchiver.archivedData(withRootObject: monumenti)
                    let defaults = UserDefaults.standard
                    defaults.set(monumentiZip, forKey: "monumentiZip")
                    print("Scrittura dul disco terminata.")
                
                } else {
                    print("Could not get json from file, make sure that file contains valid json.")
                }
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
//        for monumento in monumenti {
//            print("\(monumento.tags["name"] ?? "no name"): \(monumento.categoria ?? "MISSING")")
//        }
    }
    
    
}

