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
    
    private var labelView: UILabel!
    private var imageView: UIImageView!
    
    private let strokeAttributes: [NSAttributedString.Key: Any] = [
        .strokeColor: UIColor.white,
        .foregroundColor: UIColor.darkGray,
        .strokeWidth: -4.0,
        .font: UIFont(name: "HelveticaNeue-Bold", size: 14) as Any
    ]
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = ClusterAnnotationView.ReuseID
        
        if let monument = annotation as? Monument {
            setupImageView(monument: monument)
            setupLabelView(text: monument.title!)
            imageView.center.x = labelView.center.x
        }
    }

    func setupImageView(monument: Monument) {
        imageView = UIImageView(frame: CGRect(x: -10, y: -10, width: 20, height: 20))
        var iconImage: UIImage
        
        if let categoryKey = CategoryKey(rawValue: monument.category) {
            let category = MNCategory(key: categoryKey)
            iconImage = category.mapIcon
        } else {
            iconImage = UIImage(systemName: "questionmark")!
        }
        imageView.image = iconImage
        addSubview(imageView)
    }
    
    func setupLabelView(text: String) {
        
        labelView = UILabel()
        labelView.frame = CGRect(x: 0, y: 12, width: 100, height: 200)
        labelView.textAlignment = .center
        labelView.numberOfLines = 0
        labelView.lineBreakMode = .byWordWrapping
        labelView.attributedText = NSAttributedString(string: text, attributes: strokeAttributes)
        labelView.sizeToFit()
        addSubview(labelView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultLow

        let frameOrigin = CGPoint(x: 0, y: 0)
        let frameSize = CGSize(width: labelView.frame.width, height: labelView.frame.maxY - imageView.frame.minY )
        self.frame = CGRect(origin: frameOrigin, size: frameSize)
        
    }
}
