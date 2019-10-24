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
import CoreData

@available(iOS 11.0, *)
class ViewController: UIViewController, UIGestureRecognizerDelegate {
   
    let configuration = ARWorldTrackingConfiguration()

	let maxVisibleMonuments = 30
    let config = EnvironmentConfiguration()

	/// Whether to display some debugging data. This currently displays the coordinate of the best location estimate.
	/// The initial value is respected
	var displayDebug = UserDefaults.standard.object(forKey: "switchDebugState") as? Bool ?? false

	var updateInfoLabelTimer: Timer?
	var comingFromBackground = false
	var isFirstRun = true
	var scaleRelativeToDistance = UserDefaults.standard.bool(forKey: "scaleRelativeTodistance")
    var shouldLoadMonumentsFromTree = true
    
    // Core Data
    private var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>?
	var monuments = [Monument]()
	var numberOfVisibibleMonuments = 0
    
    
    // Views
    let sceneLocationView = SceneLocationView()
    var infoLabel = UILabel()
	var countLabel = UILabel()
	var blurEffect: UIVisualEffect!
    var blurVisualEffectView: UIVisualEffectView!

	// Set IBOutlet
	@IBOutlet var noPOIsView: UIView!
    
	// ViewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()
        
        // Setup Core Data - If data did preload perform initialNodesSetup immediately, otherwise wait
        // unitle Core Data preload finishes
        fetchResultsController?.delegate = self
        if UserDefaults.standard.bool(forKey: preloadDataKey) == true {
            logger.verbose("Perform initial nodes setup")
            self.initialNodesSetup()
        }
        
		// Setup blur visual effect
        setupSceneLocationView()
        
		// Setup SceneLocationView
        setupSceneLocationView()
        
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
        infoLabel.frame = CGRect(x: 6, y: 14, width: 300, height: 56)
	}
    
    // MARK: - Setup functions
    
    private func setupSceneLocationView() {
        sceneLocationView.orientToTrueNorth = false
        sceneLocationView.stackingOffset = 5.0
        sceneLocationView.antialiasingMode = .multisampling4X
        sceneLocationView.locationNodeTouchDelegate = self
        sceneLocationView.session.delegate = self
        view.addSubview(sceneLocationView)
        view.sendSubviewToBack(sceneLocationView) // send sceneLocationView behind the IB elements
    }
    
    private func setupBlurVisualEffectView() {
        blurVisualEffectView = UIVisualEffectView(frame: view.bounds)
        blurEffect = UIBlurEffect(style: .light)
        blurVisualEffectView.isUserInteractionEnabled = false
        blurVisualEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(blurVisualEffectView)
        view.sendSubviewToBack(blurVisualEffectView)
        noPOIsView.layer.cornerRadius = 5
    }
    
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
    
    // MARK: - Utility functions
    
    @objc func resumeSceneLocationView() {
        sceneLocationView.run()
        logger.verbose("Resume sceneLoationView")
    }

    @objc func pauseSceneLocationView() {
        sceneLocationView.pause()
        saveCurrentLocation()
        logger.verbose("Pause sceneLoationView")
    }
    
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
    
    // MARK: - Animations
    
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
			self.blurVisualEffectView.effect = self.blurEffect
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
    
	// MARK: - Update debugging infoLabel
    
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

	// MARK: - Prepare for segue
    
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toSettingsVC":
            let navigationController = segue.destination as! UINavigationController
            let settingsVC = navigationController.topViewController as! SettingsVC
            settingsVC.delegate = self
        case "toCategoriesVC":
            let categoriesVC = segue.destination as! CategoriesVC
            categoriesVC.delegate = self
        default:
            ()
        }
	}

	// MARK: - Debug mode
    
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

// MARK: - Data Helpers

@available(iOS 11.0, *)
extension ViewController {
    
    /// Hide or reveal nodes based on maxDistance and selected categories
    @objc func updateNodes() {
        logger.info("Update location nodes")
        guard let currentLocation = sceneLocationView.sceneLocationManager.locationManager.currentLocation else {
            logger.error("Failed to update nodes. No current location avaiable.")
            return
        }
        
        for monument in self.monuments {
            if let categoryStatus = global.categories[monument.category!] {
                monument.isActive = categoryStatus
            }
        }
        
        let locationNodes = self.sceneLocationView.locationNodes as! [MNLocationAnnotationNode]
        
        var count = 0
        var numberOfNewVisible = 0
        var numberOfNewHidden = 0
        
        for node in locationNodes {
            let distanceFromUser = currentLocation.distance(from: node.annotation.location)
            
            // The mounument should be visible
            if distanceFromUser <= Double(global.maxDistance) && node.annotation.isActive {
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
            logger.warning("Cannot create nodes because user location not available")
            return
        }
        
        logger.debug("Loading nodes around current location...")
        
        if let monuments = FetchRequests.fetchMonumentsAroundLocation(location: currentLocation, radius: 10000) {
            for monument in monuments {
                if let categoryStatus = global.categories[monument.category!] {
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
        let nMax = (monuments.count < config.maxNumberOfVisibleMonuments) ?
            monuments.count : config.maxNumberOfVisibleMonuments
        
        let sortedMonuments = monuments.sorted(by: {
            $0.location.distance(from: location) < $1.location.distance(from: location)
        })[0..<nMax]
        
        for monument in sortedMonuments {
            group.enter() // Workaround to force the creation of an UIImage in the main thread
            let distanceFromUser = monument.location.distance(from: location)
            let isHidden = !(distanceFromUser <= Double(config.maxDistance) && monument.isActive)
            if !isHidden { count += 1 }
            nodes.append(self.buildNode(monument: monument, forLocation: location, isHidden: isHidden))
            group.leave()
        }
        group.wait() // Wait until all nodes have been created
        self.labelCounterAnimate(count: count)
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

        locationAnnotationNode.shouldStackAnnotation = true
        return locationAnnotationNode
    }
    
    private func distanceFromUser(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> Double {
        return 0
    }
}

// MARK: - LNTouchDelegate

extension ViewController: LNTouchDelegate {
    func annotationNodeTouched(node: AnnotationNode) {
        if let locationAnnotationNode = node.parent as? MNLocationAnnotationNode {
            if locationAnnotationNode.annotation.wikiUrl != nil {
                logger.info("Touched \(locationAnnotationNode.annotation.name!)")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let annotationDetailsVC = storyboard.instantiateViewController(
                    withIdentifier: "AnnotationDetailsVC") as! AnnotationDetailsVC
                annotationDetailsVC.monument = locationAnnotationNode.annotation
                
                present(annotationDetailsVC, animated: true, completion: nil)
            }
        }
    }
       
    func locationNodeTouched(node: LocationNode) {
        
    }
}

// MARK: - Categories ViewController Delegate

extension ViewController: CategoriesVCDelegate {
    func updateVisibleAnnotations(sender: UIViewController) {
        self.updateNodes()
    }
}

// MARK: - Notification Observers

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
        nc.addObserver(self, selector: #selector(orientationDidChange),
                       name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}

// MARK: - SettingsViewController Delegate

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

// MARK: - ARSession Delegate

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

// MARK: - Core Data

extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        logger.info("Data content did change")
        self.initialNodesSetup()
    }
}
