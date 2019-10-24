//
//  MapVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 29/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import MapKit

/// Send back the annotation result from a search performed on the whole quadTree
protocol SearchMKAnnotationDelegate: class {
    func searchResult(annotation: MKAnnotation)
}

class MapVC: UIViewController {
    
    // MARK: Properties
    var mustClearSearch = false
    var isCentered = true
    var isFirstLoad = true
    
    var annotationsWithButton: [String] = []
    var risultatoRicerca: Monument!
    var backgroundView: UIView!
    var observer: NSKeyValueObservation?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var mapButtonsContainer: MapButtonsContainerView!
    
    // MARK: IBActions
    @IBAction func mapButtonAction(_ sender: Any) {
        mapButtonPressed()
    }
    
    @IBAction func presentCategoriesVC(_ sender: Any) {
        let dst = self.storyboard?.instantiateViewController(withIdentifier: "CategoriesVC") as! CategoriesVC
        dst.delegate = self
        dst.modalPresentationStyle = .overFullScreen
        
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        keyWindow?.addSubview(dst.view)
        
        dst.view.transform = CGAffineTransform(translationX: self.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { _ in
            self.present(dst, animated: false, completion: nil)
            dst.parentVC = self
        })
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "toSearchVC", sender: self)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        logger.debug("Enter in MapVC")
                
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.pointOfInterestFilter = .excludingAll   // Remove Apple Maps
        
        setupCompass()
        setupBackgroundView()

        // Read old previously saved region
        if let region = restoreMKCoordinateRegionFromUserDefaults() {
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
            let icon = #imageLiteral(resourceName: "LocationFilled")
            changeButtonImage(newImage: icon, animated: false)
        } else {
            let icon = #imageLiteral(resourceName: "LocationEmpty")
            changeButtonImage(newImage: icon, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveMKCoordinateRegionToUserDefaults()
        NotificationCenter.default.post(name: Notification.Name("resumeSceneLocationView"), object: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchVC" {
            let searchVC = segue.destination as! SearchVC
            searchVC.delegate = self
        }
    }
    
    // MARK: Compass
    func setupCompass() {
        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .adaptive
        self.view.addSubview(compassButton)
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        compassButton.topAnchor.constraint(equalTo: mapButtonsContainer.bottomAnchor, constant: 8).isActive = true
        NSLayoutConstraint(item: compassButton, attribute: .centerX, relatedBy: .equal, toItem: mapButtonsContainer,
                           attribute: .centerX, multiplier: 1, constant: 0).isActive = true
    }
    
    // MARK: Load monuments
    func loadAnnotations(for region: MKCoordinateRegion) {
        if var monuments = FetchRequests.fetchMonumentsFor(region: region) {
            if monuments.count >= 100 {
                monuments = Array(monuments[0..<100])
            }
            mapView.addAnnotations(monuments)
            logger.info("Loaded \(monuments.count) monuments")
        }
    }
    
    // MARK: Show details
    func addBottomSubView(for monument: Monument) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let detailsVC = storyboard.instantiateViewController(identifier: "AnnotationDetailsVC") as! AnnotationDetailsVC
        detailsVC.monument = monument
    
        view.addSubview(backgroundView)
        detailsVC.delegate = self
    
        self.addChild(detailsVC)
        self.view.addSubview(detailsVC.view)
        detailsVC.didMove(toParent: self)
        
        let width = view.frame.width
        let height = view.frame.height
        detailsVC.view.frame = CGRect(x: 0, y: view.frame.maxY, width: width, height: height)
        addFrameObserver(to: detailsVC)
    }
    
    // MARK: Background View
    func setupBackgroundView() {
        self.backgroundView = UIView(frame: view.frame)
        self.backgroundView.backgroundColor = .clear
        backgroundView.isUserInteractionEnabled = false
    }
    
    func addFrameObserver(to viewController: UIViewController) {
        observer = viewController.view.observe(\.frame, options: .new) {view, _ in
            self.changeBackgroundAlphaByVisibleFrame(frame: view.frame)
        }
    }
    
    func changeBackgroundAlphaByVisibleFrame(frame: CGRect) {
        let yPosition = frame.origin.y
        let alpha: CGFloat = 0.75 - yPosition / UIScreen.main.bounds.height * 0.75
        backgroundView?.backgroundColor = UIColor(white: 0, alpha: alpha)
    }
    
    // MARK: User Defaults
    func saveMKCoordinateRegionToUserDefaults() {
        let defaults = UserDefaults.standard
        let locationData = [
            "lat": mapView.centerCoordinate.latitude,
            "lon": mapView.centerCoordinate.longitude,
            "latDelta": mapView.region.span.latitudeDelta,
            "lonDelta": mapView.region.span.longitudeDelta
        ]
        defaults.set(locationData, forKey: "mapViewRegion")
        defaults.set(isCentered, forKey: "mapWasCentered")
    }
    
    func restoreMKCoordinateRegionFromUserDefaults() -> MKCoordinateRegion? {
        if let region = UserDefaults.standard.object(forKey: "mapViewRegion") as? [String: Any] {
            let latitude = region["lat"] as! CLLocationDegrees
            let longitude = region["lon"] as! CLLocationDegrees
            let latDelta = region["latDelta"] as! CLLocationDegrees
            let lonDelta = region["lonDelta"] as! CLLocationDegrees
            
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            
            return MKCoordinateRegion(center: center, span: span)
        }
        return nil
    }
}

// MARK: - MKMapViewDelegate

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Monument else { return nil }
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if isFirstLoad {
            centerMapOnUserLocation(location: userLocation.location!, radius: 1000)
            isFirstLoad = false
        }
    }
    
    /// Center the map on the current user location
    func centerMapOnUserLocation(location: CLLocation, radius: Double) {
        
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: radius * 2,
                                                  longitudinalMeters: radius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
        
        if !isFirstLoad {
            let newImage = #imageLiteral(resourceName: "LocationFilled")
            changeButtonImage(newImage: newImage, animated: true)
        }
        
        if let userLocation = mapView.view(for: mapView.userLocation) {
            if userLocation.isHidden {
                userLocation.isHidden = false
                logger.verbose("Unhide user location.")
            }
        }
        
        isCentered = true
        logger.verbose("Center location.")
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if mapView.userTrackingMode != .followWithHeading && isCentered && !mustClearSearch && !isFirstLoad {
            let newImage = #imageLiteral(resourceName: "LocationEmpty")
            changeButtonImage(newImage: newImage, animated: true)
            isCentered = false
            logger.verbose("Map is not centered. regionWillChange")
        }
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // TODO: Should be implemented?
        self.loadAnnotations(for: mapView.region)
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        if mode == .none && !isCentered {
            let newImage = #imageLiteral(resourceName: "LocationFilled")
            changeButtonImage(newImage: newImage, animated: true)
            isCentered = false
            logger.info("didChange mode.")
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let monument = view.annotation as? Monument {
            logger.debug("Presenting annotationDetailsVC")
            self.addBottomSubView(for: monument)
        }
    }
        
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        // TODO: Should be implemented?
        logger.verbose("Did deselect annotation")
        for child in self.children {
            if let detailsVC = child as? AnnotationDetailsVC {
                detailsVC.hideAndRemoveFromParent()
            }
        }
        observer?.invalidate()
        backgroundView.removeFromSuperview()
    }
    
    
    
    // MARK: Buttons
    func mapButtonPressed() {
        
        if mustClearSearch {
            clearSearchResult()
        }
        
        if isCentered && mapView.userTrackingMode != .followWithHeading {
            let newImage = #imageLiteral(resourceName: "Compass")
            changeButtonImage(newImage: newImage, animated: true)
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            logger.verbose("Set heading tracking mode.")
            
        } else if mapView.userTrackingMode == .followWithHeading {
            let newImage = #imageLiteral(resourceName: "LocationFilled")
            changeButtonImage(newImage: newImage, animated: true)
            mapView.setUserTrackingMode(.none, animated: true)
            logger.verbose("Disable heading tracking mode.")
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

// MARK: - Search MKAnnotation Delegate

extension MapVC: SearchMKAnnotationDelegate {
    func searchResult(annotation: MKAnnotation) {
        
        logger.info("Selected monument: \(String(describing: annotation.title)) lat: \(annotation.coordinate.latitude)")
        // TODO: show selected annotation
    }
    
    func clearSearchResult() {
        logger.verbose("Clear")
        let annotations = mapView.annotations
        for annotation in annotations {
            mapView.view(for: annotation)?.isHidden = false
        }
        mapView.showsUserLocation = true
        mustClearSearch = false
    }
}

// MARK: - Categories VC Delegate

extension MapVC: CategoriesVCDelegate {
    func updateVisibleAnnotations(sender: UIViewController) {
    //TODO: Implement this
    }
}

extension MapVC: AnnotationDetailsDelegate {
    
    func annotationDetails(_ annotationDetails: AnnotationDetailsVC, viewControllerDidDisapper animated: Bool) {
        if let selectedMonument = annotationDetails.monument {
            for annotation in mapView.selectedAnnotations {
                if annotation.title == selectedMonument.title {
                    mapView.deselectAnnotation(annotation, animated: true)
                }
            }
        }
    }
}
