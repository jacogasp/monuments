//
//  VisibilitySliderView.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 28/10/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class VisibilitySlider: UISlider {

    
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
        self.backgroundColor = .clear
        
        let effectView = UIVisualEffectView()
        effectView.frame = self.bounds
        effectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        let blur = UIBlurEffect(style: .dark)
        effectView.effect = blur
        self.addSubview(effectView)
        
        // MARK: The slider
        
        let slider = UISlider()
        slider.transform = .init(rotationAngle: -.pi / 2)
        slider.frame = CGRect(x: 0, y: self.bounds.width / 2, width: self.bounds.width, height: self.bounds.height - self.bounds.width)
        slider.isContinuous = true
        slider.tintColor = .lightGray
        slider.minimumValue = 50
        slider.maximumValue = 5000
        slider.value = Float(global.maxDistance)
        slider.thumbTintColor = .lightGray
        
        self.addSubview(slider)
        self.layoutMargins = UIEdgeInsets(top: 20, left: 8, bottom: 20, right: 8)
        slider.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    }
}
