//
//  Constants.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 29/07/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Enviroment

class Environment: ObservableObject {
    @Published var numVisibleMonuments = 0
    @Published var maxVisibleDistance = 1
    @Published var showOvalMap = false
    @Published var showCounter = false
    @Published var activeFilters = []
}

// MARK: - General constants

struct Constants {
    static let drawerItemIconSize: CGFloat = 25
    static let MAX_NUM_VISIBLE_POIS = 25
    static let MAX_VISIBILITY_STEPS = [100, 250, 500, 1000, 5000]  // Meters
}

// MARK: - Colors

extension Color {
    static let primary = Color(#colorLiteral(red: 0.7994838357, green: 0.2183310688, blue: 0.165236026, alpha: 1))
    static let secondary = Color(#colorLiteral(red: 0.9537991881, green: 0.2298480868, blue: 0.2896286845, alpha: 1))
}

// MARK: - Fonts

extension Font {
    static let main = Font.custom("Helvetica Neue", size: 22).weight(.light)
    static let subtitle = Font.system(size: 12).weight(.light)
    static let trajanTitle = Font.custom("Trajan Pro", size: 38)
}

// MARK: - Animations

extension AnyTransition {
    static var fadeAndSlide: AnyTransition {
        AnyTransition.move(edge: .top).combined(with: .opacity)
    }
}
