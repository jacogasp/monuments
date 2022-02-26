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
        let lang = "it"
        
        
        ARCLViewContainer(monument: $monument)
            .edgesIgnoringSafeArea(.all)
            .sheet(item: self.$monument) { aMonument in
                if let wikiUrl = monument?.wikiUrl, let titleUrl = wikiUrl[lang] {
                WikipediaDetailView(
                    title: aMonument.name,
                    subtitle: aMonument.category?.description,
                    wikiUrl: titleUrl,
                    lang: lang
                )
            }
        }
    }
}


struct ARCLViewContainer: UIViewControllerRepresentable {

    @Binding var monument: Monument?
    @EnvironmentObject var env: Environment

    var currentVisibleMonument = 0
    var currentMaxDistance = -1

    // Coordinator to listen to SceneLocationView touches
    class Coordinator: NSObject, LNTouchDelegate, ARCLViewControllerDelegate {

        // MARK: - Properties
        var parent: ARCLViewContainer
        let delayAfterDismiss = 4.0
        var remaining = 0.0
        weak var timer: Timer?

        // MARK: - Init
        init(_ parent: ARCLViewContainer) {
            self.parent = parent
        }


        func nodesDidUpdate(count: Int) {

            // Prevent infinite rendering loop
            if count != parent.currentVisibleMonument {
                parent.env.numVisibleMonuments = count
                parent.currentVisibleMonument = count

                if timer == nil {
                    showPOIViewCounter()
                }

                remaining = delayAfterDismiss
                logger.info("Number of visible monuments: \(count)")
            }
        }

        // Show POI view counter and start counting down
        func showPOIViewCounter() {
            withAnimation {
                parent.env.showVisibleMonumentsCounter = true
            }
            timer = Timer.scheduledTimer(
                    timeInterval: 0.1,
                    target: self, selector: #selector(countTime),
                    userInfo: nil,
                    repeats: true)
        }

        // Count time and dismiss counter view after some idle time
        @objc func countTime() {
            remaining -= 0.1
            if (remaining <= 0) {
                withAnimation {
                    parent.env.showVisibleMonumentsCounter = false
                }
                timer?.invalidate()
                timer = nil
            }
        }

        // Tap on a balloon
        func annotationNodeTouched(node: AnnotationNode) {
            if let locationAnnotationNode = node.parent as? MNLocationAnnotationNode {
                if locationAnnotationNode.annotation.wikiUrl != nil {
                    let monument = locationAnnotationNode.annotation as Monument
                    parent.monument = monument
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
        arcl.maxDistance = env.maxDistance
        return arcl
    }

    func updateUIViewController(_ uiView: ARCLViewController, context: Context) {
        if context.coordinator.parent.currentMaxDistance != Int(env.maxDistance) {
            uiView.updateNodes(maxDistance: env.maxDistance)
            context.coordinator.parent.currentMaxDistance = Int(env.maxDistance)
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
                monument.isActive = ((monument.category?.isSelected) != nil) // FIXME: useless
//                if let categoryStatus = global.categories[CategoryKey(rawValue: (monument.category?.key)!) ?? <#default value#>] {
//                    monument.isActive = categoryStatus
//                }
            }
            self.monuments = monuments

            // Add nodes to the scene and stack annotations
            let locationNodes = buildNodes(monuments: monuments, forLocation: currentLocation)
            sceneLocationView.addLocationNodesWithConfirmedLocation(locationNodes: locationNodes)
            updateNodes(maxDistance: maxDistance)
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
            nodes.append(buildNode(monument: monument, forLocation: location, isHidden: isHidden))
            group.leave()
        }
        group.wait() // Wait until all nodes have been created
        logger.info("Visible monuments: \(count)")
        return nodes
    }

    /// Return a single LocationNode for a given Monument
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

        for monument in monuments {
            monument.isActive = ((monument.category?.isSelected) != nil) // FIXME: useless
//            if let categoryStatus = global.categories[monument.category] {
//                monument.isActive = categoryStatus
//            }
//            monument.isActive = true // FIXME: categoryStatus
        }

        let locationNodes = sceneLocationView.locationNodes as! [MNLocationAnnotationNode]

        var count = 0
        var numberOfNewVisible = 0
        var numberOfNewHidden = 0

        for node in locationNodes {
            let distanceFromUser = currentLocation.distance(from: node.annotation.location)

            // The monument should be visible
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

