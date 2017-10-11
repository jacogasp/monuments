//
//  LocationNode.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 04/10/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import CoreLocation

class MNLocationAnnotationNode: LocationAnnotationNode {
    
    let annotation: Monumento
    
    init(annotation: Monumento, image: UIImage) {
        self.annotation = annotation
        super.init(location: annotation.location, image: image)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

