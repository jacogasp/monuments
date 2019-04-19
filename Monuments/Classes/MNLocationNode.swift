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
    
    let annotation: MNMonument
    
    init(annotation: MNMonument, image: UIImage, isHidden: Bool) {
        self.annotation = annotation
        super.init(location: annotation.location, image: image)
        self.isHidden = isHidden
        self.name = annotation.title
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
