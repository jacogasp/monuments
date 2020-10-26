//
// MonumentAnnotationView.swift
// Monuments
//
// Created by Jacopo Gasparetto on 26/10/2020.
// Copyright (c) 2020 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import MapKit.MKMarkerAnnotationView

class MonumentAnnotationView: MKMarkerAnnotationView {
    static let ReuseID = "MNAnnotationView"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = ClusterAnnotationView.ReuseID
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
        markerTintColor = UIColor.secondary
//        glyphImage = #imageLiteral(resourceName: "Theatre")
//        glyphTintColor = .white
    }
}