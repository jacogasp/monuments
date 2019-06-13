//
//  Extensions.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 14/11/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import MapKit

// MARK: Extensions

extension DispatchQueue {
    /// Asynchronouse delay
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
			execute: execute)
    }
}

// MARK: UIView to UIImage
extension UIView {
    /// Convert the UIView to an UIImage
    func generateImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return uiImage
    }
}

extension UIView {
    // TODO: what is this for?
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        
        for subview in subviews {
            recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
        }
        
        return recursiveSubviews
    }
}

extension MKCoordinateRegion {
    /// Convert MKCoordinateRegion to MKMapRect
    func toMKMapRect() -> MKMapRect {
        let region = self
        let topLeft = CLLocationCoordinate2D(
            latitude: region.center.latitude + (region.span.latitudeDelta / 2.0),
            longitude: region.center.longitude - (region.span.longitudeDelta / 2.0)
        )
        
        let bottomRight = CLLocationCoordinate2D(
            latitude: region.center.latitude - (region.span.latitudeDelta / 2.0),
            longitude: region.center.longitude + (region.span.longitudeDelta / 2.0)
        )
        
        let topLeftMapPoint = MKMapPoint(topLeft)
        let bottomRightMapPoint = MKMapPoint(bottomRight)
        
        let origin = MKMapPoint(x: topLeftMapPoint.x,
                                y: topLeftMapPoint.y)
        let size = MKMapSize(width: fabs(bottomRightMapPoint.x - topLeftMapPoint.x),
                             height: fabs(bottomRightMapPoint.y - topLeftMapPoint.y))
        
        return MKMapRect(origin: origin, size: size)
    }
}

extension UIImage {
    /// Initialize a UIImage by a UIView
    convenience init(view: UIView) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
        
    }
}

extension CLLocationCoordinate2D {
    /// Compare two CLLocationCoordinate2D
    func isEqual(_ coord: CLLocationCoordinate2D) -> Bool {
        return (fabs(self.latitude - coord.latitude) < .ulpOfOne)
			&& (fabs(self.longitude - coord.longitude) < .ulpOfOne)
    }
    
    var description: String? {
        return "\(round(self.latitude * 100) / 100), \(round(self.longitude * 100) / 100)"
    }
}
