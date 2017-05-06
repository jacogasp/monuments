//
//  MapVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 29/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import Mapbox

class MapVC: UIViewController, MGLMapViewDelegate {
    let mapView: MGLMapView = MGLMapView()
    let trackingManager = ARTrackingManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.frame = view.bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        view.addSubview(mapView)
        
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        disegnaMonumenti()
    }
    
    func disegnaMonumenti() {
        
        let global = Global()
        global.checkWhoIsVisible()
        
        var annotationsVisibili: [MGLPointAnnotation] = []
        if let oldAnnotations = mapView.annotations {
            mapView.removeAnnotations(oldAnnotations)
        }
        
        for monumento in monumenti {
            if monumento.isVisible {
                let marker = MGLPointAnnotation()
                marker.coordinate = CLLocationCoordinate2D(latitude: monumento.lat, longitude: monumento.lon)
                marker.title = monumento.nome
                marker.subtitle = monumento.categoria
                annotationsVisibili.append(marker)
            }
        }
        mapView.addAnnotations(annotationsVisibili)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Use the default marker. See also: our view annotation or custom marker examples.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }
    
    // Allow callout view to appear when an annotation is tapped.
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}

