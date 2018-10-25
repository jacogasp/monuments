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
class ViewController: UIViewController, UIGestureRecognizerDelegate {
    let sceneLocationView = SceneLocationView()

	let maxVisibleMonuments = 30

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

	// lazy var oldUserLocation = UserDefaults.standard.object(forKey: "oldUserLocation") as? CLLocation
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
		print("viewDidLoad\n")
		// Setup blur visual effect
		effect = blurVisualEffectView.effect
		blurVisualEffectView.effect = nil
		noPOIsView.layer.cornerRadius = 5
		blurVisualEffectView.isUserInteractionEnabled = false
        
		// Setup SceneLocationView
		// Set to true to display an arrow which points north.
		sceneLocationView.orientToTrueNorth = false
		sceneLocationView.locationDelegate = self
        
		view.addSubview(sceneLocationView)
		view.sendSubview(toBack: sceneLocationView) // send sceneLocationView behind the IB elements
		
		sceneLocationView.antialiasingMode = .multisampling4X

		setupCountLabel()                          // Create the UILabel that counts the visible annotations
        setupNotificationObservers()               // Setup Notification Observers

		let tapRecognizer = UITapGestureRecognizer()
		tapRecognizer.numberOfTapsRequired = 1
		tapRecognizer.numberOfTouchesRequired = 1
		tapRecognizer.addTarget(self, action: #selector(sceneTapped))
		sceneLocationView.gestureRecognizers = [tapRecognizer]

		shouldDisplayDebugAtStart()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		print("\nViewWillAppear")
		print("Run sceneLocationView\n")
		sceneLocationView.run()
	}

	override func viewDidDisappear(_ animated: Bool) {
		print("viewDidDisappear")
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		print("View will disappear")
		print("Pause sceneLocationView\n")
		sceneLocationView.pause()
	}

	override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
		sceneLocationView.frame = view.bounds
		infoLabel.frame = CGRect(x: 6, y: 0, width: 300, height: 14 * 4)
		infoLabel.center = CGPoint(x: view.center.x, y: view.frame.height - infoLabel.frame.height / 2)
	}

	@objc func resumeSceneLocationView() {
		sceneLocationView.run()
		print("Resume sceneLoationView\n")
	}

	@objc func pauseSceneLocationView() {
		sceneLocationView.pause()
		if let currentLocation = sceneLocationView.currentLocation() {
			let archivedUserLocation = NSKeyedArchiver.archivedData(withRootObject: currentLocation)
			UserDefaults.standard.set(archivedUserLocation, forKey: "oldUserLocation")
			print("oldUserLocation successfully saved.")
		} else {
			print("Failed to save oldUserLocation")
		}
		print("Pause sceneLoationView\n")
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

	// MARK: Update counterLabel
	func setupCountLabel() {
		countLabel.frame = CGRect(x: 0, y: 0, width: 210, height: 20)
		countLabel.center = CGPoint(x: view.bounds.size.width / 2, y: -countLabel.frame.height)
		countLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
		countLabel.layer.cornerRadius = countLabel.frame.height / 2.0
		countLabel.clipsToBounds = true
		countLabel.layer.borderColor = UIColor.black.cgColor
		countLabel.layer.borderWidth = 0.5
		countLabel.font = UIFont(name: global.defaultFontName, size: 12)
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

	// MARK: Handle tap gestures
	@objc func sceneTapped(recognizer: UITapGestureRecognizer) {
		let location = recognizer.location(in: sceneLocationView)
		print("Tap at location: \(location)\n")

		let options = [
			SCNHitTestOption.backFaceCulling: false,
			SCNHitTestOption.firstFoundOnly: false,
			SCNHitTestOption.ignoreChildNodes: false,
			SCNHitTestOption.clipToZRange: false,
			SCNHitTestOption.ignoreHiddenNodes: false
		]
		let hitResults = sceneLocationView.hitTest(location, options: options)
		print(hitResults)
		for hit in hitResults {
			if let hitnode = hit.node.parent as? MNLocationAnnotationNode {
				print("\(hitnode.annotation.title!) \(hitnode.position)")
				let annotationDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
					withIdentifier: "AnnotationDetailsVC") as! AnnotationDetailsVC

				annotationDetailsVC.title = hitnode.annotation.title
				annotationDetailsVC.subtitle = hitnode.annotation.subtitle
				annotationDetailsVC.wikiUrl = hitnode.annotation.wikiUrl
				annotationDetailsVC.modalPresentationStyle = .overCurrentContext
				present(annotationDetailsVC, animated: true, completion: nil)
			} else {
				print("result is not MNLocationAnnotationNode")
			}
		}
	}

	// MARK: Update debugging infoLabel
	@objc func updateInfoLabel() {
		if let position = sceneLocationView.currentScenePosition() {
			infoLabel.text = "x: \(String(format: "%.2f", position.x)), " +
			"y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
		}

		if let eulerAngles = sceneLocationView.currentEulerAngles() {
			infoLabel.text!.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), " +
				"y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
		}

		if let heading = sceneLocationView.locationManager.heading,
			let accuracy = sceneLocationView.locationManager.headingAccuracy {
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
		print("prepare")
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
			print("display AR Debug\r")
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
			print("Enable Debug AR")
			sceneLocationView.debugOptions = []
			infoLabel.removeFromSuperview()
			updateInfoLabelTimer?.invalidate()
		}
	}

	func displayDebugFeatures(isVisible: Bool) {
		if isVisible {
			print("Enable Debug Features")
			sceneLocationView.showsStatistics = true
		} else {
			print("Disable Debug Features")
			sceneLocationView.showsStatistics = false
		}
	}
}

// MARK: Data Helpers
@available(iOS 11.0, *)
private extension ViewController {
    
    /// Hide or reveal nodes based on maxDistance and selected categories
    @objc func updateNodes() {
        print("Update location nodes")
        guard let currentLocation = sceneLocationView.currentLocation() else {
            print("Failed to update nodes. No current location avaiable.")
            return
        }
        global.updateMonumentsState(forMonumentsList: self.monuments)
        let locationNodes = self.sceneLocationView.locationNodes as! [MNLocationAnnotationNode]
        var count = 0
        for node in locationNodes {
            let distanceFromUser = currentLocation.distance(from: node.annotation.location)
            // The mounument should be visible
            if distanceFromUser <= Double(global.maxDistance) && node.annotation.isActive {
                count += 1
                if node.isHidden { self.revealLocationNode(locationNode: node, animated: true) }
            } else {
                // The monument should be hidden
                if !node.isHidden { self.hideLocationNode(locationNode: node, animated: true)}
            }
        }
        self.labelCounterAnimate(count: count)
        print("\(count) visible monuments")
    }

    // Extract monuments within a MKMapRect centered on the user location.
    func loadMonumentsAroundLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  global.mkRegionSpanMeters,
                                                                  global.mkRegionSpanMeters)
        let rect = coordinateRegion.toMKMapRect()
        monuments = quadTree.annotations(in: rect) as! [MNMonument]
        print("Loaded \(monuments.count) element around current location.")
        // Set the distance between each monument and the user location
        for monument in monuments {
            monument.distanceFromUser = monument.location.distance(from: location)
        }
    }
    
    /// Add a list of nodes
    func buildNodes(forLocation location: CLLocation) -> [LocationAnnotationNode] {
        var count = 0
        var nodes: [LocationAnnotationNode] = []
        let group = DispatchGroup()
        let nMax = (monuments.count < global.maxNumberOfVisibleMonuments) ?
            monuments.count : global.maxNumberOfVisibleMonuments
        let sortedMonuments = monuments.sorted(by: {$0.distanceFromUser < $1.distanceFromUser })[0..<nMax]
        for monument in sortedMonuments {
            group.enter() // Workaround to force the creation of an UIImage in the main thread
            let distanceFromUser = monument.location.distance(from: location)
            let isHidden = !(distanceFromUser <= Double(global.maxDistance) && monument.isActive)
            if !isHidden { count += 1 }
            nodes.append(self.buildNode(monument: monument, isHidden: isHidden))
            group.leave()
        }
        group.wait() // Wait until all nodes have been created
        self.labelCounterAnimate(count: count)
        print("\(count) visible monuments")
        return nodes
    }
    
    /// Return a single LocationNode for a givend Monument
    func buildNode(monument: MNMonument, isHidden: Bool) -> MNLocationAnnotationNode {
        let annotationView = LocationNodeView(annotation: monument)
        annotationView.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        annotationView.layer.cornerRadius = annotationView.frame.size.height / 2.0
        annotationView.clipsToBounds = true
        annotationView.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        return MNLocationAnnotationNode(annotation: monument, image: annotationView.generateImage(), isHidden: isHidden)
    }
    
    /// Set the locationNode isHidden = false and run the animation to reveal it.
    func revealLocationNode(locationNode: LocationNode, animated: Bool) {
        locationNode.isHidden = false
        locationNode.opacity = 0.0
        
        if animated {
            let fadeIn = SCNAction.fadeIn(duration: 0.2)
            let moveFromTop = SCNAction.group([fadeIn])
            locationNode.childNodes.first?.runAction(moveFromTop)
            locationNode.runAction(fadeIn)
        }
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
}

// MARK: SceneLocationViewDelegate
@available(iOS 11.0, *)
extension ViewController: SceneLocationViewDelegate {
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView,
                                                      position: SCNVector3, location: CLLocation) {
        // Populate Nodes
        if shouldLoadMonumentsFromTree {
            self.shouldLoadMonumentsFromTree = false
            print("Populate nodes")
            self.loadMonumentsAroundLocation(location: location)
            global.updateMonumentsState(forMonumentsList: self.monuments)
            self.buildNodes(forLocation: location).forEach { node in
                sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: node)
            }
            print("Done")
        }
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(
        sceneLocationView: SceneLocationView, position: SCNVector3,
        location: CLLocation) {

    }
    
    func sceneLocationViewDidAddLocationNode(sceneLocation View: SceneLocationView, locationNode: LocationNode) {

    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
  
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        print("SceneNode setup completed.")
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView,
                                                                  locationNode: LocationNode) {

    }
}

// MARK: Notification Observers
@available(iOS 11.0, *)
extension ViewController {
    func setupNotificationObservers() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(pauseSceneLocationView),
                       name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        nc.addObserver(self, selector: #selector(resumeSceneLocationView),
                       name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        nc.addObserver(self, selector: #selector(pauseSceneLocationView),
                       name: Notification.Name("pauseSceneLocationView"), object: nil)
        nc.addObserver(self, selector: #selector(resumeSceneLocationView),
                       name: Notification.Name("resumeSceneLocationView"), object: nil)
        nc.addObserver(self, selector: #selector(updateNodes),
                       name: Notification.Name("reloadAnnotations"), object: nil)
        nc.addObserver(self, selector: #selector(orientationDidChange),
                       name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
}

// MARK: SettingsViewController Delegate
@available(iOS 11.0, *)
extension ViewController: SettingsViewControllerDelegate {
    func scaleLocationNodesRelativeToDistance(_ shouldScale: Bool) {
        print("scale Locationnodes relative to distance.\n")
    }
}

// MARK: UIView to UIImage
extension UIView {
    /// Convert the UIView to an UIImage
    func generateImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return uiImage
    }
}
