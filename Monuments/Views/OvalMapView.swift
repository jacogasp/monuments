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
    
    private let clipLayer = CALayer()
    private let shapeLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()

    override func layoutSubviews() {
        super.layoutSubviews()
        commonInit()
    }
    
    private func commonInit() {
        layer.mask = clipLayer
        clipLayer.addSublayer(gradientLayer)
        gradientLayer.mask = shapeLayer
        
        setupClipLayer()
        setupShapeLayer()
        setupGradientLayer()
    }
    
    // MARK: - Setup Layers
    
    private func setupClipLayer() {
        clipLayer.frame = bounds
    }
    
    private func setupShapeLayer() {
        shapeLayer.frame = bounds
        
        let offset: CGFloat = 25.0
        let arcCenter = CGPoint(x: self.frame.size.width / 2,
                                y: 0.5 * (offset + pow(self.frame.size.width, 2) / (4 * offset)))
        let alpha = atan(arcCenter.x / (arcCenter.y - offset))
        
        let path = UIBezierPath(arcCenter: arcCenter, radius: arcCenter.y, startAngle: .pi + alpha, endAngle: .pi - alpha, clockwise: true)
        path.move(to: CGPoint(x: self.frame.maxX, y: self.frame.maxY))
        path.move(to: CGPoint(x: 0, y: self.frame.maxY))
        path.move(to: CGPoint(x: 0, y: arcCenter.y - offset))
        path.close()
        shapeLayer.path = path.cgPath
    }
    
    private func setupGradientLayer() {
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.black, UIColor.black, UIColor.black.withAlphaComponent(0.2)].map{$0.cgColor}
        gradientLayer.locations = [0, 0.5, 1]
    }
}
