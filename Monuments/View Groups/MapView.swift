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
    
    let locationManager = CLLocationManager()
    var userTrackingMode: MKUserTrackingMode = .none
    let dbHandler = DatabaseHandler()
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
                
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.showsUserLocation = true
        view.userTrackingMode = self.userTrackingMode
        if let monuments = dbHandler.fetchMonumentsFor(region: view.region) {
            view.addAnnotations(monuments)
        }
        logger.debug("Update mapView")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
        var parent: MapView
        
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            if let monuments = parent.dbHandler.fetchMonumentsFor(region: mapView.region) {
                
                for annotation in mapView.annotations {
                    if monuments.contains(annotation as! Monument) {
                        mapView.removeAnnotation(annotation)
                    } else {
                        mapView.addAnnotation(annotation)
                    }
                }
            }
            
        }
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
