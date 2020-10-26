//
//  MapViewContainer.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 26/06/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI
import MapKit
import CoreData

struct MapViewContainer: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> some MapViewController {
        MapViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
