//
//  MapView.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 26/06/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI
import MapKit
import CoreData

struct MapView: UIViewRepresentable {

    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {

    }
}


struct MapViewTest: View {
    var body: some View {
        MapView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return MapViewTest()
    }
}
