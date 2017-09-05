//
//  DataCollection.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 10/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import MapKit
import SQLite

class Monumento {
    
    let nome: String
    let lat: Double
    let lon: Double
    var osmtag: String
    var isActive: Bool
    var hasWiki: Bool
    
    var categoria: String? {
        for filtro in filtri {
            if osmtag == filtro.osmtag {
                return filtro.categoria
            }
        }
        return nil
    }
    
    init(nome: String, lat: Double, lon: Double, osmtag: String, hasWiki: Bool) {

        self.nome = nome
        self.lat = lat
        self.lon = lon
        self.osmtag = osmtag
        self.isActive = false
        self.hasWiki = hasWiki
    }
}

class MonumentiClass {
    static let monumentiClass = MonumentiClass()
    
    //var monumenti = [Monumento]()
    
    func leggiDatabase(city: String) {
        
        let table = Table(city)
        let nomeSQL = Expression<String>("nome")
        let latSQL = Expression<Double>("lat")
        let lonSQL = Expression<Double>("lon")
        let categoriaSQL = Expression<String>("tag")
        let wikiSQL = Expression<String>("wiki")
        
        
        if let path = Bundle.main.path(forResource: "db", ofType: "sqlite") {
            do {
                let db = try Connection(path)
                print("Succesfully connected to the sql database.")
                for monumento in try db.prepare(table) {
                    let nome = monumento[nomeSQL]
                    let lat = monumento[latSQL]
                    let lon = monumento[lonSQL]
                    let osmtag = monumento[categoriaSQL]
                    
                    var hasWiki = false
                    if !(monumento[wikiSQL].isEmpty) {
                        hasWiki = true
                    }
                    
                    let monumento = Monumento(nome: nome, lat: lat, lon: lon, osmtag: osmtag, hasWiki: hasWiki)
                    monumenti.append(monumento)
                    
                }
            } catch {
                print("Errore nel connettersi al database: \(error)")
            }
            print("Monuments with wikipedia link: \(monumenti.filter{$0.hasWiki}.count)\n")
        }
        
        
    } // End leggiDatabase()
    
} // End MonumentiClass

