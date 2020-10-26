//
//  ClusterAnnotationView.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 29/09/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import MapKit

class ClusterAnnotationView: MKAnnotationView {
    static let ReuseID = "MNAnnotationClusterView"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        if let cluster = annotation as? MKClusterAnnotation {
            let totalMonuments = cluster.memberAnnotations.count
            if totalMonuments > 0 {
                image = drawCount(count: totalMonuments)
                displayPriority = .defaultLow
            } else {
                displayPriority = .defaultHigh
            }
        }
    }
    
    private func drawCount(count: Int) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30))
        
        return renderer.image { _ in

            UIColor.white.setFill()
            UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 30, height: 30)).fill()

            UIColor.secondary.setFill()
            UIBezierPath(ovalIn: CGRect(x: 2, y: 2, width: 26, height: 26)).fill()
            
            // Finally draw count text vertically and horizontally centered
            let attributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)
            ]
            let text = "\(count)"
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(x: 15 - size.width / 2, y: 15 - size.height / 2, width: size.width, height: size.height)
            text.draw(in: rect, withAttributes: attributes)
        }
    }
}
