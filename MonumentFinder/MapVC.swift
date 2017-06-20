//
//  MapVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 29/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import Mapbox

protocol RisultatoRicercaDelegate {
    
    func risultatoRicerca(monumento: Monumento?)
}


class MapVC: UIViewController, MGLMapViewDelegate, RisultatoRicercaDelegate {
    
    
    var clearSearch = false
    
    let mapView: MGLMapView = MGLMapView()
    let trackingManager = ARTrackingManager()

    var risultatoRicerca: Monumento!
    
    @IBAction func closeButton(_ sender: Any) {
    
        self.dismiss(animated: true)
    
    }
    
    @IBOutlet weak var searchButton: UIButton!

    @IBAction func searchButtonAction(_ sender: Any) {
        
        if clearSearch {
           
            disegnaMonumenti()
            searchButton.imageView?.image = #imageLiteral(resourceName: "Search_Icon")
            clearSearch = false
            
        } else {
            
            performSegue(withIdentifier: "toSearchVC", sender: self)
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let search = SearchVC()
        search.delegate = self
    
        mapView.frame = view.bounds
        mapView.styleURL = MGLStyle.lightStyleURL(withVersion: 9)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.showsUserLocation = true
        mapView.setZoomLevel(4, animated: false)
        
        view.addSubview(mapView)
        
        mapView.delegate = self
        
    }
    
    
    override func viewDidLayoutSubviews() {

        mapView.layoutMargins = UIEdgeInsetsMake(40, 0, 0, 0)
    
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        mapView.setZoomLevel(13, animated: true)
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSearchVC" {
            let searchVC = segue.destination as! SearchVC
            searchVC.delegate = self
        }
        
    }
    
    
    // Delegate result from SearchVC
    
    func risultatoRicerca(monumento: Monumento?) {
        
        searchButton.imageView?.image = #imageLiteral(resourceName: "Search_cancel")
        clearSearch = true
        
        print("Selected monument: \(monumento?.nome ?? "Error in monument search.\n")\n")
        
        if let oldAnnotations = mapView.annotations {
            mapView.removeAnnotations(oldAnnotations)
        }
        
        let marker = MGLPointAnnotation()
        if let monumento = monumento {
            marker.title = monumento.nome
            marker.coordinate = CLLocationCoordinate2D(latitude: monumento.lat, longitude: monumento.lon)
            marker.subtitle = monumento.categoria
            
            mapView.addAnnotation(marker)
            mapView.setCenter(marker.coordinate, animated: true)
            mapView.selectAnnotation((mapView.annotations?[0])!, animated: true)
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
       
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        mapView.setCenter((userLocation?.location?.coordinate)!, animated: false)
    }
    
    
    // Use the default marker. See also: our view annotation or custom marker examples.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        let reuseIdentifier = "identifier"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            
        if annotationView == nil {
            
            annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//            annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
//            annotationView?.layer.borderWidth = 4.0
//            annotationView?.layer.borderColor = UIColor.white.cgColor
//            annotationView!.backgroundColor = UIColor(red:0.03, green:0.80, blue:0.69, alpha:1.0)
            
            
        }
        
        // return annotationView
        return nil
        
    }
    
    
    // Allow callout view to appear when an annotation is tapped.
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        
        return true
    }
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        
        let hasWiki = monumenti.filter{$0.lat == annotation.coordinate.latitude}.first!.hasWiki
        if hasWiki {
            return UIButton(type: .detailDisclosure)
        } else {
            return nil
        }
    }
}



