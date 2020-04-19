//
//  VisibiltyStepper.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 13/04/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class SignButton: UIButton {
    
    let segmentLength: CGFloat = 15.0
    let segmentWidth: CGFloat = 3.0
    let signColor: UIColor = .white
    
    let highlightColor = UIColor.black.withAlphaComponent(0.5)
    
    var currentColor = UIColor.clear
    
    
    public enum SignType {
        case plus
        case minus
    }
    
    public var type: SignType = .plus
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public convenience init(type: SignType) {
        self.init()
        self.type = type
    }
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? highlightColor : currentColor
        }
    }
    
    override open var isEnabled: Bool {
        didSet {
            currentColor = isEnabled ? .clear : highlightColor
            backgroundColor = currentColor
        }
    }
    
    override func draw(_ rect: CGRect) {
        switch self.type {
        case .plus:
            self.layer.addSublayer(vLayer)
            self.layer.addSublayer(hLayer)
        case .minus:
            self.layer.addSublayer(hLayer)
        }
    }
    
    lazy var hLayer: CALayer = {
        let hLayer = CALayer()
        hLayer.frame = CGRect(
            x: (layer.bounds.width - segmentLength) / 2,
            y: (layer.bounds.height - segmentWidth) / 2,
            width: segmentLength, height: segmentWidth
        )
        hLayer.backgroundColor = signColor.cgColor
        hLayer.cornerRadius = self.segmentWidth / 2
        return hLayer
    }()
    
    lazy var vLayer: CALayer = {
        let vLayer = CALayer()
        vLayer.frame = CGRect(
            x: (layer.bounds.width - segmentWidth) / 2,
            y: (layer.bounds.height - segmentLength) / 2,
            width: segmentWidth, height: segmentLength
        )
        vLayer.backgroundColor = signColor.cgColor
        vLayer.cornerRadius = self.segmentWidth / 2
        return vLayer
    }()
}


public class Stepper: UIControl {
    
    var minimumValue: Int = 0
    var maximumValue: Int = 1000
    var stepValue: Int =  100
    let useVibrancy = true
    
    var value: Int = 100 {
        didSet {
            plusButton.isEnabled = value != maximumValue
            minusButton.isEnabled = value != minimumValue
        }
    }
    
    lazy var plusButton: UIButton = {
        let button = SignButton(type: .plus)
        button.addTarget(self, action: #selector(setValue(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var minusButton: UIButton = {
        let button = SignButton(type: .minus)
        button.addTarget(self, action: #selector(setValue(sender:)), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let blur = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blur)
        
        let vibrancy = UIVibrancyEffect(blurEffect: blur, style: .fill)
        let vibrancyView = UIVisualEffectView(effect: vibrancy)
        
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(blurView)
        
        if (useVibrancy) {
            blurView.contentView.addSubview(vibrancyView)
            vibrancyView.contentView.addSubview(plusButton)
            vibrancyView.contentView.addSubview(minusButton)
        } else {
            self.addSubview(plusButton)
            self.addSubview(minusButton)
        }
        
    }
    
    // MARK: Drawings
    public override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(rect: self.bounds)
        let linePath = UIBezierPath(rect: CGRect(x: 0, y: self.bounds.height / 2, width: self.bounds.width, height: 1))
        path.append(linePath)
        
        path.usesEvenOddFillRule = true
        
        let maskPath = CAShapeLayer()
        maskPath.path = path.cgPath
        maskPath.fillColor = UIColor.white.cgColor
        maskPath.fillRule = .evenOdd
        self.layer.mask = maskPath
    }
    
    public override func layoutSubviews() {
        plusButton.frame = CGRect(x: 0, y: 0, width: self.bounds.width - 0.5, height: self.bounds.height / 2)
        minusButton.frame = CGRect(x: 0, y: self.bounds.height / 2 + 0.5, width: self.bounds.width, height: self.bounds.height / 2)
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
    }
    
    // MARK: Logic

    @objc func setValue(sender: SignButton) {
        var newValue: Int
        switch sender.type {
           
        case .plus:
            newValue = value + stepValue
        case .minus:
            newValue = value - stepValue
        }
        newValue = min(maximumValue, max(minimumValue, newValue))
        
        if (newValue != value) {
            value = newValue
            self.sendActions(for: .valueChanged)
        }
    }
}

