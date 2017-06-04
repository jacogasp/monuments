//
//  AnnotationView.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 07.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//


import UIKit

open class AnnotationView: ARAnnotationView, UIGestureRecognizerDelegate {
    open var titleLabel: UILabel?
    open var descriptionLabel: UILabel?
    open var infoButton: UIButton?
    open var categoria: String?
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.titleLabel == nil {
            self.loadUi()
        }
    }
    
    func loadUi() {
        
        // Background setup
        self.backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(blurEffectView)
        
        // Title label
        self.titleLabel?.removeFromSuperview()
        self.descriptionLabel?.removeFromSuperview()
        let label = UILabel()
        let sublabel = UILabel()
        
    
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 16) ?? UIFont.systemFont(ofSize: 14)
        //label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        self.addSubview(label)
        self.titleLabel = label
        
        // Description label
        sublabel.backgroundColor = UIColor.clear
        sublabel.numberOfLines = 2
        sublabel.textColor = UIColor.white
        self.addSubview(sublabel)
        self.descriptionLabel = sublabel

        
        sublabel.font = UIFont(name: "HelveticaNeue-Thin", size: 10) ?? UIFont.systemFont(ofSize: 10)
        
        // Info button
        
        self.infoButton?.removeFromSuperview()
        let button = UIButton(frame: self.bounds)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AnnotationView.tapGesture))
        self.addGestureRecognizer(tapGesture)
        button.addGestureRecognizer(tapGesture)
        
        self.addSubview(button)
        
        
        if self.annotation != nil
        {
            self.bindUi()
        }
    }
    
    func layoutUi() {
        
        self.titleLabel?.frame = CGRect(x: 7.5, y: 2, width: self.frame.size.width  - 15, height: 20);
        self.descriptionLabel?.frame = CGRect(x: 7.5, y: 20, width: self.frame.size.width  - 15, height: 24);
    }
    
    // This method is called whenever distance/azimuth is set
    override open func bindUi() {
        
        if let annotation = self.annotation, let title = annotation.title, let categoria = annotation.categoria {
            
            let distance = annotation.distanceFromUser > 1000 ? String(format: "%.1f km", annotation.distanceFromUser / 1000) : String(format:"%.0f m", annotation.distanceFromUser)
            
            self.titleLabel?.text = title
            self.descriptionLabel?.text = String(format: "Categoria: %@\nDistanza: %@", categoria, distance)
            self.categoria = categoria
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutUi()
    }
    
    
    
    
    open func tapGesture() {
        if let annotation = annotation {
            print("Annotation \(String(describing: annotation.title!)) tapped.\n")
            
            let annotationDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AnnotationDetailsVC") as! AnnotationDetailsVC
            
            annotationDetailVC.titolo = annotation.title
            annotationDetailVC.categoria = annotation.categoria
            
            annotationDetailVC.modalPresentationStyle = .overCurrentContext
            
            let rootViewController = self.window?.rootViewController
            rootViewController?.present(annotationDetailVC, animated: true, completion: nil)
            //rootViewController?.performSegue(withIdentifier: "toDetailAnnotationsVC", sender: nil)
        }
    }
}
