//
//  ARVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 11/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import CoreLocation

class ARVC: ARViewController, ARDataSource {
    
    var annotationsArray: [ARAnnotation] = []
    
    @IBAction func presentFiltri(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        //view.window!.layer.add(transition, forKey: kCATransition)
        let filtriVC = FiltriVC()
        filtriVC.modalPresentationStyle = .overFullScreen
        view.window?.layer.add(transition, forKey: kCATransition)
        present(filtriVC, animated: false, completion: nil)
        
    }
    
    @IBAction func setMaxVisiblità(_ sender: Any) {
        
        // Ottieni il navigatvarController e previene ulteriori tocchi
        let navigationController = self.navigationController
        navigationController?.hidesBarsOnTap = false
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.isUserInteractionEnabled = false
        
        // Configura il bottone trasparente per chidere la bubble
        let bottoneTrasparente = UIButton()
        bottoneTrasparente.frame = self.view.frame
        self.view.addSubview(bottoneTrasparente)
        bottoneTrasparente.addTarget(self, action: #selector(dismiss(sender:)), for: .touchUpInside)
    
        //Disegna la bubble view sopra qualsiasi cosa
        let bubbleView = BubbleView(frame: CGRect(x: 0, y: 60, width: self.view.frame.size.width, height: 95))
        bubbleView.tag = 99
        bubbleView.backgroundColor = UIColor.clear
        let currentWindow = UIApplication.shared.keyWindow
        currentWindow?.addSubview(bubbleView)
    }
    
    func dismiss(sender: UIButton) {
        print("premuto")
        sender.removeFromSuperview()
        let currentWindow = UIApplication.shared.keyWindow
        if let bubbleView = currentWindow?.viewWithTag(99) {
            bubbleView.removeFromSuperview()
        }
        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        self.presenter.maxDistance = UserDefaults.standard.value(forKey: "maxVisibilità") as! Double
        print(annotationsArray.count)

        
        self.setAnnotations(self.createAnnotation())
        print("Visibilità impostata a \(self.presenter.maxDistance) metri.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view did load")
        
        // Present ARViewController
        self.dataSource = self
        if UserDefaults.standard.object(forKey: "maxVisibilità") != nil {
            self.presenter.maxDistance = UserDefaults.standard.value(forKey: "maxVisibilità") as! Double
        } else {
            self.presenter.maxDistance = 500
        }
        
        self.presenter.maxVisibleAnnotations = 25
        //self.headingSmoothingFactor = 0.05
        self.trackingManager.userDistanceFilter = 25
        self.trackingManager.reloadDistanceFilter = 75

        // Vertical offset by distance
        self.presenter.distanceOffsetMode = .manual
        self.presenter.distanceOffsetMultiplier = 0.1   // Pixels per meter
        self.presenter.distanceOffsetMinThreshold = 500 // Doesn't raise annotations that are nearer than this

        self.presenter.maxVisibleAnnotations = 100      // Max number of annotations on the screen
        // Stacking
        self.presenter.verticalStackingEnabled = true
        // Location precision
        self.trackingManager.userDistanceFilter = 15
        self.trackingManager.reloadDistanceFilter = 50
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
    
    // QUESTO POTREBBE ESSERE RIDONDANTE
    override func viewDidAppear(_ animated: Bool) {
        
        let global = Global()
        global.checkWhoIsVisible()
        
        annotationsArray = self.createAnnotation()
        print("\(annotationsArray.count) annotazioni visibili")
        self.setAnnotations(annotationsArray)
        
        self.navigationController?.hidesBarsOnTap = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// This method is called by ARViewController, make sure to set dataSource property.
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.frame = CGRect(x: 0,y: 0,width: 175,height: 50)
        return annotationView;
    }
    
    // MARK: Crea le annotations
    func createAnnotation() -> Array<ARAnnotation> {
        var annotations: [ARAnnotation] = []
        for monumento in monumenti {
            if monumento.isVisible {
                let title = monumento.nome + "\n" + monumento.categoria!
                let location = CLLocation(latitude: monumento.lat, longitude: monumento.lon)
                let annotation = ARAnnotation(identifier: nil, title: title, location: location)

                annotation?.categoria = monumento.categoria
                annotations.append(annotation!)
                // print(monumento.nome)
            }
        }
        return annotations
    }
    // MARK: statusBar animation
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
}
