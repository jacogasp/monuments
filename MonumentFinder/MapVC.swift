//
//  MapVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 29/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import ClusterKit.MapKit

protocol RisultatoRicercaDelegate {
    
    func risultatoRicerca(monumento: Monumento)
}


class MapVC: UIViewController, MKMapViewDelegate, RisultatoRicercaDelegate {
    
    var mustClearSearch = false
    var isCentered = true
    var isFirstLoad = true
    
    var annotationsWithButton: [String] = []
    var risultatoRicerca: Monumento!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapButton: UIButton!
    
    // MARK: IBActions
    @IBAction func mapButtonAction(_ sender: Any) {
        mapButtonPressed()
    }
    // 
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: { NotificationCenter.default.post(name: Notification.Name("resumeSceneLocationView"), object: nil)})
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        if mustClearSearch {
            clearSearchResult()
        } else {
            performSegue(withIdentifier: "toSearchVC", sender: self)
        }
    }

    // MARK: viewDidLoad
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("Enter in MapVC")
        
        if #available(iOS 11.0, *) {
            mapView.register(CustomPOIAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        } else {
            // Fallback on earlier versions
        }
        
        let search = SearchVC()
        search.delegate = self
      
        let algorithm = CKNonHierarchicalDistanceBasedAlgorithm()
        algorithm.cellSize = 400
        mapView.clusterManager.algorithm = algorithm
        mapView.clusterManager.marginFactor = 1
        mapView.clusterManager.setQuadTree(quadTree)
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        mapView.view // ???????
        mapView.fadesOutWhileRemoving = true

        // Read old previously saved region
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
    
    override func viewWillAppear(_ animated: Bool) {
        isCentered = UserDefaults.standard.bool(forKey: "mapWasCentered")
        if isCentered {
            let icon = UIImage(named: "Icon_map_fill")
            changeButtonImage(newImage: icon!, animated: false)
        } else {
            let icon = UIImage(named: "Icon_map_empty")
            changeButtonImage(newImage: icon!, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // Save current mapView.region to reuse later
        let defaults = UserDefaults.standard
        let locationData = ["lat" : mapView.centerCoordinate.latitude,
                            "lon" : mapView.centerCoordinate.longitude,
                            "latDelta" : mapView.region.span.latitudeDelta,
                            "lonDelta" : mapView.region.span.longitudeDelta]
        defaults.set(locationData, forKey: "mapViewRegion")
        defaults.set(isCentered, forKey: "mapWasCentered")
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

        print("Selected monument: \(String(describing: monumento.title)) lat: \(monumento.coordinate.latitude)\n")

        let annotations = mapView.annotations
        for annotation in annotations {
            if annotation.title! == monumento.title {

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
        print("clearSearchResult()\n")
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
    
    // Setup the annotation view for each annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        } else {
            let identifier = "annotation"
//            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ?? ClusterAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomPOIAnnotationView

//            if let cluster = annotation as? CKCluster {
//                if cluster.count > 1 {
//                    annotationView?.canShowCallout = false
//                } else {
//                    annotationView?.canShowCallout = true
////                    if let monumento = cluster.firstAnnotation as? Monumento {
////                        switch monumento.osmtag {
////                        case "monument":
////                            annotationView.image = UIImage(named: "POI_Monument")
////                        case "place_of_worship":
////                            annotationView.image = UIImage(named: "POI_Worship")
////                        default:
////                            annotationView.image = #imageLiteral(resourceName: "POI_Obelisk")
////                        }
////                        if !monumento.wikiUrl!.isEmpty {
////                            let button = UIButton(type: .detailDisclosure)
////                            annotationView.rightCalloutAccessoryView = button
////                        }
////                    }
//                }
//            }
            return annotationView
        }
    }

    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotationsDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AnnotationDetailsVC") as! AnnotationDetailsVC
        if let annotation = view.annotation as? CKCluster {
            if let monumento = annotation.firstAnnotation as? Monumento {
                annotationsDetailsVC.modalPresentationStyle = .overCurrentContext
                annotationsDetailsVC.titolo = monumento.title
                annotationsDetailsVC.categoria = monumento.categoria
                annotationsDetailsVC.wikiUrl = monumento.wikiUrl
                print("Presenting annotationDetailsVC\n")
                self.present(annotationsDetailsVC, animated: true, completion: nil)
            }
        }
        
    }
    
    /// Center the map on the current user location
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
    
    // MARK: How To Update Clusters
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChange")
        mapView.clusterManager.updateClustersIfNeeded()
        
    }
    
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        
        if mode == .none && !isCentered {
            let newImage = UIImage(named: "Icon_map_empty")
            changeButtonImage(newImage: newImage!, animated: true)
            isCentered = false
            print("Map: didChange mode.")
        }
        
        
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Did select annotation:", terminator: " ")
        
        guard let cluster = view.annotation as? CKCluster else {
            print("Cluster failed")
            return
        }
            
        if (cluster.count > 1) {
            mapView.show(cluster, animated: true)
        }
    
//        if cluster.count > 1 {
//            let edgePadding = UIEdgeInsetsMake(40, 20, 44, 20)
//            mapView.show(cluster, edgePadding: edgePadding, animated: true)
//        } else {
//            if let annotation = cluster.firstAnnotation {
//                mapView.clusterManager.selectAnnotation(annotation, animated: true)
//                if let title = annotation.title {
//                    if let x = title {
//                     print(x)
//                    } else {
//                        print("unknown")
//                    }
//                }
//            }
//        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let cluster = view.annotation as? CKCluster, cluster.count == 1 else {
            return
        }
        mapView.clusterManager.deselectAnnotation(cluster.firstAnnotation, animated: true)
        print("Did deselect annotation: \(cluster.firstAnnotation!.title!!)")
    }
    
    // MARK: How To Handle Drag and Drop
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
//        guard let cluster = view.annotation as? CKCluster else {
//            return;
//        }
//        
//        switch newState {
//        case .ending:
//            
//            if let annotation = cluster.firstAnnotation as? MKPointAnnotation {
//                annotation.coordinate = cluster.coordinate
//            }
//            view.setDragState(.none, animated: true)
//            
//        case .canceling:
//            view.setDragState(.none, animated: true)
//            
//        default: break
//            
//        }
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

extension UIButton {
    
    func addBlurEffect() {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blur.frame = self.bounds
        blur.isUserInteractionEnabled = false
        self.insertSubview(blur, at: 0)
        if let imageView = self.imageView {
            self.bringSubview(toFront: imageView)
        }
    }
    
}

