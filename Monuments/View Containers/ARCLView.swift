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
    @State private var monument: Monument?
    @State private var isDetailPresented = false
    
    var body: some View {
        ARCLViewContainer(monument: $monument, isDetailPresented: $isDetailPresented).edgesIgnoringSafeArea(.all)
            //
        .sheet(isPresented: self.$isDetailPresented) {
            WikipediaDetailView(monument: self.monument!)
        }
    }
}


struct ARCLViewContainer: UIViewControllerRepresentable {
    
    @Binding var monument: Monument?
    @Binding var isDetailPresented: Bool
    
    // Cordinator to listen to SceneLocationView touches
    class Coordinator: NSObject, LNTouchDelegate {
        
        var parent: ARCLViewContainer
        weak var monument: Monument!
        
        init(_ parent: ARCLViewContainer) {
            self.parent = parent
        }
        // Tap on a balloon
        func annotationNodeTouched(node: AnnotationNode) {
             if let locationAnnotationNode = node.parent as? MNLocationAnnotationNode {
                if locationAnnotationNode.annotation.wikiUrl != nil {
                self.parent.monument = locationAnnotationNode.annotation as Monument
                self.parent.isDetailPresented = true
                }
            }
        }
        
        func locationNodeTouched(node: LocationNode) { }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> ARCLViewController {
        let arcl = ARCLViewController()
        arcl.sceneLocationView.locationNodeTouchDelegate = context.coordinator
        return arcl
    }
    
    func updateUIViewController(_ uiView: ARCLViewController, context: Context) {
        
    }
}

class ARCLViewController: UIViewController, ARSCNViewDelegate {
        
    // MARK: - Properties
    let maxVisibleMonuments = 25
    
    var sceneLocationView = SceneLocationView()
    var monuments = [Monument]()
    
    // MARK: - Init
    override func viewDidLoad() {
        view.backgroundColor = .blue
        
        if ARConfiguration.isSupported {
            setupSceneLocationView()
            sceneLocationView.run()
            initialNodesSetup()
        }
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
