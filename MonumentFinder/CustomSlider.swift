//
//  CustomSlider.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 11/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {

    var label: UILabel = UILabel()
    var labelXMin: CGFloat?
    var labelXMax: CGFloat?
    var labelText: () -> String = {
        ""
    }

//    required init(coder aDecoder: NSCoder) {
//        label = UILabel()
//        super.init(coder: aDecoder)!
//     //   self.addTarget(self, action: Selector("onValueChanged:"), for: .valueChanged)
//        
//    }

    func setup() {

        labelXMin = frame.origin.x + 16
        labelXMax = frame.origin.x + self.frame.width - 14

        let labelXOffset: CGFloat = labelXMax! - labelXMin!
        let valueOffset: CGFloat = CGFloat(self.maximumValue - self.minimumValue)
        let valueDifference: CGFloat = CGFloat(self.value - self.minimumValue)
        let valueRatio: CGFloat = CGFloat(valueDifference / valueOffset)
        let labelXPos = CGFloat(labelXOffset * valueRatio + labelXMin!)

        label.frame = CGRect(x: labelXPos, y: self.frame.origin.y + 25, width: 200, height: 25)
        label.text = String(format: "%.0f m", self.value)
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 12) ?? UIFont.systemFont(ofSize: 12)
        label.textColor = defaultColor

        self.superview!.addSubview(label)

    }

    func updateLabel() {

        label.text = labelText()
        let labelXOffset: CGFloat = labelXMax! - labelXMin!
        let valueOffset: CGFloat = CGFloat(self.maximumValue - self.minimumValue)
        let valueDifference: CGFloat = CGFloat(self.value - self.minimumValue)
        let valueRatio: CGFloat = CGFloat(valueDifference / valueOffset)
        let labelXPos = CGFloat(labelXOffset * valueRatio + labelXMin!)
        label.frame = CGRect(x: labelXPos - label.frame.width / 2, y: self.frame.origin.y + 25, width: 200, height: 25)
        label.textAlignment = NSTextAlignment.center

        self.superview!.addSubview(label)

    }

    public override func layoutSubviews() {

        labelText = {
            String(format: "%.0f m", self.value)
        }
        setup()
        updateLabel()
        super.layoutSubviews()
    }

    func onValueChanged(sender: CustomSlider) {

        updateLabel()
        self.value = powf(10, sender.value)

    }
}
