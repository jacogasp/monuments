//
//  ARCLView.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 25/07/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI
import CoreLocation
import ARKit

struct ARCLView: View {
    var body: some View {
        ARCLViewContainer().edgesIgnoringSafeArea(.all)
    }
}


struct ARCLViewContainer: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> ARCLViewController {
        return ARCLViewController()
        
    }
    
    func updateUIViewController(_ uiView: ARCLViewController, context: Context) {}
    
}

class ARCLViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: -Properties
    let maxVisibleMonuments = 25
    
    private var sceneLocationView: SceneLocationView!
    var monuments = [Monument]()
    
    // MARK: - Init
    override func viewDidLoad() {
        view.backgroundColor = .blue
        if ARConfiguration.isSupported {
            sceneLocationView = SceneLocationView()
            sceneLocationView.frame = view.bounds
            sceneLocationView.arViewDelegate = self
            
            view.addSubview(sceneLocationView)
            sceneLocationView.run()
            initialNodesSetup()
        }
    }
    
    // MARK: - Helpers
    
    func initialNodesSetup() {
        logger.verbose("Perform initial nodes setup")
        // Wait until currentLocation is available
        guard let currentLocation = sceneLocationView.sceneLocationManager.currentLocation else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.initialNodesSetup()
            }
            logger.warning("Cannot create nodes because user location not available")
            return
        }
        
        logger.debug("Loading nodes around current location...")
        
        if let monuments = FetchRequests.fetchMonumentsAroundLocation(location: currentLocation, radius: 10000) {
            for monument in monuments {
                if let categoryStatus = global.categories[monument.category] {
                    monument.isActive = categoryStatus
                }
            }
            self.monuments = monuments
            
            // Add nodes to the scene and stack annotations
            let locationNodes = self.buildNodes(monuments: monuments, forLocation: currentLocation)
            self.sceneLocationView.addLocationNodesWithConfirmedLocation(locationNodes: locationNodes)
            // Add nodes to the map
            //            self.mapView.addAnnotations(monuments)
        }
    }
    
    /// Add a list of nodes
    func buildNodes(monuments: [Monument], forLocation location: CLLocation) -> [LocationAnnotationNode] {
        var count = 0
        var nodes: [LocationAnnotationNode] = []
        let group = DispatchGroup()
        let nMax = monuments.count < maxVisibleMonuments ? monuments.count : maxVisibleMonuments
        
        let sortedMonuments = monuments.sorted(by: {
            $0.location.distance(from: location) < $1.location.distance(from: location)
        })[0..<nMax]
        
        for monument in sortedMonuments {
            group.enter() // Workaround to force the creation of an UIImage in the main thread
            let distanceFromUser = monument.location.distance(from: location)
            let isHidden = !(distanceFromUser <= Double(global.maxDistance) && monument.isActive)
            if !isHidden { count += 1 }
            nodes.append(self.buildNode(monument: monument, forLocation: location, isHidden: isHidden))
            group.leave()
        }
        group.wait() // Wait until all nodes have been created
        //        self.labelCounterAnimate(count: count)
        logger.info("Visible monuments: \(count)")
        return nodes
    }
    
    /// Return a single LocationNode for a givend Monument
    func buildNode(monument: Monument, forLocation location: CLLocation, isHidden: Bool) -> MNLocationAnnotationNode {
        let annotationView = AnnotationView(frame: CGRect(x: 0, y: 0, width: 230, height: 50))
        annotationView.distanceFromUser = monument.location.distance(from: location)
        annotationView.annotation = monument
        let locationAnnotationNode = MNLocationAnnotationNode(annotation: monument,
                                                              image: annotationView.generateImage(),
                                                              isHidden: isHidden)
        return locationAnnotationNode
    }
}

struct ARCLView_Previews: PreviewProvider {
    static var previews: some View {
        ARCLView()
    }
}
