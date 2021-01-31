//
//  UserSettings.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 09/08/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import Combine

// MARK: - Environment

final class Environment: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    @Published var numVisibleMonuments = 0

    var showVisibleMonumentsCounter: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }

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
    var activeCategories: [RightOption] {
        willSet {
            objectWillChange.send()
        }
    }
    
    
    static func loadCategories() -> [RightOption] {
        CategoryKey.allCases.map({ RightOption(name: $0.rawValue, isSelected: true) })
    }
    
}
