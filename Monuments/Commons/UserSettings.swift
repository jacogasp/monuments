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
    let availableCategories: [CategoryKey:MNCategory]
    
    @Published var numVisibleMonuments = 0
    
    init() {
        // TODO: use real language
        availableCategories = DatabaseHandler().getLocalizedCategories(lang: nil)
    }

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
    
    @UserDefault("ActiveCategories", defaultValue: global.categories)
    var activeCategories: [CategoryKey:MNCategory] {
        willSet {
            objectWillChange.send()
        }
    }

//
//    static func loadCategories() -> [CategoryKey: MNCategory] {
////        CategoryKey.allCases.map({ RightOption(name: $0.rawValue, isSelected: true) })
//        Global.
//        DatabaseHandler().getLocalizedCategories(lang: nil)
//    }
    
}
