//
//  Annotation.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 06.06.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import CoreLocation

open class Annotation: ARAnnotation  {
    
    var categoria: String = "Nessuna categoria"
    var isTappable: Bool = false
    /*
    init?(identifier: String?, title: String?, location: CLLocation, categoria: String?, isTappable: Bool?) {
        self.categoria = categoria
        self.isTappable = isTappable
        
        super.init(identifier: identifier, title: title, location: location)
    }*/
}
