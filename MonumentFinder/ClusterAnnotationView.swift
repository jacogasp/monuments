//
//  ClusterAnnotationView.swift
//  ClusterTest
//
//  Created by Jacopo Gasparetto on 13/09/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import MapKit
import ClusterKit

class ClusterAnnotationView: MKAnnotationView {
    
    var countLabel: UILabel?
    open var view: UIView?
    
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    public override var annotation: MKAnnotation? {
        didSet {
            updateClusterSize()
            
        }
    }
    
//    override func removeFromSuperview() {
//        UIView.animateKeyframes(withDuration: 1, delay: 0, options: .layoutSubviews, animations: {
//            self.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
//            self.alpha = 0
//        }, completion: nil)
//        super.removeFromSuperview()
//    }
    
    private func setupView() {
        canShowCallout = true
        backgroundColor = UIColor.clear
        self.view?.removeFromSuperview()
        let aView = UIView()
        aView.layer.borderColor = UIColor.white.cgColor
        aView.layer.borderWidth = 3.0
        aView.backgroundColor = UIColor.red
        aView.layer.masksToBounds = true
        self.addSubview(aView)
        self.view = aView
    }
    
    private func updateClusterSize() {
        if let cluster = annotation as? CKCluster {
            
            let count = cluster.annotations.count
            
            var sideLength: Double {
                switch count {
                case 1:
                    return 15
                case 2...9:
                    return 30.0
                case 10...60:
                    return 35.0
                default:
                    return 8.0 * log(Double(count))
                }
            }
            frame = CGRect(origin: frame.origin, size: CGSize(width: sideLength, height: sideLength))

            countLabel?.removeFromSuperview()
            let label = UILabel()
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            label.textAlignment = .center
            label.backgroundColor = UIColor.clear
            label.textColor = UIColor.white
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 2
            label.numberOfLines = 1
            label.baselineAdjustment = .alignCenters
            if count > 1 {
                label.text = "\(count)"
            }
            self.addSubview(label)
            countLabel = label
            
//            transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
//            self.alpha = 0.5
//            UIView.animate(withDuration: 0.6, delay: 0, options: .layoutSubviews, animations: {
//                self.transform = .identity
//                self.alpha = 1
//            }, completion: nil)

            
            setNeedsLayout()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
       
        countLabel?.frame = bounds
        view?.frame = bounds
        view?.layer.cornerRadius = bounds.size.width / 2.0
    }
}
