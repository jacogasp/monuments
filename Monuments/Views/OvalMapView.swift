//
//  OvalMapView.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 28/10/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import MapKit

class OvalMapView: MKMapView {

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutOvalMask()
    }
    
    private func layoutOvalMask() {
        let mask = self.shapeMaskLayer()
        let offset: CGFloat = 25.0
        let arcCenter = CGPoint(x: self.frame.size.width / 2,
                                y: 0.5 * (offset + pow(self.frame.size.width, 2) / (4 * offset)))
        let alpha = atan(arcCenter.x / (arcCenter.y - offset))
        
        let path = UIBezierPath(arcCenter: arcCenter, radius: arcCenter.y, startAngle: .pi + alpha, endAngle: .pi - alpha, clockwise: true)
        path.move(to: CGPoint(x: self.frame.maxX, y: self.frame.maxY))
        path.move(to: CGPoint(x: 0, y: self.frame.maxY))
        path.move(to: CGPoint(x: 0, y: arcCenter.y - offset))
        path.close()
        mask.path = path.cgPath
    }
    
    private func shapeMaskLayer() -> CAShapeLayer {
        if let layer = self.layer.mask as? CAShapeLayer { return layer }
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.black.cgColor
        self.layer.mask = layer
        return layer
    }
}

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * .pi / 180.0
    }
}
