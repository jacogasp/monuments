//
//  AnnnotationView.swift
//  ARKit+CoreLocation
//
//  Created by Jacopo Gasparetto on 28/09/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import UIKit

@IBDesignable

open class LocationNodeView: UIView {
    
    let debugColor = false
    
    var title: String?
    var subtitle: String?
    var distanceFromUser: Double?
    
    var titleLabel: UILabel?
    var subtitleLabel: UILabel?
    var disclosureIndicator: UIImageView?

    let annotation: MNMonument?
    
    init(annotation: MNMonument) {
        self.annotation = annotation
        super.init(frame: CGRect.zero)
        self.loadUi()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadUi() {
        
        if annotation?.wikiUrl != "" {
            disclosureIndicator = UIImageView()
            disclosureIndicator?.image = #imageLiteral(resourceName: "DisclosureIndicatorGray")
            self.addSubview(disclosureIndicator!)
        }
        
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
        subLabel.font = UIFont(name: global.defaultFontName, size: 16) ?? UIFont.systemFont(ofSize: 16)
        self.addSubview(subLabel)
        self.subtitleLabel = subLabel

        if self.annotation != nil {
            self.bindUi()
        }
    }
    
    func layoutUi() {
        self.titleLabel?.frame = CGRect(x: 15, y: 2, width: self.frame.size.width - 80, height: 20)
        self.subtitleLabel?.frame = CGRect(x: 15, y: self.frame.midY, width: self.frame.size.width - 30, height: 20)
        self.disclosureIndicator?.frame = CGRect(
			x: self.frame.maxX - 35,
			y: self.frame.midY - 10,
			width: 20, height: 20)
    }
    
    func bindUi() {
        if let annotation = self.annotation {
            let distance = annotation.distanceFromUser > 1000 ?
				String(format: "%.1f km", annotation.distanceFromUser / 1000) :
				String(format: "%.0f m", annotation.distanceFromUser)
            self.titleLabel?.text = annotation.title
            self.subtitleLabel?.text = "\(annotation.subtitle ?? "No category") \(distance)"
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.layoutUi()
    }
}
