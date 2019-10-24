//
//  StringExtensions.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 06/10/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//

import Foundation

extension String {
    static func localizedStringWithCounts(_ key: String, _ args: CVarArg) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String.localizedStringWithFormat(format, args)
    }
}
