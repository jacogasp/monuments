//
//  MapAnnotation.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 13/10/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import ClusterKit.CKCluster


open class MapAnnotationView: MKAnnotationView {

    open lazy var countLabel: UILabel = {
        let label = UILabel()
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.backgroundColor = .clear
        label.font = .boldSystemFont(ofSize: 13)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 2
        label.baselineAdjustment = .alignCenters
        self.addSubview(label)
        return label
    }()
    
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        //configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var annotation: MKAnnotation? {
        didSet {
            configure()
        }
    }
    
    open func configure() {
        guard let cluster = annotation as? CKCluster else { return }

        let count = cluster.annotations.count
        backgroundColor = defaultColor
        var diameter: Double {
            switch count {
            case 1:
                self.layer.borderWidth = 3.0
                self.layer.borderColor = UIColor.white.cgColor
                return 20
            case 2...9:
                return 30.0
            case 10...60:
                return 35.0
            default:
                self.layer.borderWidth = 0.0
                countLabel.text = "\(count)"
                return 8.0 * log(Double(count))
            }
        }
        
        frame = CGRect(origin: frame.origin, size: CGSize(width: diameter, height: diameter))

    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = bounds.width / 2
        countLabel.frame = bounds
    }
}
