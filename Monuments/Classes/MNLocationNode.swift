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
    
    let annotation: Monument
    
    init(annotation: Monument, image: UIImage, isHidden: Bool) {
        self.annotation = annotation
        let location = CLLocation(latitude: annotation.latitude, longitude: annotation.longitude)
        super.init(location: location, image: image)
        self.isHidden = isHidden
        self.name = annotation.name
        self.shouldStackAnnotation = true
        self.scaleRelativeToDistance = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
