//
//  MapVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 29/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import MapKit

protocol RisultatoRicercaDelegate {
    
    func risultatoRicerca(monumento: Monumento)
}


class MapVC: UIViewController, MKMapViewDelegate, RisultatoRicercaDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func mapButtonAction(_ sender: Any) {
        mapButtonPressed()
    }
    
    
    @IBOutlet weak var mapButton: UIButton!
    
    var mustClearSearch = false
    var isCentered = true
    var isFirstLoad = true
    
    var annotationsWithButton: [String] = []
    
    var risultatoRicerca: Monumento!
    

    @IBAction func closeButton(_ sender: Any) {
        if let previousController = self.presentingViewController{
            previousController.view.backgroundColor = UIColor.green
            previousController.view.isHidden = true
            self.dismiss(animated: true, completion: { () in
                previousController.dismiss(animated: false, completion: nil)
            })
        }
        
    }
    
    
    @IBOutlet weak var searchButton: UIButton!

    @IBAction func searchButtonAction(_ sender: Any) {
        
        if mustClearSearch {
            clearSearchResult()
        } else {
            
            performSegue(withIdentifier: "toSearchVC", sender: self)
        }
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        let search = SearchVC()
        search.delegate = self
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        DispatchQueue.main.async {
            self.disegnaMonumenti()
        }
        
        let defaults = UserDefaults.standard
        if let savedRegion = defaults.object(forKey: "mapViewRegion") as? Dictionary<String, Any> {
            let latitude = savedRegion["lat"] as! CLLocationDegrees
            let longitude = savedRegion["lon"] as! CLLocationDegrees
            let latDelta = savedRegion["latDelta"] as! CLLocationDegrees
            let lonDelta = savedRegion["lonDelta"] as! CLLocationDegrees
            
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: false)
            isFirstLoad = false
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        let locationData = ["lat":mapView.centerCoordinate.latitude
            , "lon":mapView.centerCoordinate.longitude
            , "latDelta":mapView.region.span.latitudeDelta
            , "lonDelta":mapView.region.span.longitudeDelta]
        defaults.set(locationData, forKey: "mapViewRegion")
    }
    
    func dismissMap() {
    
        dismiss(animated: true, completion: nil)
    
    }
    
    
    func disegnaMonumenti() {
        
        let global = Global()
        global.checkWhoIsVisible()
        
        if !mapView.annotations.isEmpty {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        for monumento in monumenti {
            if monumento.isActive {
                let coordinate = CLLocationCoordinate2D(latitude: monumento.lat, longitude: monumento.lon)
                let marker = MonumentAnnotation(title: monumento.nome, subtitle: monumento.categoria, coordinate: coordinate, identifier: monumento.hasWiki ? "wiki" : "nowiki")
                self.mapView.addAnnotation(marker)
            }
        }
        print("Added \(monumenti.filter{$0.isActive}.count)")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSearchVC" {
            let searchVC = segue.destination as! SearchVC
            searchVC.delegate = self
        }
        
        if segue.destination is SettingsVC {
            print("going back")
        }
        
    }
    
    
    // ******************* Delegate result from SearchVC *******************
    
    func risultatoRicerca(monumento: Monumento) {
        
        searchButton.imageView?.image = #imageLiteral(resourceName: "Search_cancel")
        let newImage = UIImage(named: "Icon_map_empty")
        changeButtonImage(newImage: newImage!, animated: false)
        mustClearSearch = true
        
        print("Selected monument: \(monumento.nome) lat: \(monumento.lat)\n")
        
        let annotations = mapView.annotations
        for annotation in annotations {
            if annotation.title! == monumento.nome {
                
                print("Set visibile only \((annotation.title!)!), lat: \(annotation.coordinate.latitude) identifier: \((annotation as! MonumentAnnotation).identifier)")
                let newRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 500, 500)
                self.mapView.setRegion(newRegion, animated: true)
                self.mapView.selectAnnotation(annotation, animated: true)
                self.isCentered = false
                self.mapView.view(for: annotation)?.isHidden = false
                
            } else {
                self.mapView.view(for: annotation)?.isHidden = true
            }
        }
    }
    
    func clearSearchResult() {
        
        let annotations = mapView.annotations
        for annotation in annotations {
            mapView.view(for: annotation)?.isHidden = false
        }
        mapView.showsUserLocation = true
        searchButton.imageView?.image = #imageLiteral(resourceName: "Search_Icon")
        mustClearSearch = false
        
    }
    
    // ***************** mapView *****************************+
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if isFirstLoad {
            centerMapOnUserLocation(location: userLocation.location!, radius: 1000)
            isFirstLoad = false
        }
        
    }
    
    
    // Use the default marker. See also: our view annotation or custom marker examples.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? MonumentAnnotation {
            let identifier = annotation.identifier
            var view: MKPinAnnotationView
            if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequedView.annotation = annotation
                view = dequedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.isEnabled = true
                view.canShowCallout = true
                switch identifier {
                case "wiki":
                    view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                    view.pinTintColor = UIColor.purple
                default: break
                    
                }
            }
            
            return view
        }
        
        return nil
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let annotationsDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AnnotationDetailsVC") as! AnnotationDetailsVC
        
        if let title = view.annotation?.title, let categoria = view.annotation?.subtitle {
            annotationsDetailsVC.titolo = title
            annotationsDetailsVC.categoria = categoria
            annotationsDetailsVC.modalPresentationStyle = .overCurrentContext

            self.present(annotationsDetailsVC, animated: true, completion: nil)
        }
        
    }
    
    
    func centerMapOnUserLocation(location: CLLocation, radius: Double) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, radius * 2, radius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
        
        if !isFirstLoad {
            let newImage = UIImage(named: "Icon_map_fill")
            changeButtonImage(newImage: newImage!, animated: true)
        }
        
        if let userLocation = mapView.view(for: mapView.userLocation) {
            if userLocation.isHidden {
                userLocation.isHidden = false
                print ("Unhide user location.")
            }
        }
        
        isCentered = true
        print("Center location.")
        
    }
    
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
            if mapView.userTrackingMode != .followWithHeading && isCentered && !mustClearSearch && !isFirstLoad {
                let newImage = UIImage(named: "Icon_map_empty")
                changeButtonImage(newImage: newImage!, animated: true)
                isCentered = false
                print("Map is not centered. regionWillChange")
            }
    }
    
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        
        if mode == .none && !isCentered {
            let newImage = UIImage(named: "Icon_map_empty")
            changeButtonImage(newImage: newImage!, animated: true)
            isCentered = false
            print("Map: didChange mode.")
        }
        
    }
    
    // ****************** mapButton *****************
    
    func mapButtonPressed() {
        
        if mustClearSearch {
            clearSearchResult()
        }
        
        if isCentered && mapView.userTrackingMode != .followWithHeading {
            let newImage = UIImage(named: "Icon_compass")
            changeButtonImage(newImage: newImage!, animated: true)
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            print("Set heading tracking mode.")
            
        } else if mapView.userTrackingMode == .followWithHeading {
            let newImage = UIImage(named: "Icon_map_fill")
            changeButtonImage(newImage: newImage!, animated: true)
            mapView.setUserTrackingMode(.none, animated: true)
            print("Disable heading tracking mode.")
        } else {
            let userLocation = mapView.userLocation.location
            centerMapOnUserLocation(location: userLocation!, radius: 1000)
        }
        
    }
    
    
    func changeButtonImage(newImage: UIImage, animated: Bool) {
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.mapButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.mapButton.setImage(newImage, for: .normal)
            }, completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.mapButton.transform = CGAffineTransform.identity
                }
            })
        } else {
            self.mapButton.setImage(newImage, for: .normal)
        }
        
    }
    
    
}

class MonumentAnnotation: NSObject, MKAnnotation {
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(title: String, subtitle: String?, coordinate: CLLocationCoordinate2D, identifier: String) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.identifier = identifier
        
        super.init()
    }
    
}



