//
//  MapVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 29/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import ClusterKit.MapKit

/// Send back the annotation result from a search performed on the whole quadTree
protocol SearchMKAnnotationDelegate {
    func searchResult(annotation: MKAnnotation)
}

class MapVC: UIViewController, MKMapViewDelegate, SearchMKAnnotationDelegate, FiltriVCDelegate {
    
    var mustClearSearch = false
    var isCentered = true
    var isFirstLoad = true
    
    var annotationsWithButton: [String] = []
    var risultatoRicerca: Monumento!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapButton: UIButton!
    
    // MARK: IBActions
    @IBAction func mapButtonAction(_ sender: Any) {
        mapButtonPressed()
    }
    
    @IBAction func presentFilterVC(_ sender: Any) {
        let dst = self.storyboard?.instantiateViewController(withIdentifier: "FiltriVC") as! FiltriVC
        dst.delegate = self
        dst.modalPresentationStyle = .overFullScreen
        UIApplication.shared.keyWindow?.addSubview(dst.view)
        dst.view.transform = CGAffineTransform(translationX: self.view.frame.size.width, y: 0)
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { finished in self.present(dst, animated: false, completion: nil); dst.parentVC = self })
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "toSearchVC", sender: self)
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
        algorithm.cellSize = 350
        mapView.clusterManager.algorithm = algorithm
        mapView.clusterManager.marginFactor = 1
        //mapView.clusterManager.setQuadTree(quadTree)
        updateVisibleAnnotations()
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        mapView.view // ???????
        mapView.fadesOutWhileRemoving = true
        mapView.showsPointsOfInterest = false

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
        NotificationCenter.default.post(name: Notification.Name("resumeSceneLocationView"), object: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSearchVC" {
            let searchVC = segue.destination as! SearchVC
            searchVC.delegate = self
        }
    }
    
    // ******************* Delegate result from SearchVC *******************
    
    func searchResult(annotation: MKAnnotation) {
        
        print(annotation)
        print("Selected monument: \(String(describing: annotation.title)) lat: \(annotation.coordinate.latitude)\n")
        mapView.clusterManager.selectAnnotation(annotation, animated: true)
        
        // Uncomment if you want a different zoom level on the selected POI
        // let newRegion = MKCoordinateRegionMakeWithDistance(annotation, 500, 500)
        // self.mapView.setRegion(newRegion, animated: true)

    }
    
    func clearSearchResult() {
        print("clearSearchResult()\n")
        let annotations = mapView.annotations
        for annotation in annotations {
            mapView.view(for: annotation)?.isHidden = false
        }
        mapView.showsUserLocation = true
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
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomPOIAnnotationView
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
        // print("regionDidChange")
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
        
        guard let cluster = view.annotation as? CKCluster else { print("Cluster failed"); return }
        
        if cluster.count > 1 {
            let edgePadding = UIEdgeInsetsMake(40, 20, 44, 20)
            mapView.show(cluster, edgePadding: edgePadding, animated: true)
        } else {
            if let annotation = cluster.firstAnnotation {
                mapView.clusterManager.selectAnnotation(annotation, animated: true)
            }
        }
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

// MARK: Extensions
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
