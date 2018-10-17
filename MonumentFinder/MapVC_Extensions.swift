//
//  MapVC_Extensions.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 21/11/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import ClusterKit.MapKit

extension MapVC {
    
    func updateVisibleAnnotations() {
        guard let annotations = quadTree.annotations as? [MNMonument] else { return }
        let oldAnnotations = Set(mapView.clusterManager.annotations as! [MNMonument])
        let visibleAnnotations = Set(annotations.filter {$0.isActive} as [MNMonument])
      
        let annotationsToRemove = oldAnnotations.subtracting(visibleAnnotations)

        mapView.clusterManager.removeAnnotations(Array(annotationsToRemove))
        mapView.clusterManager.addAnnotations(Array(visibleAnnotations))
        print("\(visibleAnnotations.count) visible annotation on map of \(annotations.count) total annotations.")
        
    }
}
