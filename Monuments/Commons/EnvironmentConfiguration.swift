//
//  EnvironmentConfiguration.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 21/04/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import UIKit

final class EnvironmentConfiguration {
    private let config: NSDictionary
    
    init(dictionary: NSDictionary) {
        config = dictionary
    }
    
    convenience init() {
        let bundle = Bundle.main
        let configPath = bundle.path(forResource: "config", ofType: "plist")!
        let config = NSDictionary(contentsOfFile: configPath)!
        
        let dict = NSMutableDictionary()
        if let commonConfig = config["Common"] as? [AnyHashable: Any] {
            dict.addEntries(from: commonConfig)
        }
        
        if let environment = bundle.infoDictionary!["ConfigEnvironment"] as? String {
            if let environmentConfig = config[environment] as? [AnyHashable: Any] {
                dict.addEntries(from: environmentConfig)
            }
        }
        
        self.init(dictionary: dict)
    }
}

extension EnvironmentConfiguration {
    var mkRegionSpanMeters: Double {
        return Double(config["MKRegionSpanMeters"] as! Double)
    }
    
    var maxNumberOfVisibleMonuments: Int {
        return config["MaxNumberOfVisibleMonuments"] as! Int
    }
    
    var maxDistance: Int {
        return config["MaxDistance"] as! Int
    }
    
    var defaultColor: UIColor {
        let hexColor = Int(config["DefaultColor"] as! String, radix: 16)!
        return UIColor(netHex: hexColor)
    }
    
    var defaultFontName: String {
        return config["DefaultFontName"] as! String
    }
    
    var defaultFont: UIFont {
        return UIFont(name: config["DefaultFontName"] as! String, size: 17.0) ?? UIFont.systemFont(ofSize: 17.0)
    }
}
