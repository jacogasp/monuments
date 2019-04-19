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
            guard let cluster = annotation as? CKCluster else { return }
            if cluster.count > 1 {
                setupCounterView(cluster: cluster)
                self.canShowCallout = false
            } else {
                for subview in subviews {
                    subview.removeFromSuperview()
                }
                self.canShowCallout = true
                guard let monument = cluster.firstAnnotation as? MNMonument else { return }
                
                if !monument.wikiUrl!.isEmpty {
                    let button = UIButton(type: .detailDisclosure)
                    self.rightCalloutAccessoryView = button
                }
                
                switch monument.osmtag {
                case "monument":
                    image = #imageLiteral(resourceName: "POI_Museum")
                case "place_of_worship":
                    image = #imageLiteral(resourceName: "POI_Worship")
                case "artwork":
                    image = #imageLiteral(resourceName: "POI_Artwork")
                case "memorial":
                    image = #imageLiteral(resourceName: "POI_Mermorial")
                case "museum":
                    image = #imageLiteral(resourceName: "POI_Museum")
                case "Generico":
                    image = #imageLiteral(resourceName: "POI_Generic")
                case "attraction":
                    image = #imageLiteral(resourceName: "POI_Attraction")
                case "cemetery":
                    image = #imageLiteral(resourceName: "POI_Cemetery")
                case "tomb":
                    image = #imageLiteral(resourceName: "POI_Tomb")
                case "palace":
                    image = #imageLiteral(resourceName: "POI_Palace")
                case "castle":
                    image = #imageLiteral(resourceName: "POI_Castle")
                case "obelisk":
                    image = #imageLiteral(resourceName: "POI_Obelisk")
                case "ruins":
                    image = #imageLiteral(resourceName: "POI_Ruin")
                case "sculpture":
                    image = #imageLiteral(resourceName: "POI_Sculpture")
                case "statue":
                    image = #imageLiteral(resourceName: "POI_Statue")
                case "fountain":
                    image = #imageLiteral(resourceName: "POI_Fountain")
                default:
                    image = "❓".image()
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
        aView.backgroundColor = global.defaultColor
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
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
