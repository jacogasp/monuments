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
        
        
        let navbar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 64))
        
        let navItem = UINavigationItem(title: "Mappa")
        let fontName = defaultFont
        
        navbar.titleTextAttributes = [NSFontAttributeName: fontName]
        
        let closeButton = UIButton(type: .custom)
        closeButton.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        closeButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18)
        closeButton.setTitleColor(defaultColor, for: .normal)
        closeButton.contentHorizontalAlignment = .left
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(dismissMap), for: UIControlEvents.touchUpInside)

        
        let closeButtonItem = UIBarButtonItem(customView: closeButton)
        navItem.leftBarButtonItem = closeButtonItem

        navbar.setItems([navItem], animated: false)
        view.addSubview(navbar)
    }
    
    override func viewDidLayoutSubviews() {

        mapView.layoutMargins = UIEdgeInsetsMake(40, 0, 0, 0)
        print(mapView.layoutMargins.top)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        disegnaMonumenti()
    }
    
    func dismissMap() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func disegnaMonumenti() {
        
        let global = Global()
        global.checkWhoIsVisible()
        
        var annotationsVisibili: [MGLPointAnnotation] = []
        if let oldAnnotations = mapView.annotations {
            mapView.removeAnnotations(oldAnnotations)
        }
        
        for monumento in monumenti {
            if monumento.isActive {
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

