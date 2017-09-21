//
//  ARVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 11/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import MapKit
import ClusterKit



class ARVC: ARViewController, ARDataSource {
    
    var annotationsArray: Array<Annotation> = []
    var shouldLoadDb = true

    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var shouldUpdateUserLocation = true

    @IBOutlet weak var locationAlertView: UIView!
    
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var viewCounter: UIView!
    
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
        
        self.presenter.maxDistance = UserDefaults.standard.value(forKey: "maxVisibilità") as! Double
        self.setAnnotations(self.createAnnotation())
        
        print("Visibilità impostata a \(self.presenter.maxDistance.rounded()) metri.")
        print("\(self.presenter.visibleAnnotationViews.count) annotazioni visibili.\n")
        self.labelCounterAnimateIn()
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set notification center
        let nc = NotificationCenter.default
        
        nc.addObserver(forName: Notification.Name("reloadAnnotations"), object: nil, queue: nil) { notification in
            self.reloadAnnotations()
        }
        
        nc.addObserver(forName: Notification.Name("appWillEnterForeground"), object: nil, queue: nil) { notification in
            self.shouldUpdateUserLocation = true
            self.animateIn()
            nc.removeObserver(self, name: Notification.Name("appWillEnterForeground"), object: nil)
        }
        
        // Present ARViewController
        self.dataSource = self
        if UserDefaults.standard.object(forKey: "maxVisibilità") != nil {
            self.presenter.maxDistance = UserDefaults.standard.value(forKey: "maxVisibilità") as! Double
        } else {
            self.presenter.maxDistance = 500
        }
        
        //self.headingSmoothingFactor = 0.05
        self.trackingManager.userDistanceFilter = 25
        self.trackingManager.reloadDistanceFilter = 75
        
        // Vertical offset by distance
        self.presenter.distanceOffsetMode = .none
        self.presenter.distanceOffsetMultiplier = 0.1   // Pixels per meter
        self.presenter.distanceOffsetMinThreshold = 500 // Doesn't raise annotations that are nearer than this
        self.presenter.maxVisibleAnnotations = 100      // Max number of annotations on the screen
        // Stacking
        self.presenter.verticalStackingEnabled = true
        self.presenter.bottomBorder = 0.5
        // Location precision
        self.trackingManager.userDistanceFilter = 15
        self.trackingManager.reloadDistanceFilter = 50
        //self.trackingManager.minimumHeadingAccuracy = 120
        self.trackingManager.allowCompassCalibration = true
        self.trackingManager.headingFilterFactor = 0.1
        // Ui
        self.uiOptions.closeButtonEnabled = false
        // Debugging
        self.uiOptions.debugLabel = false
        self.uiOptions.debugMap = false
        self.uiOptions.simulatorDebugging = Platform.isSimulator
        self.uiOptions.setUserLocationToCenterOfAnnotations = Platform.isSimulator
        // Interface orientation
        self.interfaceOrientationMask = .all


        // MARK: TODO Handle failing
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /// This method is called by ARViewController, make sure to set dataSource property.
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.frame = CGRect(x: 0,y: 0,width: 150, height: 50)
        annotationView.layer.cornerRadius = 2
        annotationView.clipsToBounds = true
        return annotationView;
    }
    
    // MARK: Crea le annotations
    
    func createAnnotation() -> Array<Annotation> {
        
        
        let span = MKCoordinateSpanMake(0.2, 0.2)
        let coordinateRegion = MKCoordinateRegion(center: (userLocation?.coordinate)!, span: span)
        let rect = coordinateRegion.toMKMapRect()
        let monumenti = quadTree.annotations(in: rect) as! [Monumento]
        
        let activeMonuments = selectActiveMonuments(in: monumenti)
        
        var annotations: [Annotation] = []
        for monumento in activeMonuments {
            let monumento = monumento
            let title = monumento.title
            let location = CLLocation(latitude: monumento.coordinate.latitude, longitude: monumento.coordinate.longitude)
            let annotation = Annotation(identifier: nil, title: title!, location: location)
            annotation?.categoria = monumento.categoria!
            let hasWiki: (Monumento) -> (Bool) = { monumento in
                return (monumento.wikiUrl?.isEmpty)! ? false : true
            }
            annotation?.wikiUrl = monumento.wikiUrl
            annotation?.isTappable = hasWiki(monumento)
            annotations.append(annotation!)
        }
        
        return annotations
        
    }
    
    
    func reloadAnnotations() {
        
        print("Reloading annotations...")
        annotationsArray = []
        annotationsArray = self.createAnnotation()

        self.setAnnotations(annotationsArray)
        print("\(annotationsArray.count) annotazioni attive aggiornate.\n")

    }
    
    func selectActiveMonuments(in monuments: [Monumento]) -> [Monumento] {
        print("Select active monuments. ")
        let filtriAttivi = filtri.filter{$0.selected}.map{$0.osmtag}

        var activeMonuments = [Monumento]()
        print("Check visibilità di \(monuments.count) oggetti per categoria... ", terminator: "")
        for monument in monuments {
            monument.isActive = false
            let osmtag = monument.osmtag
            for filtro in filtriAttivi {
                if osmtag == filtro {
                    activeMonuments.append(monument)
                }
            }
        }
        
        print("\(activeMonuments.count) oggetti attivi.")
        return activeMonuments
    }

    override func arTrackingManager(_ trackingManager: ARTrackingManager, didUpdateUserLocation location: CLLocation) {
        super.arTrackingManager(trackingManager, didUpdateUserLocation: location)
        if shouldUpdateUserLocation {
            self.userLocation = location
            self.reloadAnnotations()
            self.animateOut()
            shouldUpdateUserLocation = false
        }
    }

    
    // Animate locationViewAlert pop-up
    func animateIn() {
        locationAlertView.center = view.center
        view.addSubview(locationAlertView)
        locationAlertView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        locationAlertView.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations:{
            self.locationAlertView.transform = .identity
            self.locationAlertView.alpha = 1
        }, completion: nil)
        
    }
    
    func animateOut() {
        
        UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseOut, animations: {
            self.locationAlertView.alpha = 0
            self.locationAlertView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: { finished in
            self.locationAlertView.removeFromSuperview()
        })
    }
    
    // Label counter visible annotations
    
    func labelCounterAnimateIn() {
        
        countLabel.alpha = 0.8
        countLabel.layer.borderColor = UIColor.black.cgColor
        countLabel.layer.borderWidth = 0.5
        let count = self.presenter.activeAnnotations.count
        if count > 0 {
            countLabel.text = "\(count) oggetti visibili"
        } else {
            countLabel.text = "Nessun oggetto visibile"
        }
        let oldCenter = CGPoint(x: view.bounds.width / 2, y: -countLabel.bounds.height)
        countLabel.center = oldCenter
        view.addSubview(countLabel)

        //countLabel.transform = CGAffineTransform.init(translationX: 0, y: -50 - countLabel.bounds.height)

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.countLabel.center = CGPoint(x: self.view.bounds.width / 2, y: 50)
        }, completion: { finished in
            UIView.animate(withDuration: 0.3, delay: 2, options: .curveEaseInOut, animations: {
                self.countLabel.center = oldCenter
            }, completion: {finishe in
                self.countLabel.removeFromSuperview()
            })
        })
    }
    

    override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
        return true
    }
    
    
    // Status bar settigs
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}



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
