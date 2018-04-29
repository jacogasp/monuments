//
//  ClusterAnnotationView.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 06/09/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import MapKit

class ClusterAnnotationView: MKAnnotationView {

    func rectCenter(rect: CGRect) -> CGPoint {
        return CGPoint(x: rect.midX, y: rect.midY)
    }
    
    func centerRect(rect: CGRect, center: CGPoint) -> CGRect{
        return CGRect(x: center.x - rect.size.width / 2.0, y: center.y - rect.size.height / 2, width: rect.size.width, height: rect.size.height)
    }
    let scaleFactorAlpha: Float = 0.3
    let scaleFactorBeta: Float = 0.4
    
    func scaledValueForValue(value: Float) -> Float {
        return 1.0 / (1.0 + expf(-1 * scaleFactorAlpha * powf(value, scaleFactorBeta)))
    }
    
    let countLabel = UILabel()
    
    func initWithAnnotation(annotation: MapAnnotation, reuseIdentifier: String) {
        
    }
    
    
}
