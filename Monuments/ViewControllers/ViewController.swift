//
//  ViewController.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 02/10/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//
// swiftlint:disable type_body_length
// swiftlint:disable file_length

import ARKit
import MapKit
import SceneKit
import UIKit

@available(iOS 11.0, *)
class ViewController: UIViewController, UIGestureRecognizerDelegate, LNTouchDelegate {
    
    let sceneLocationView = SceneLocationView()
    let configuration = ARWorldTrackingConfiguration()

	let maxVisibleMonuments = 30
    let config = EnvironmentConfiguration()

	/// Whether to display some debugging data
	/// This currently displays the coordinate of the best location estimate
	/// The initial value is respected
	var displayDebug = UserDefaults.standard.object(forKey: "switchDebugState") as? Bool ?? false
	var infoLabel = UILabel()

	var updateInfoLabelTimer: Timer?
	var comingFromBackground = false
	var isFirstRun = true
	var scaleRelativeToDistance = UserDefaults.standard.bool(forKey: "scaleRelativeTodistance")
    var shouldLoadMonumentsFromTree = true

	var monuments = [MNMonument]()
	var visibleMonuments = [MNMonument]()
	var numberOfVisibibleMonuments = 0
	var countLabel = UILabel()
	var effect: UIVisualEffect!
    

	// Set IBOutlet
	@IBOutlet var noPOIsView: UIView!
	@IBOutlet var blurVisualEffectView: UIVisualEffectView!
	@IBOutlet var locationAlertView: UIView!

	// ViewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()
        
		// Setup blur visual effect
		effect = blurVisualEffectView.effect
		blurVisualEffectView.effect = nil
		noPOIsView.layer.cornerRadius = 5
		blurVisualEffectView.isUserInteractionEnabled = false
        
		// Setup SceneLocationView
        sceneLocationView.shouldStackAnnotations = true
        sceneLocationView.stackingOffset = 5.0
        sceneLocationView.antialiasingMode = .multisampling4X
        sceneLocationView.locationNodeTouchDelegate = self
        sceneLocationView.session.delegate = self
        view.addSubview(sceneLocationView)
        view.sendSubviewToBack(sceneLocationView) // send sceneLocationView behind the IB elements
        
        // Settings View Controller Delegate
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let settingsVC = storyboard.instantiateViewController(identifier: "SettingsVC") as! SettingsVC
        settingsVC.delegate = self
        
        // Create the UILabel that counts the visible annotations
		setupCountLabel()
        
        // Setup Notification Observers
        setupNotificationObservers()
		shouldDisplayDebugAtStart()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
        logger.verbose("Run sceneLocationView")
		sceneLocationView.run()
        
        logger.verbose("Perform initial nodes setup")
        initialNodesSetup()
	}

	override func viewDidDisappear(_ animated: Bool) {
		logger.verbose("viewDidDisappear")
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		logger.verbose("Pause sceneLocationView")
		sceneLocationView.pause()
	}

	override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
		sceneLocationView.frame = view.bounds
        
        // CounterLabel setup
		infoLabel.frame = CGRect(x: 6, y: 0, width: 300, height: 14 * 4)
		infoLabel.center = CGPoint(x: view.center.x, y: view.frame.height - infoLabel.frame.height / 2)
	}

	@objc func resumeSceneLocationView() {
		sceneLocationView.run()
		logger.verbose("Resume sceneLoationView")
	}

	@objc func pauseSceneLocationView() {
		sceneLocationView.pause()
        saveCurrentLocation()
		logger.verbose("Pause sceneLoationView")
	}
    
    // MARK: Orientation changes
	@objc func orientationDidChange() {
		let orientation = UIDevice.current.orientation
		var angle: CGFloat = 0.0
		switch orientation {
		case .landscapeLeft:
			angle = .pi / 2
		case .landscapeRight:
			angle = -.pi / 2
		default:
			angle = 0.0
		}
		let rotation = CGAffineTransform(rotationAngle: angle)
		UIView.animate(withDuration: 0.2) {
			for view in self.view.subviews where view is UIButton {
				view.transform = rotation
			}
		}
	}
    
    private func saveCurrentLocation() {
        do {
            guard let currentLocation = sceneLocationView.sceneLocationManager.currentLocation else {
                throw CLError(.locationUnknown)
            }
            
            let archivedUserLocation = try NSKeyedArchiver.archivedData(withRootObject: currentLocation,
                                                                        requiringSecureCoding: false)
            UserDefaults.standard.set(archivedUserLocation, forKey: "oldUserLocation")
        } catch CLError.locationUnknown {
            logger.error("CurrentLocation not found")
        } catch {
            logger.error("Failed to save oldUserLocation with error: \(error)")
        }
    }

	// MARK: Update counterLabel
	func setupCountLabel() {
		countLabel.frame = CGRect(x: 0, y: 0, width: 210, height: 20)
		countLabel.center = CGPoint(x: view.bounds.size.width / 2, y: -countLabel.frame.height)
		countLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
		countLabel.layer.cornerRadius = countLabel.frame.height / 2.0
		countLabel.clipsToBounds = true
		countLabel.layer.borderColor = UIColor.black.cgColor
		countLabel.layer.borderWidth = 0.5
		countLabel.font = UIFont(name: config.defaultFontName, size: 12)
		countLabel.textAlignment = .center
	}

	/// Drop down the label counter for visible objects. count: number of item to count
	func labelCounterAnimate(count: Int) {
		if count > 0 {
			countLabel.text = "\(count) oggetti visibili"
			if view.subviews.contains(noPOIsView) { noPOIsViewAnimateOut() }
		} else {
			countLabel.text = "Nessun oggetto visibile"
			if !view.subviews.contains(noPOIsView) { noPOIsViewAnimateIn() }
		}

		let oldCenter = CGPoint(x: view.bounds.width / 2, y: -countLabel.bounds.height)

		if !view.subviews.contains(countLabel) {
			countLabel.center = oldCenter
			view.addSubview(countLabel)
			UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: { self.countLabel.center = CGPoint(x: self.view.bounds.width / 2, y: 50)},
                           completion: { _ in
                                UIView.animate(withDuration: 0.3,
                                               delay: 2,
                                               options: .curveEaseInOut,
                                               animations: { self.countLabel.center = oldCenter},
                                               completion: { _ in self.countLabel.removeFromSuperview() })
			})
		}
	}
    
    /// Make No POIs View visible
	func noPOIsViewAnimateIn() {
		view.addSubview(noPOIsView)
		noPOIsView.center = view.center
		noPOIsView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
		noPOIsView.alpha = 0

		UIView.animate(withDuration: 0.4) {
			self.blurVisualEffectView.effect = self.effect
			self.noPOIsView.alpha = 1
			self.noPOIsView.transform = .identity
		}
	}
    /// Hide No POIs View
	func noPOIsViewAnimateOut() {
		UIView.animate(
			withDuration: 0.3, animations: {
				self.noPOIsView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
				self.noPOIsView.alpha = 0

				self.blurVisualEffectView.effect = nil
			}, completion: { (_: Bool) in
				self.noPOIsView.removeFromSuperview()
		})
	}
    
	// MARK: Update debugging infoLabel
	@objc func updateInfoLabel() {
        if let position = sceneLocationView.currentScenePosition {
			infoLabel.text = "x: \(String(format: "%.2f", position.x)), " +
			"y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
		}

        if let eulerAngles = sceneLocationView.currentEulerAngles {
			infoLabel.text!.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), " +
				"y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
		}

        if let heading = sceneLocationView.sceneLocationManager.locationManager.heading,
            let accuracy = sceneLocationView.sceneLocationManager.locationManager.headingAccuracy {
			infoLabel.text!.append("Heading: \(String(format: "%.2f", heading))º, accuracy: \(Int(round(accuracy)))º\n")
		}

		let date = Date()
		let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)

		if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
			infoLabel.text!.append(
				"\(String(format: "%02d", hour)):" +
				"\(String(format: "%02d", minute)):\(String(format: "%02d", second)):" +
				"\(String(format: "%03d", nanosecond / 1000000))"
			)
		}
	}

	// MARK: Prepare for segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "toSettingsVC" {
			let navigationController = segue.destination as! UINavigationController
			let settingsVC = navigationController.topViewController as! SettingsVC
			settingsVC.delegate = self
		}
	}

	// MARK: Debug mode
	func shouldDisplayDebugAtStart() {
		let shouldDisplayARDebug = UserDefaults.standard.bool(forKey: "switchArFeaturesState")
		let shouldDisplaDebugFeatures = UserDefaults.standard.bool(forKey: "switchDebugState")

		if shouldDisplayARDebug { displayARDebug(isVisible: true) }
		if shouldDisplaDebugFeatures { displayDebugFeatures(isVisible: true) }
	}

	func displayARDebug(isVisible: Bool) {
		if isVisible {
			logger.debug("display AR Debug")
			sceneLocationView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]

			infoLabel.font = UIFont.systemFont(ofSize: 10)
			infoLabel.textAlignment = .left
			infoLabel.textColor = UIColor.white
			infoLabel.numberOfLines = 0
			sceneLocationView.addSubview(infoLabel)

			updateInfoLabelTimer = Timer.scheduledTimer(
				timeInterval: 0.1,
				target: self,
				selector: #selector(updateInfoLabel),
				userInfo: nil,
				repeats: true)
		} else {
			logger.debug("Enable Debug AR")
			sceneLocationView.debugOptions = []
			infoLabel.removeFromSuperview()
			updateInfoLabelTimer?.invalidate()
		}
	}

	func displayDebugFeatures(isVisible: Bool) {
		if isVisible {
			logger.debug("Enable Debug Features")
			sceneLocationView.showsStatistics = true
		} else {
			logger.debug("Disable Debug Features")
			sceneLocationView.showsStatistics = false
		}
	}
}

// MARK: Data Helpers
@available(iOS 11.0, *)
extension ViewController {
    
    /// Hide or reveal nodes based on maxDistance and selected categories
    @objc func updateNodes() {
        logger.info("Update location nodes")
        guard let currentLocation = sceneLocationView.sceneLocationManager.locationManager.currentLocation else {
            logger.error("Failed to update nodes. No current location avaiable.")
            return
        }
        global.updateMonumentsState(forMonumentsList: self.monuments)
        let locationNodes = self.sceneLocationView.locationNodes as! [MNLocationAnnotationNode]
        
        var count = 0
        var numberOfNewVisible = 0
        var numberOfNewHidden = 0
        
        for node in locationNodes {
            let distanceFromUser = currentLocation.distance(from: node.annotation.location)
            
            // The mounument should be visible
            if distanceFromUser <= Double(global.maxDistance) && node.annotation.isActive {
                count += 1
                // if node.isHidden { self.revealLocationNode(locationNode: node, animated: true) }
                if node.isHidden {
                    numberOfNewVisible += 1
                }
            } else {
                // The monument should be hidden
                if !node.isHidden {
                    let action = SCNAction.sequence([
                        SCNAction.wait(duration: 0.01 * Double(numberOfNewHidden)),
                        SCNAction.fadeOut(duration: 0.2)])
                    node.runAction(action, completionHandler: {node.isHidden = true})
                    numberOfNewHidden += 1
                }
            }
        }
        self.labelCounterAnimate(count: count)
        logger.info("Number of visible monuments: \(count)")
    }
    
    /// Create nodes when the app starts and the currentLocation is available
    func initialNodesSetup() {
        
        // Wait until currentLocation is available
        guard let currentLocation = sceneLocationView.sceneLocationManager.currentLocation else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.initialNodesSetup()
            }
            return
        }
        
        logger.debug("Populate nodes")
        
        monuments = self.loadMonumentsAroundLocation(location: currentLocation)
        global.updateMonumentsState(forMonumentsList: self.monuments)
        
        // Add nodes to the Scene
        self.sceneLocationView.addLocationNodesWithConfirmedLocation(locationNodes:
            self.buildNodes(forLocation: currentLocation))
    }

    /// Extract monuments within a MKMapRect centered on the user location.
    func loadMonumentsAroundLocation(location: CLLocation) -> [MNMonument] {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: config.mkRegionSpanMeters,
                                                  longitudinalMeters: config.mkRegionSpanMeters)
        let rect = coordinateRegion.toMKMapRect()
        let monuments = quadTree.annotations(in: rect) as! [MNMonument]
        logger.info("Loaded elements around current location: \(monuments.count)")
        // Set the distance between each monument and the user location
        for monument in monuments {
            monument.distanceFromUser = monument.location.distance(from: location)
        }
        return monuments
    }
    
    /// Add a list of nodes
    func buildNodes(forLocation location: CLLocation) -> [LocationAnnotationNode] {
        var count = 0
        var nodes: [LocationAnnotationNode] = []
        let group = DispatchGroup()
        let nMax = (monuments.count < config.maxNumberOfVisibleMonuments) ?
            monuments.count : config.maxNumberOfVisibleMonuments
        let sortedMonuments = monuments.sorted(by: {$0.distanceFromUser < $1.distanceFromUser })[0..<nMax]
        for monument in sortedMonuments {
            group.enter() // Workaround to force the creation of an UIImage in the main thread
            let distanceFromUser = monument.location.distance(from: location)
            let isHidden = !(distanceFromUser <= Double(config.maxDistance) && monument.isActive)
            if !isHidden { count += 1 }
            nodes.append(self.buildNode(monument: monument, isHidden: isHidden))
            group.leave()
        }
        group.wait() // Wait until all nodes have been created
        self.labelCounterAnimate(count: count)
        logger.info("Visible monuments: \(count)")
        return nodes
    }
    
    /// Return a single LocationNode for a givend Monument
    func buildNode(monument: MNMonument, isHidden: Bool) -> MNLocationAnnotationNode {
        let annotationView = LocationNodeView(annotation: monument)
        annotationView.frame = CGRect(x: 0, y: 0, width: 230, height: 50)
        annotationView.layer.cornerRadius = annotationView.frame.size.height / 2.0
        annotationView.clipsToBounds = true
        annotationView.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        
        let locationAnnotationNode = MNLocationAnnotationNode(annotation: monument, image: annotationView.generateImage(), isHidden: isHidden)
        
        return locationAnnotationNode
    }
    
    /// Set the locationNode isHidden = false and run the animation to reveal it.
    func revealLocationNode(locationNode: LocationNode, animated: Bool) {
        
        locationNode.isHidden = false
        let action = SCNAction.sequence([SCNAction.wait(duration: 0.01 * Double(numberOfNewVisible)),
                                      SCNAction.fadeIn(duration: 0.2)])
        locationNode.runAction(action)
        
    }
    
    /// Set the locationNode isHidden = true and run the animation to hide it.
    func hideLocationNode(locationNode: LocationNode, animated: Bool) {
        if animated {
            let fadeOut = SCNAction.fadeOut(duration: 0.2)
            let moveToDown = SCNAction.group([fadeOut])
            locationNode.childNodes.first?.runAction(
                moveToDown, completionHandler: {
                    locationNode.isHidden = true
            })
        }
    }
    
    func toggleLocationNode(locationNode: LocationNode) {
    
        if locationNode.isHidden {
            locationNode.runAction(SCNAction.fadeOut(duration: 0.2))
            locationNode.runAction(SCNAction.unhide())
        } else {
            locationNode.runAction(SCNAction.fadeIn(duration: 0.2))
            locationNode.runAction(SCNAction.hide())
        }
       
    }
    
    // MARK: LNTouchProtocol
    func locationNodeTouched(node: AnnotationNode) {
        if let locationAnnotationNode = node.parent as? MNLocationAnnotationNode {
            logger.info("Touched \(locationAnnotationNode.annotation.title!)")
            let annotationDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
                withIdentifier: "AnnotationDetailsVC") as! AnnotationDetailsVC
            annotationDetailsVC.title = locationAnnotationNode.annotation.title
            annotationDetailsVC.subtitle = locationAnnotationNode.annotation.subtitle
            annotationDetailsVC.wikiUrl = locationAnnotationNode.annotation.wikiUrl
            annotationDetailsVC.modalPresentationStyle = .overCurrentContext
            present(annotationDetailsVC, animated: true, completion: nil)
            
        }
    }
}

// MARK: Notification Observers
@available(iOS 11.0, *)
extension ViewController {
    func setupNotificationObservers() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(pauseSceneLocationView),
                       name: UIApplication.didEnterBackgroundNotification, object: nil)
        nc.addObserver(self, selector: #selector(resumeSceneLocationView),
                       name: UIApplication.willEnterForegroundNotification, object: nil)
        nc.addObserver(self, selector: #selector(pauseSceneLocationView),
                       name: Notification.Name("pauseSceneLocationView"), object: nil)
        nc.addObserver(self, selector: #selector(resumeSceneLocationView),
                       name: Notification.Name("resumeSceneLocationView"), object: nil)
        nc.addObserver(self, selector: #selector(updateNodes),
                       name: Notification.Name("reloadAnnotations"), object: nil)
        nc.addObserver(self, selector: #selector(orientationDidChange),
                       name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}

// MARK: SettingsViewController Delegate
@available(iOS 11.0, *)
extension ViewController: SettingsViewControllerDelegate {
    
    func changeMaxVisibility(newValue value: Int) {
        UserDefaults.standard.set(value, forKey: "maxVisibility")
        global.maxDistance = value
        self.updateNodes()
    }
    
    func scaleLocationNodesRelativeToDistance(_ shouldScale: Bool) {
        logger.info("Scale LocationNodes relative to distance.")
    }
}

/// ARSession Delegegate
@available(iOS 11.0, *)
extension ViewController: ARSessionDelegate {
   func session(_ session: ARSession, didFailWithError error: Error) {

       switch error._code {
       case 102:
           configuration.worldAlignment = .gravity
           restartSession()
           logger.error("ARKit failed with error 102. Restarted ARKit Session with gravity")
       default:
           configuration.worldAlignment = .gravityAndHeading
           restartSession()
           logger.error("ARKit failed with error Code=\(error._code). Restarting ARKit Session with gravity and heading")
       }
   }

   @objc func restartSession() {

       self.sceneLocationView.session.pause()

       self.sceneLocationView.session.run(configuration, options: [
           .resetTracking,
           .removeExistingAnchors])
   }
}
