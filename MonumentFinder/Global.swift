//
//  Global.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 29/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import UIKit

// MARK: Variabili globali
var monumenti: [Monument] = []
let defaultColor = UIColor(netHex: 0xB21818)
var filtri: [Filtro] = []

// MARK: Funzioni globali
class Global {
    func checkWhoIsVisible() {
        let filtriAttivi = filtri.filter{$0.selected}.map{$0.osmtag}
        print("Filtri attivi: \(filtriAttivi)")
        
        for monumento in monumenti {
            monumento.isVisible = false
            let tags = monumento.tags
            for filtro in filtriAttivi {
                if tags.containsValue(value: filtro) {
                    monumento.isVisible = true
                }
            }
        }
    }
}

// MARK: Extensions globali

extension Dictionary where Value: Equatable {
    func containsValue(value : Value) -> Bool {
        return self.contains { $0.1 == value }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

