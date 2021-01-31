//
// MonumentAnnotationView.swift
// Monuments
//
// Created by Jacopo Gasparetto on 26/10/2020.
// Copyright (c) 2020 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import MapKit.MKAnnotationView

class MonumentAnnotationView: MKAnnotationView {
    static let ReuseID = "MNAnnotationView"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = ClusterAnnotationView.ReuseID
        
        if let monument = annotation as? Monument {
            self.canShowCallout = true
            
            let imageView = setupImageView(monument: monument)
            let labelView = setupLabelView(monument: monument)
            self.addSubview(imageView)
            self.addSubview(labelView)
            
            NSLayoutConstraint.activate([
                labelView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                NSLayoutConstraint(item: labelView,
                                   attribute: .width,
                                   relatedBy: .equal,
                                   toItem: nil,
                                   attribute: .notAnAttribute,
                                   multiplier: 1,
                                   constant: 100),
                NSLayoutConstraint(item: labelView,
                                   attribute: .top,
                                   relatedBy: .equal,
                                   toItem: imageView,
                                   attribute: .bottom,
                                   multiplier: 1,
                                   constant: 2)
            ])
        }
    }
    
    func setupImageView(monument: Monument) -> UIImageView {
        let categoryKey = CategoryKey(rawValue: monument.category)!
        let category = MNCategory(key: categoryKey)
        
        let imageView = UIImageView(frame: CGRect(x: -10, y: -10, width: 20, height: 20))
        imageView.image = category.mapIcon
        return imageView
    }
    
    func setupLabelView(monument: Monument) -> UILabel {
        let labelView = UILabel()
        
        let strokeAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor: UIColor.white,
            .strokeWidth: -2.0,
            .font: UIFont.systemFont(ofSize: 12, weight: .heavy),
            .foregroundColor: UIColor.darkGray,
        ]

        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        labelView.attributedText = NSAttributedString(string: monument.name, attributes: strokeAttributes)
        labelView.textAlignment = .center
        labelView.sizeToFit()
        labelView.numberOfLines = 0
        labelView.lineBreakMode = .byWordWrapping
        
        return labelView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
