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
    
    var annotationsArray: [Annotation] = []
    var shouldLoadDb = true
    
    
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
        
        //print("premuto")
        
        let currentWindow = UIApplication.shared.keyWindow
       if let bubbleView = currentWindow?.viewWithTag(99) {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
                bubbleView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }, completion: {finished in
                sender.removeFromSuperview()
                bubbleView.removeFromSuperview()
            })
        }
        
        self.presenter.maxDistance = UserDefaults.standard.value(forKey: "maxVisibilità") as! Double
        print(annotationsArray.count)
        
        self.setAnnotations(self.createAnnotation())
        print("Visibilità impostata a \(self.presenter.maxDistance) metri.\n")
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("view did load")
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: Notification.Name("reloadAnnotations"), object: nil, queue: nil) { notification in
            self.reloadAnnotations()
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
        self.presenter.distanceOffsetMode = .automaticOffsetMinDistance
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
        
        
        if (shouldLoadDb && selectedCity != "") { // Viene eseguito solo all'avvio
            loadDb()
        }
        reloadAnnotations()
        // MARK: TODO Handle failing
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if (shouldLoadDb && selectedCity == "") { // Viene eseguito solo all'avvio, in caso nessuna città sia selezionata
            showAlert()
        }

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
        
        var annotations: [Annotation] = []
        for monumento in monumenti {
            if monumento.isActive {
                let title = monumento.nome
                let location = CLLocation(latitude: monumento.lat, longitude: monumento.lon)
                let annotation = Annotation(identifier: nil, title: title, location: location)
                annotation?.categoria = monumento.categoria!
                annotation?.isTappable = monumento.hasWiki
                annotations.append(annotation!)
                // print(monumento.nome)
            }
        }
        return annotations
        
    }
    
    
    func reloadAnnotations() {
        
        print("Reloading annotations...")
        let global = Global()
        global.checkWhoIsVisible()
        annotationsArray = []
        annotationsArray = self.createAnnotation()
        
        self.setAnnotations(annotationsArray)
        print("\(annotationsArray.count) annotazioni attive aggiornate.\n")
        
    }
    
    
    func loadDb() {
    
        print("\nLoading database...")
        
        let monumentiReader = MonumentiClass()
        monumentiReader.leggiDatabase(city: selectedCity)
        print("Città: \(selectedCity). Monumenti letti dal database: \(monumenti.count).\n")
        
        shouldLoadDb = false
        
    }
    
    
    func showAlert() {
        
        print("Nessuna città selezionata.")
        
        let message = "Nessuna città selezionata. Seleziona una città nelle impostazioni per visualizzare i monumenti che ti circondano."
        
        let alertController = UIAlertController(title: "Seleziona città", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let attributedString = NSMutableAttributedString(string: message, attributes: [NSAttributedStringKey.font: defaultFont])
        alertController.setValue(attributedString, forKey: "attributedMessage")
        
        let action = UIAlertAction(title: "Ho capito", style: UIAlertActionStyle.default, handler: nil)
        
        alertController.addAction(action)
        
        self.present(alertController, animated: true) {
            print("Alert controller presentato")
        }
            
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for segue")
        
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
