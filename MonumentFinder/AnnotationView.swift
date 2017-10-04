//
//  AnnnotationView.swift
//  ARKit+CoreLocation
//
//  Created by Jacopo Gasparetto on 28/09/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import UIKit

@IBDesignable

open class AnnotationView: UIView {
    
    let debugColor = false
    
    var title: String?
    var subtitle: String?
    var distanceFromUser: Double?
    
    var titleLabel: UILabel?
    var subtitleLabel: UILabel?
    var distanceLabel: UILabel?
    let annotation: Annotation?
    
    init(annotation: Annotation) {
        self.annotation = annotation
        super.init(frame: CGRect.zero)
        self.loadUi()
    }
    
//    override public init(frame: CGRect) {
//        super.init(frame: frame)
//        self.loadUi()
//    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


    func loadUi() {
        
        // Background setup
//        self.layer.cornerRadius = self.frame.size.height / 2.0
//        self.clipsToBounds = true
//        self.backgroundColor = .clear
//        self.layer.backgroundColor = UIColor.white.cgColor
//        self.alpha = 0.95
        
        // Title label
        self.titleLabel?.removeFromSuperview()
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Light", size: 20) ?? UIFont.systemFont(ofSize: 20)
        label.backgroundColor = debugColor ? .green : .clear
        label.textColor = UIColor.black
        self.addSubview(label)
        self.titleLabel = label
        
        // Subtitle label
        self.subtitleLabel?.removeFromSuperview()
        let subLabel = UILabel()
        subLabel.backgroundColor = debugColor ? .blue : .clear
        subLabel.font = UIFont(name: defaultFontName, size: 16) ?? UIFont.systemFont(ofSize: 16)
        subLabel.text = subtitle
        self.addSubview(subLabel)
        self.subtitleLabel = subLabel
        
        // Distance label
        self.distanceLabel?.removeFromSuperview()
        let distance = UILabel()
        distance.backgroundColor = debugColor ? .red : .clear
        distance.font = UIFont(name: defaultFontName, size: 20) ?? UIFont.systemFont(ofSize: 20)
        distance.textAlignment = .right
        self.addSubview(distance)
        self.distanceLabel = distance
        
        if self.annotation != nil {
            self.bindUi()
        }
    }
    
    func layoutUi() {
        self.titleLabel?.frame = CGRect(x: 15, y: 2, width: self.frame.size.width - 80, height: 20)
        self.subtitleLabel?.frame = CGRect(x: 15, y: self.frame.midY, width: self.frame.size.width - 30, height: 20)
        self.distanceLabel?.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
        self.distanceLabel?.center = CGPoint(x: self.frame.maxX - (distanceLabel?.frame.size.width)! / 2 - 5, y: self.frame.midY)
    }
    
    func bindUi() {
        if let annotation = self.annotation {
            let distance = annotation.distanceFromUser > 1000 ? String(format: "%.1f km", annotation.distanceFromUser / 1000) : String(format:"%.0f m", annotation.distanceFromUser)

            self.titleLabel?.text = annotation.title
            self.subtitleLabel?.text = annotation.subtitle
            self.distanceLabel?.text = distance
            
//            self.descriptionLabel?.text = String(format: "%@\nDistanza: %@", categoria, distance)
//            self.isTappable = annotation.isTappable
        }

    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.layoutUi()
    }

}

