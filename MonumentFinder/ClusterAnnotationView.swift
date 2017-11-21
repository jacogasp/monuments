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
        willSet {
            updateClusterSize()
        }
    }
    
    private func setupView() {

        if let cluster = annotation as? CKCluster {
            if cluster.count > 1 {
                backgroundColor = UIColor.clear
                self.view?.removeFromSuperview()
                let aView = UIView()
                aView.layer.borderColor = UIColor.white.cgColor
                aView.layer.borderWidth = 3.0
                let color = defaultColor
                aView.backgroundColor = color
                aView.layer.masksToBounds = true
                self.addSubview(aView)
                self.view = aView
            } else {
                frame = CGRect(origin: frame.origin, size: CGSize(width: 30, height: 30))
                if let monument = cluster.firstAnnotation as? Monumento {
                    switch monument.osmtag {
                    case "monument":
                        image = #imageLiteral(resourceName: "POI_Monument")
                    case "place_of_worship":
                        image = #imageLiteral(resourceName: "POI_Worship")
                    case "obelisk":
                        image = #imageLiteral(resourceName: "POI_Obelisk")
//                    case "artwork":
//                        image = #imageLiteral(resourceName: "POI_Artwork")
                    default:
                        image = #imageLiteral(resourceName: "POI_Artwork")
                    }
                }
            }
        }

    }
    
    private func updateClusterSize() {
        if let cluster = annotation as? CKCluster {
            let count = cluster.annotations.count
            if count > 1 {
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
            } else {
//                for subview in subviews {
//                    subview.removeFromSuperview()
//                }
//
            }

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
