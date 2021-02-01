//
//  MapViewController.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 29/09/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Properties
    
    var mapView: MKMapView!
    private var userTrackingButton: MKUserTrackingButton!
    private var scaleView: MKScaleView!
    private let dbHandler = DatabaseHandler()
    private var displayedMonumentsIds: Set<Int>!
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupUserTrackingButtonAndScaleView()
        registerAnnotationViewClasses()
        loadMapData(for: mapView.region)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateToUserLocation()
    }
    
    private func setupMapView() {
        
        mapView = MKMapView()
        mapView.frame = self.view.bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.pointOfInterestFilter = .excludingAll
        self.view.addSubview(mapView)
    }
    
    private func setupUserTrackingButtonAndScaleView() {
        mapView.showsUserLocation = true
        
        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        view.addSubview(userTrackingButton)
        
        scaleView = MKScaleView(mapView: mapView)
        scaleView.legendAlignment = .trailing
        
        let stackView = UIStackView(arrangedSubviews: [scaleView, userTrackingButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate(
            [
                stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
            ])
    }
    
    private func registerAnnotationViewClasses() {
        mapView.register(MonumentAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    private func animateToUserLocation() {
        if let annotaion = mapView.annotations.filter ({ $0 is MKUserLocation }).first {
            let coordinate = annotaion.coordinate
            let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: true)
        }
    }
    
    
    // MARK: - Helpers
    
    private func loadMapData(for region: MKCoordinateRegion) {
        // Get between 0 and 100 monuments for the given region
        if let monuments = dbHandler.fetchMonumentsFor(region: region) {
            logger.debug("Fetched \(monuments.count) monument in current region")
            
            // If the were no previously displayed monuments, add them all
            if displayedMonumentsIds == nil {
                mapView.addAnnotations(monuments)
                displayedMonumentsIds = Set(monuments.map { $0.id })
                return
            }
            
            var monumentsToShowIds = Set(monuments.map { $0.id })
            
            // Monuments IDs to not remove from map
            let intersectionIds = displayedMonumentsIds.intersection(monumentsToShowIds)
            
            displayedMonumentsIds.subtract(intersectionIds)
            monumentsToShowIds.subtract(intersectionIds)
            
            let currentAnnotations = mapView.annotations.compactMap { $0 as? Monument }
            
            let annotationsToRemove = currentAnnotations.filter { displayedMonumentsIds.contains($0.id) }
            let annotationsToAdd = monuments.filter { monumentsToShowIds.contains($0.id) }
            
            mapView.removeAnnotations(annotationsToRemove)
            mapView.addAnnotations(annotationsToAdd)
            
            // Keep track of the monuments on the map
            displayedMonumentsIds = monumentsToShowIds.union(intersectionIds)
            logger.debug("Removed: \(annotationsToRemove.count) and added: \(annotationsToAdd.count) annotations")
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        loadMapData(for: mapView.region)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Monument else { return nil }
        
        let annotationView = MonumentAnnotationView(annotation: annotation, reuseIdentifier: MonumentAnnotationView.ReuseID)
        
        return annotationView
    }
}

