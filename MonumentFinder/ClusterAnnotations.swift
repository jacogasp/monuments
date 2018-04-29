//
//  ClusterAnnotations.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 05.09.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init (coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = title
    }
}

extension QuadTree {
    
    func mapRectForBoundingBox(rect: Rect) -> MKMapRect {
        let origin = MKMapPoint(x: rect.origin.x, y: rect.origin.y)
        let size = MKMapSize(width: rect.size.xLength, height: rect.size.yLength)
        
        return MKMapRect(origin: origin, size: size)
    }
    
    func zoomScaleToZoomLevel(scale: MKZoomScale) -> Int {
        let totalTilesAtMaxZoom = MKMapSizeWorld.width / 256.0
        let zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom)
        let zoomLevel: Int = Int(max(0, zoomLevelAtMaxZoom + Double(floor(log2(scale + 0.5)))))
        return zoomLevel
    }
    
    func cellSizeFroZoomScale(zoomScale: MKZoomScale) -> Double {
        let zoomLevel = zoomScaleToZoomLevel(scale: zoomScale)
        
        switch (zoomLevel) {

            case 13, 14, 15:
                return 64
            case 16, 17, 18:
                return 32
            case 19:
                return 16
            default:
                return 88
        }
    }
    
    func clusterAnnotationsWithinMapRect(rect: MKMapRect, zoomScale: MKZoomScale) -> MKClusterAnnotation {
        let cellSize = cellSizeFroZoomScale(zoomScale: zoomScale)
        let scaleFactor = Double(zoomScale) / cellSize
        
        let minX = Int(floor(MKMapRectGetMinX(rect) * scaleFactor))
        let maxX = Int(floor(MKMapRectGetMaxX(rect) * scaleFactor))
        let minY = Int(floor(MKMapRectGetMinY(rect) * scaleFactor))
        let maxY = Int(floor(MKMapRectGetMaxY(rect) * scaleFactor))
        
        var totalX = 0.0
        var totalY = 0.0
        var count = 0
        
        let names: NSMutableArray = []
        
        var annotations = [MKAnnotation]()
        
        for x in minX...maxX {
            for y in minY...maxY {
                let mapRect = MKMapRectMake(Double(x) / scaleFactor, Double(y) / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor)
                
                let origin = Point(mapRect.origin.x, mapRect.origin.y)
                let size = Size(xLength: mapRect.size.height, yLength: mapRect.size.width)
                
                let points = tree.points(inRect: Rect(origin: origin, size: size))
                
                for point in points {
                    totalX += point.x
                    totalY += point.y
                    count += 1
                    
                    names.add(String(describing: point.data[0]))
                }
                
                if count == 1 {
                    let coordinate = CLLocationCoordinate2D(latitude: totalX, longitude: totalY)
                    let annotation = MapAnnotation(coordinate: coordinate, title: names.lastObject as! String, subtitle: "culo")
                    annotations.append(annotation)
                }
                
                if count > 1 {
                    let coordinate =  CLLocationCoordinate2D(latitude: totalX / Double(count), longitude: totalY / Double(count))
                    let annotation = MapAnnotation(coordinate: coordinate, title: names.lastObject as! String, subtitle: "culino")
                    annotations.append(annotation)
                }
            }
        }
        return MKClusterAnnotation(memberAnnotations: annotations)
    }
}
