//
//  MaxVisiblitàView.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 11/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

/// Draw the bubble for maxDistance slider.
class BubbleView: UIView {
    
    let defaults = UserDefaults.standard

    override func draw(_ rect: CGRect) {
        
        //self.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        self.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.init(netHex: 0x95989A).cgColor
        
        // Label
        let descrizione = UILabel()
        descrizione.frame = CGRect(x: 0, y: 12, width: self.frame.width, height: 20)
        descrizione.textAlignment = NSTextAlignment.center
        descrizione.text = "Visibiltà massima"
        descrizione.textColor = global.defaultColor
        descrizione.font = UIFont(name: "HelveticaNeue-Thin", size: 18) ?? UIFont.systemFont(ofSize: 18)
        self.addSubview(descrizione)
        
        // Aggiungi lo slider
        
        let altezza: CGFloat = 20.0
        let slider = CustomSlider(frame: CGRect(x: 15,
												y: rect.midY - altezza / 2,
												width: rect.width - 30,
												height: altezza))
        slider.isContinuous = true
        slider.tintColor = UIColor(netHex: 0xB21818)
        slider.minimumValue = 0
        slider.maximumValue = Float(global.maxDistance)
        
        if let storedVisibility = defaults.value(forKey: "maxVisibility") {
            slider.value = Float(storedVisibility as! Int)
        } else {
            defaults.setValue(100, forKey: "maxVisibility")
            slider.value = Float(100)
        }
        slider.addTarget(self, action: #selector(valoreCambiato(_ :)), for: .touchUpInside)
        self.addSubview(slider)
    }
    
    @objc func valoreCambiato(_ sender: CustomSlider) {
        defaults.setValue(sender.value, forKey: "maxVisibility")
    }
}
