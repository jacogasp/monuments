//
//  ViewController.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 02/10/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import SceneKit
import MapKit


@available(iOS 11.0, *)
class ViewController: UIViewController, SceneLocationViewDelegate, AugmentedRealityDataSource {
    
    var maxDistance = UserDefaults.standard.value(forKey: "maxVisibilità") as! Double
    var monumenti = [Monumento]()
    var visibleMonuments = [Monumento]()
    var numberOfVisibibleMonuments = 0
    var countLabel = UILabel()

    // Set IBOutlet
    @IBOutlet weak var locationAlertView: UIView!
    @IBAction func setMaxVisiblità(_ sender: Any) {

        // Configura il bottone trasparente per chidere la bubble
        let bottoneTrasparente = UIButton()
        bottoneTrasparente.frame = self.view.frame
        self.view.addSubview(bottoneTrasparente)
        bottoneTrasparente.addTarget(self, action: #selector(dismiss(sender:)), for: .touchUpInside)

        //Disegna la bubble view sopra qualsiasi cosa
        let width = view.frame.size.width - 50
        let yPos = view.frame.size.height - 80
        let bubbleView = BubbleView(frame: CGRect(x: 0, y: 0, width: width, height: 100))
        bubbleView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        bubbleView.center = CGPoint(x: view.frame.midX, y: yPos)
        bubbleView.tag = 99
        let currentWindow = UIApplication.shared.keyWindow
        currentWindow?.addSubview(bubbleView)
        bubbleView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.1, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            bubbleView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)


    }


    @objc func dismiss(sender: UIButton) {

        let currentWindow = UIApplication.shared.keyWindow
        if let bubbleView = currentWindow?.viewWithTag(99) {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                bubbleView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                bubbleView.alpha = 0
            }, completion: {finished in
                sender.removeFromSuperview()
                bubbleView.removeFromSuperview()
            })
        }
        // Update maxDistance and reload annotations
        maxDistance = UserDefaults.standard.value(forKey: "maxVisibilità") as! Double
        print("Visibilità impostata a \(self.maxDistance.rounded()) metri.\n")
        self.updateLocationNodes()

    }
    
    let sceneLocationView = SceneLocationView()
    
    ///Whether to display some debugging data
    ///This currently displays the coordinate of the best location estimate
    ///The initial value is respected
    var displayDebugging = false
    var infoLabel = UILabel()
    var updateInfoLabelTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup SceneLocationView

        
        //Set to true to display an arrow which points north.
        //Checkout the comments in the property description and on the readme on this.
        //        sceneLocationView.orientToTrueNorth = false
        
        //        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
        sceneLocationView.locationDelegate = self
        
        if displayDebugging {
            sceneLocationView.showFeaturePoints = false
            sceneLocationView.showAxesNode = false

            infoLabel.font = UIFont.systemFont(ofSize: 10)
            infoLabel.textAlignment = .left
            infoLabel.textColor = UIColor.white
            infoLabel.numberOfLines = 0
            sceneLocationView.addSubview(infoLabel)
            
            updateInfoLabelTimer = Timer.scheduledTimer(
                timeInterval: 0.1,
                target: self,
                selector: #selector(self.updateInfoLabel),
                userInfo: nil,
                repeats: true)
            
        }
        
        view.addSubview(sceneLocationView)
        view.sendSubview(toBack: sceneLocationView)     // send sceneLocationView behind the IB elements
        addLocationNodes()                              // Create the locationNodes in a certain MKMapRegion centered to user location
        sceneLocationView.showsStatistics = true
        
        setupCountLabel()                               // Create the UILabel that counts the visible annotations

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func  viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\nRun sceneLocationView\n")
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Pause sceneLocationView\n")
        sceneLocationView.pause()
    }
    
    override func viewDidLayoutSubviews() {
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)
        
        if displayDebugging {
            infoLabel.frame = CGRect(
                x: 6,
                y: 0,
                width: self.view.frame.size.width - 12,
                height: 14 * 4)
            infoLabel.frame.origin.y = self.view.frame.size.height - infoLabel.frame.size.height
        }
    }
    
    // MARK: Add annotationView
    
    // Fill the dataSource binding the Annotation with the AnnotationView.
    func augmentedReality(_ viewController: UIViewController, viewForAnnotation: Annotation) -> AnnotationView {
        let annotationView = AnnotationView(annotation: viewForAnnotation)
        annotationView.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        annotationView.layer.cornerRadius = annotationView.frame.size.height / 2.0
        annotationView.clipsToBounds = true
        annotationView.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        
        return annotationView
        
    }
    
    /// Create return a LocationAnnotationNode object given a Monumento object
    func setupLocationNode(monument: Monumento) -> LocationAnnotationNode{
        
        let annotation = Annotation(identifier: monument.title!, title: monument.title!, location: monument.location)
        annotation?.subtitle = monument.categoria
        if let currentLocation = sceneLocationView.locationManager.currentLocation {
            annotation?.distanceFromUser = currentLocation.distance(from: monument.location)
        }
        let annotationView = augmentedReality(self, viewForAnnotation: annotation!)
        
        let annotationImage = generateImageFromView(inputView: annotationView)
        let annotationNode = LocationAnnotationNode(location: monument.location, image: annotationImage)
        
        
        return annotationNode
    }
    
    /// Add locationNodes closer than maxDistance. Extract annotations from the quadTree object and create a UIImage for each annotation to be used in SceneLocationView.
    func addLocationNodes() {
        
        print("Adding annotations for current location:", terminator: " ")
    
        if let currentLocation = sceneLocationView.locationManager.currentLocation {
            print("(\(currentLocation.coordinate.description!))...")
            
            // Extract monuments within a MKMapRect centered on the user location.
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let coordinateRegion = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
            let rect = coordinateRegion.toMKMapRect()
            monumenti = quadTree.annotations(in: rect) as! [Monumento]
            
            // Add the annotation
            for monument in monumenti {
                let annotationNode = setupLocationNode(monument: monument)
                sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                
            }
            
            updateLocationNodes() // Check the visibility
            print("\(sceneLocationView.locationNodes.count) nodes created.")

        }
    }
    
    /// Update the locatonNodes revealing or hiding based on distanceFromUser
    func updateLocationNodes() {
        if let currentLocation = sceneLocationView.locationManager.currentLocation {
            
            // Count the number visible monuments an animate the label counter
            var count = 0
            for monument in monumenti {
                if currentLocation.distance(from: monument.location) <= maxDistance {
                    count += 1
                }
            }
            self.labelCounterAnimate(count: count)
            
            // Check if the locationNodes is visibile. Use a delay to animate one node per time
            let locationNodes = sceneLocationView.locationNodes
            var index = 0
            locationNodes.forEach{(locationNode) in
                index += 1
                self.delay(Double(index) * 0.1) {
                    let distanceFromUser = currentLocation.distance(from: locationNode.location)
                    if distanceFromUser > self.maxDistance && locationNode.isHidden == false {
                        self.hideLocationNode(locationNode: locationNode, animated: true)
                    }
                    if distanceFromUser <= self.maxDistance && locationNode.isHidden == true {
                        self.revealLocationNode(locationNode: locationNode, animated: true)
                    }
                }
            }
        } else {
            print("Failed to updateLocationNodes(): no location.\n")
        }
       
    }
    
    /// Set the locationNode isHidden = false and run the animation to reveal it.
    func revealLocationNode(locationNode: LocationNode, animated: Bool) {
        locationNode.isHidden = false
        locationNode.opacity = 0.0
        locationNode.childNodes.first?.position = SCNVector3(x: 0, y: 10, z: 0)

        if animated {
            // let scaleOut = SCNAction.scale(by: 3, duration: 0.5)
            let fadeIn = SCNAction.fadeIn(duration: 0.2)
            let moveIn = SCNAction.moveBy(x: 0, y: -10, z: 0, duration: 0.2)
            let moveFromTop = SCNAction.group([fadeIn, moveIn])
            locationNode.childNodes.first?.runAction(moveFromTop)
            locationNode.runAction(fadeIn)
        }
    }
    
    /// Set the locationNode isHidden = true and run the animation to hide it.
    func hideLocationNode(locationNode: LocationNode, animated: Bool) {
        
        if animated {
            // let scaleOut = SCNAction.scale(by: 3, duration: 0.5)
            let fadeOut = SCNAction.fadeOut(duration: 0.2)
            let moveOut = SCNAction.moveBy(x: 0, y: -10, z: 0, duration: 0.2)
            let moveToDown = SCNAction.group([fadeOut, moveOut])
            locationNode.childNodes.first?.runAction(moveToDown, completionHandler: {
                locationNode.isHidden = true
            })
        }
    }
    
    /// Convert a UIView to a UIImage
    func generateImageFromView(inputView: UIView) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.drawHierarchy(in: inputView.bounds, afterScreenUpdates: true)
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return uiImage
    }
    
    /// Delay the exectution of the inner block (in seconds).
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
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
        countLabel.font = UIFont(name: defaultFontName, size: 12)
        countLabel.textAlignment = .center
    }
    
    /// Drop down the label counter for visible objects. count: number of item to count
    func labelCounterAnimate(count: Int) {
        
        if count > 0 {
            countLabel.text = "\(count) oggetti visibili"
        } else {
            countLabel.text = "Nessun oggetto visibile"
        }
        
        let oldCenter = CGPoint(x: view.bounds.width / 2, y: -countLabel.bounds.height)
        print("center: \(countLabel.center), oldCenter: \(oldCenter)")
        
        if !view.subviews.contains(countLabel) {
            countLabel.center = oldCenter

            view.addSubview(countLabel)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.countLabel.center = CGPoint(x: self.view.bounds.width / 2, y: 50)
            }, completion: { finished in
                UIView.animate(withDuration: 0.3, delay: 2, options: .curveEaseInOut, animations: {
                    self.countLabel.center = oldCenter
                }, completion: {finished in
                    self.countLabel.removeFromSuperview()
                })
            })
        }
    }
    
    // MARK: Update debugging infoLabel
    
    @objc func updateInfoLabel() {
        if displayDebugging {
            if let position = sceneLocationView.currentScenePosition() {
                infoLabel.text = "x: \(String(format: "%.2f", position.x)), y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
            }
            
            if let eulerAngles = sceneLocationView.currentEulerAngles() {
                infoLabel.text!.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
            }
            
            if let heading = sceneLocationView.locationManager.heading,
                let accuracy = sceneLocationView.locationManager.headingAccuracy {
                infoLabel.text!.append("Heading: \(heading)º, accuracy: \(Int(round(accuracy)))º\n")
            }
            
            let date = Date()
            let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
            
            if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
                infoLabel.text!.append("\(String(format: "%02d", hour)):\(String(format: "%02d", minute)):\(String(format: "%02d", second)):\(String(format: "%03d", nanosecond / 1000000))")
            }
        }
    }
    
    // MARK: SceneLocationViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        // print("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        // print("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
        
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }

}

// MARK: Extensions

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
    }
}

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        
        for subview in subviews {
            recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
        }
        
        return recursiveSubviews
    }
}

// MARK: Convert MKCoordinateRegion to MKMapRect
extension MKCoordinateRegion {
    func toMKMapRect() -> MKMapRect {
        let region = self
        let topLeft = CLLocationCoordinate2D(
            latitude: region.center.latitude + (region.span.latitudeDelta/2.0),
            longitude: region.center.longitude - (region.span.longitudeDelta/2.0)
        )
        
        let bottomRight = CLLocationCoordinate2D(
            latitude: region.center.latitude - (region.span.latitudeDelta/2.0),
            longitude: region.center.longitude + (region.span.longitudeDelta/2.0)
        )
        
        let topLeftMapPoint = MKMapPointForCoordinate(topLeft)
        let bottomRightMapPoint = MKMapPointForCoordinate(bottomRight)
        
        let origin = MKMapPoint(x: topLeftMapPoint.x,
                                y: topLeftMapPoint.y)
        let size = MKMapSize(width: fabs(bottomRightMapPoint.x - topLeftMapPoint.x),
                             height: fabs(bottomRightMapPoint.y - topLeftMapPoint.y))
        
        return MKMapRect(origin: origin, size: size)
    }
    
}

extension UIImage{
    convenience init(view: UIView) {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
        
    }
}

extension CLLocationCoordinate2D {
    func isEqual(_ coord: CLLocationCoordinate2D) -> Bool {
        return (fabs(self.latitude - coord.latitude) < .ulpOfOne) && (fabs(self.longitude - coord.longitude) < .ulpOfOne)
    }
}

extension CLLocationCoordinate2D {
    var description: String? {
        return "\(round(self.latitude * 100) / 100), \(round(self.longitude * 100) / 100)"
    }
}


