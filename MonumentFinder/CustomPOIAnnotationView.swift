//
//  CustomPOIAnnotationView.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 20/11/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import MapKit
import ClusterKit

class CustomPOIAnnotationView: MKAnnotationView {
    
    var countLabel: UILabel?
    open var counterView: UIView?
    
    override var annotation: MKAnnotation? {
        didSet {
//            image = #imageLiteral(resourceName: "POI_Worship")
            guard let cluster = annotation as? CKCluster else { return }
            if cluster.count > 1 {
                setupCounterView(cluster: cluster)
            } else {
                for subview in subviews {
                    subview.removeFromSuperview()
                }
                guard let monument = cluster.firstAnnotation as? Monumento else { return }
                switch monument.osmtag {
                case "monument":
                    image = #imageLiteral(resourceName: "POI_Monument")
                case "place_of_worship":
                    image = #imageLiteral(resourceName: "POI_Worship")
                case "artwork":
                    image = #imageLiteral(resourceName: "POI_Artwork")
                default:
                    image = "📐".image()
                }
            }
        }
    }
    
    func setupCounterView(cluster: CKCluster) {
        backgroundColor = .clear
        self.counterView?.removeFromSuperview()
        let aView = UIView()
        aView.layer.borderColor = UIColor.white.cgColor
        aView.layer.borderWidth = 3.0
        aView.backgroundColor = defaultColor
        aView.layer.masksToBounds = true
        self.addSubview(aView)
        self.counterView = aView
        
        let count = cluster.annotations.count
        var diameter: Double {
            switch count {
            case 1:
                return 20
            case 2...9:
                return 30.0
            case 10...60:
                return 35.0
            default:
                return 8.0 * log(Double(count))
            }
        }
        frame = CGRect(origin: frame.origin, size: CGSize(width: diameter, height: diameter))
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
        label.text = "\(count)"
        self.addSubview(label)
        countLabel = label
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        countLabel?.frame = bounds
        counterView?.frame = bounds
        counterView?.layer.cornerRadius = bounds.size.width / 2.0
    }
    
}

extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 30, height: 35)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.white.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

