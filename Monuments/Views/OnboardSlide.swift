//
//  OnboardSlide.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 10/10/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableButton: UIButton {
        
    @IBInspectable public var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        layer.masksToBounds = true
        layer.cornerRadius = layer.frame.height / 2
        setTitleColor(.white, for: .selected)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
}

@IBDesignable
class OnboardSlideView: UIView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var button: DesignableButton!
    @IBAction func buttonTapped(_ sender: Any) {}
}
