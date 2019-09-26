//
//  MapButtonsContainerView.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 26/09/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//

import UIKit

@IBDesignable
class MapButtonsContainerView: UIView {
    
    let centerLine = CALayer()
   
    override func draw(_ rect: CGRect) {
        // Drawing code
        centerLine.frame = CGRect(x: 0, y: rect.height / 2 - 0.25, width: rect.width, height: 0.5)
        centerLine.backgroundColor = UIColor.lightGray.cgColor
        layer.addSublayer(centerLine)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = UIColor.white.withAlphaComponent(0.8)
    }

}
