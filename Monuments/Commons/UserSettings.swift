//
//  UserSettings.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 09/08/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import Combine

// MARK: - Enviroment

final class Environment: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    @Published var numVisibleMonuments = 0
    @Published var showCounter = false
    
    @UserDefault("MaxVisibleDistance", defaultValue: Constants.DEFAULT_MAX_VISIBILITY)
    var maxDistance: Double {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("ShowOvalMap", defaultValue: Constants.DEFAULT_SHOW_OVALMAP)
    var showOvalMap: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("ActiveCategories", defaultValue: loadCategories())
    var activeCategories: [String: Bool] {
        willSet {
            objectWillChange.send()
        }
    }
    
    
    static func loadCategories() -> [String: Bool] {
        return CategoryKey.allCases.reduce([String: Bool]()) { tempDict, categoryKey in
            var tempDict = tempDict
            tempDict[categoryKey.rawValue] = true
            return tempDict
        }
    }
    
}
