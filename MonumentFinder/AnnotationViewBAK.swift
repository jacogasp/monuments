//
//  TestAnnotationView.swift
//  HDAugmentedRealityDemo
//
//  Created by Danijel Huis on 30/04/15.
//  Copyright (c) 2015 Danijel Huis. All rights reserved.
//

import UIKit

open class AnnotationViewBAK: ARAnnotationView, UIGestureRecognizerDelegate {
    open var titleLabel: UILabel?
    open var infoButton: UIButton?
    open var categoria: String?
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.titleLabel == nil {
            self.loadUi()
        }
    }
    
    func loadUi() {
        
        
        
        // Title label
        self.titleLabel?.removeFromSuperview()
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        self.addSubview(label)
        self.titleLabel = label
        
        // Info button
//        self.infoButton?.removeFromSuperview()
//        let button = UIButton(type: UIButtonType.detailDisclosure)
//        button.isUserInteractionEnabled = false   // Whole view will be tappable, using it for appearance
//        self.addSubview(button)
//        self.infoButton = button
//        
//        // Gesture
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AnnotationView.tapGesture))
//        self.addGestureRecognizer(tapGesture)
        
        // Other
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.layer.cornerRadius = 5
        
        if self.annotation != nil
        {
            self.bindUi()
        }
    }
    
    func layoutUi() {
        let origine = self.frame.height
        
        self.titleLabel?.frame = CGRect(x: origine + 5, y: 0, width: self.frame.size.width - origine - 5, height: self.frame.size.height);
        
        let lato = self.frame.height
        let quadrato = UIView(frame: CGRect(x: 0, y: 0, width: lato, height: lato))
        quadrato.backgroundColor = UIColor.init(netHex: 0x08A9F9)
        
        let offset: CGFloat = 0
        let iconaFrame = CGRect(x: offset, y:offset, width: lato - 2 * offset, height: lato - 2 * offset)
        let icona = UIImageView(frame: iconaFrame)
        let iconaImg = UIImage(named: self.categoria ?? "Statua")
        
        icona.image = iconaImg?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        //icona.tintColor = UIColor.white
        icona.contentMode = .scaleAspectFit
        
        self.addSubview(quadrato)
        quadrato.addSubview(icona)
        
    }
    
    // This method is called whenever distance/azimuth is set
    override open func bindUi() {
        if let annotation = self.annotation, let title = annotation.title, let categoria = annotation.categoria {
            let distance = annotation.distanceFromUser > 1000 ? String(format: "%.1fkm", annotation.distanceFromUser / 1000) : String(format:"%.0fm", annotation.distanceFromUser)
            
            let text = String(format: "%@\nDistanza: %@", title, distance)
            self.titleLabel?.text = text
            self.categoria = categoria
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutUi()
    }
    
    open func tapGesture() {
        if let annotation = self.annotation {
            let alertView = UIAlertView(title: annotation.title, message: "Tapped", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
        }
    }
    
    
}
