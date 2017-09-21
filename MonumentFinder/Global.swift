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

let defaultColor = UIColor(netHex: 0xB21818)
let defaultFont = UIFont(name: "HelveticaNeue-Thin", size: 17) ?? UIFont.systemFont(ofSize: 17)

var filtri: [Filtro] = []

var selectedCity: String = ""
var savedCity: String = ""

// MARK: Funzioni globali
class Global {

    
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

extension UIButton {
    var titleLabelFont: UIFont! {
        get { return self.titleLabel?.font }
        set { self.titleLabel?.font = newValue}
    }
}

class Theme {
    static func apply() {
        applyToUIButton()
        applyToUINavigationBar()
        // UILabel.appearance().font = UIFont(name: "HelevticaNeue-Light", size: 12)
        // ...
    }
    
    // It can either theme a specific UIButton instance, or defaults to the appearance proxy (prototype object) by default
    static func applyToUIButton(a: UIButton = UIButton.appearance()) {
        a.titleLabelFont = UIFont(name: "HelveticaNeue-Medium", size: 17)
        // other UIButton customizations
    }
    
    static func applyToUINavigationBar(a: UINavigationBar = UINavigationBar.appearance()) {
        if let titleFont = UIFont(name: "HelveticaNeue-Light", size: 17) {
            a.titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): titleFont]
        }
    }
}
