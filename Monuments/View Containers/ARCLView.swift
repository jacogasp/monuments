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
import Combine

struct ARCLView: View {
    @State private var monument: Monument? = nil
    
    var body: some View {
        ARCLViewContainer(monument: $monument)
            .edgesIgnoringSafeArea(.all)
            .sheet(item: self.$monument) { aMonument in
                WikipediaDetailView(monument: aMonument)
            }
    }
}


struct ARCLViewContainer: UIViewControllerRepresentable {
    
    @Binding var monument: Monument?
    @EnvironmentObject var env: Environment
    
    
    var currentVisibleMonument = 0
    var currentMaxDistance = -1
    
    // Cordinator to listen to SceneLocationView touches
    class Coordinator: NSObject, LNTouchDelegate, ARCLViewControllerDelegate {
        
        func nodesDidUpdate(count: Int) {
            
            // Prevent infinite rendering loop
            if count != parent.currentVisibleMonument {
                parent.env.numVisibleMonuments = count
                parent.currentVisibleMonument = count
                parent.env.showCounter = true
                logger.info("Number of visible monuments: \(count)")
            }
        }
        
        
        var parent: ARCLViewContainer
//        weak var monument: Monument!
        
        init(_ parent: ARCLViewContainer) {
            self.parent = parent
        }
        // Tap on a balloon
        func annotationNodeTouched(node: AnnotationNode) {
            if let locationAnnotationNode = node.parent as? MNLocationAnnotationNode {
                if locationAnnotationNode.annotation.wikiUrl != nil {
                    let monument = locationAnnotationNode.annotation as Monument
                    self.parent.monument = monument
                    logger.info("Tapped \(monument.name)")
                }
            }
        }
        
        func locationNodeTouched(node: LocationNode) { }
    }
    
    // MARK: - Init
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> ARCLViewController {
        let arcl = ARCLViewController()
        arcl.sceneLocationView.locationNodeTouchDelegate = context.coordinator
        arcl.delegate = context.coordinator
        arcl.maxDistance = self.env.maxDistance
        return arcl
    }
    
    func updateUIViewController(_ uiView: ARCLViewController, context: Context) {
        if context.coordinator.parent.currentMaxDistance != Int(self.env.maxDistance) {
            uiView.updateNodes(maxDistance: self.env.maxDistance)
            context.coordinator.parent.currentMaxDistance = Int(self.env.maxDistance)
        }
    }
}

// MARK: - ARCLViewControllerDelegate

protocol ARCLViewControllerDelegate {
    func nodesDidUpdate(count: Int)
}

class ARCLViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - Properties
    var maxVisibleMonuments = 25
    var sceneLocationView = SceneLocationView()
    var monuments = [Monument]()
    var delegate: ARCLViewControllerDelegate?
    var maxDistance = 250.0       // Meters
    
    // MARK: - Init
    override func viewDidLoad() {
        view.backgroundColor = .blue
        
        if ARConfiguration.isSupported {
            setupSceneLocationView()
            initialNodesSetup()
        } else {
            logger.error("ARConfiguration not supported.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if ARConfiguration.isSupported {
            sceneLocationView.run()
        } else {
            logger.error("ARConfiguration not supported.")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneLocationView.pause()
        logger.debug("Scene Location View paused.")
    }
    
    // MARK: - Helpers
    private func setupSceneLocationView() {
        sceneLocationView.frame = view.bounds
        
        view.addSubview(sceneLocationView)
        sceneLocationView.orientToTrueNorth = true
        sceneLocationView.stackingOffset = 3.0
        sceneLocationView.antialiasingMode = .multisampling4X
    }
    
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
        
        let dbHandler = DatabaseHandler()
        
        if let monuments = dbHandler.fetchMonumentsAroundLocation(location: currentLocation, radius: 10000) {
            for monument in monuments {
                if let categoryStatus = global.categories[monument.category] {
                    monument.isActive = categoryStatus
                }
            }
            self.monuments = monuments
            
            // Add nodes to the scene and stack annotations
            let locationNodes = self.buildNodes(monuments: monuments, forLocation: currentLocation)
            self.sceneLocationView.addLocationNodesWithConfirmedLocation(locationNodes: locationNodes)
            self.updateNodes(maxDistance: self.maxDistance)
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
        logger.info("Visible monuments: \(count)")
        return nodes
    }
    
    /// Return a single LocationNode for a givend Monument
    func buildNode(monument: Monument, forLocation location: CLLocation, isHidden: Bool) -> MNLocationAnnotationNode {
        let annotationView = AnnotationView(frame: CGRect(origin: .zero, size: CGSize.balloon))
        annotationView.distanceFromUser = monument.location.distance(from: location)
        annotationView.annotation = monument
        let locationAnnotationNode = MNLocationAnnotationNode(annotation: monument,
                                                              image: annotationView.generateImage(),
                                                              isHidden: isHidden)
        return locationAnnotationNode
    }
    
    /// Hide or reveal nodes based on maxDistance and selected categories
    func updateNodes(maxDistance: Double) {
        logger.verbose("Update location nodes. Max distance: \(maxDistance)")
        guard let currentLocation = sceneLocationView.sceneLocationManager.locationManager.currentLocation else {
            logger.error("Failed to update nodes. No current location available.")
            return
        }
        
        for monument in self.monuments {
            if let categoryStatus = global.categories[monument.category] {
                monument.isActive = categoryStatus
            }
            monument.isActive = true // FIXME: categoryStatus
        }
        
        let locationNodes = self.sceneLocationView.locationNodes as! [MNLocationAnnotationNode]
        
        var count = 0
        var numberOfNewVisible = 0
        var numberOfNewHidden = 0
        
        for node in locationNodes {
            let distanceFromUser = currentLocation.distance(from: node.annotation.location)
            
            // The mounument should be visible
            //            if distanceFromUser <= maxDistance && node.annotation.isActive {
            if distanceFromUser <= maxDistance { // FIXME
                count += 1
                if node.isHidden {
                    node.isHidden = false
                    let action = SCNAction.sequence([SCNAction.wait(duration: 0.01 * Double(numberOfNewVisible)),
                                                     SCNAction.fadeIn(duration: 0.2)])
                    node.runAction(action)
                    numberOfNewVisible += 1
                }
            } else { // The monument should be hidden
                if !node.isHidden {
                    let action = SCNAction.sequence([
                                                        SCNAction.wait(duration: 0.01 * Double(numberOfNewHidden)),
                                                        SCNAction.fadeOut(duration: 0.2)])
                    node.runAction(action, completionHandler: {node.isHidden = true})
                    numberOfNewHidden += 1
                }
            }
        }
        delegate?.nodesDidUpdate(count: count)
    }
    
}

//struct ARCLView_Previews: PreviewProvider {
//    static var previews: some View {
//        ARCLView()
//    }
//}

struct ARCLView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
