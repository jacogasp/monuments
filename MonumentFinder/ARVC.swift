//
//  testVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 11/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import CoreLocation

class ARVC: ARViewController, ARDataSource {


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
        
        self.maxDistance = UserDefaults.standard.value(forKey: "maxVisibilità") as! Double
        self.reloadAnnotations()
        
        print("Visibilità impostata a \(self.maxDistance) metri.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present ARViewController
        self.dataSource = self
        if UserDefaults.standard.object(forKey: "maxVisibilità") != nil {
            self.maxDistance = UserDefaults.standard.value(forKey: "maxVisibilità") as! Double
        } else {
            self.maxDistance = 500
        }
        self.maxVisibleAnnotations = 25
        self.maxVerticalLevel = 5
        self.headingSmoothingFactor = 0.05
        self.trackingManager.userDistanceFilter = 25
        self.trackingManager.reloadDistanceFilter = 75
        self.uiOptions.debugEnabled = false
        self.uiOptions.closeButtonEnabled = false
        
  //      UIApplication.shared.keyWindow!.bringSubview(toFront: navigationBar)
        //arViewController.interfaceOrientationMask = .landscape
//        self.onDidFailToFindLocation =
//            {
//                [weak self, weak self] elapsedSeconds, acquiredLocationBefore in
//                
//                self?.handleLocationFailure(elapsedSeconds: elapsedSeconds, acquiredLocationBefore: acquiredLocationBefore, arViewController: self)
//        }
    }
    
    // QUESTO POTREBBE ESSERE RIDONDANTE
    override func viewDidAppear(_ animated: Bool) {
        
        //checkWhichAnnotationAreVisible()
        let global = Global()
        global.checkWhoIsVisible()
        
        let annotations = self.createAnnotation()
        self.setAnnotations(annotations)
        self.reloadAnnotations()
        
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
                let annotation = ARAnnotation()
                annotation.title = monumento.tags["name"]! + "\n" + monumento.categoria!
                annotation.location = CLLocation(latitude: Double(monumento.lat)!, longitude: Double(monumento.lon)!)
                annotation.categoria = monumento.categoria
                annotations.append(annotation)
                print(monumento.tags["name"]!)
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
