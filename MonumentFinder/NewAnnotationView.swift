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
    open var wikiLabel: UILabel?
    open var infoButton: UIButton?
    open var categoria: String?
    open var isTappable: Bool?
//    open var infoIconView: UIImageView?
    open var blurEffectView: UIVisualEffectView?

    open var arFrame: CGRect = CGRect.zero

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.titleLabel == nil {
            self.loadUi()
        }
    }
    /*
     override open func initialize()
     {
     super.initialize()
     self.loadUi()
     }*/

    func loadUi() {

        // Background setup

        self.layer.cornerRadius = self.frame.size.height / 2.0
        self.clipsToBounds = true

        self.backgroundColor = .white
        self.alpha = 0.95


        // Title label
        self.titleLabel?.removeFromSuperview()
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 16) ?? UIFont.systemFont(ofSize: 14)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        self.addSubview(label)
        self.titleLabel = label
        
        // Description label
        self.descriptionLabel?.removeFromSuperview()
        let sublabel = UILabel()
        sublabel.backgroundColor = UIColor.clear
        sublabel.numberOfLines = 2
        sublabel.textColor = UIColor.black
        sublabel.font = UIFont(name: "HelveticaNeue-Thin", size: 10) ?? UIFont.systemFont(ofSize: 10)
        self.addSubview(sublabel)
        self.descriptionLabel = sublabel


        if self.isTappable! {

            self.wikiLabel?.removeFromSuperview()
            let wLabel = UILabel()
            wLabel.text = "Wikipedia"
            wLabel.font = UIFont(name: "TrajanPro-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10)
            wLabel.textColor = UIColor.darkGray
            self.addSubview(wLabel)
            self.wikiLabel = wLabel

//            self.infoIconView?.removeFromSuperview()
//            let infoView = UIImageView(frame: CGRect(x: self.frame.maxX - 30, y: self.frame.maxY - 25, width: 14, height: 14))
//            let infoView = UIImageView()
//            infoView.image = UIImage(named: "Info_Icon")
//            self.addSubview(infoView)
//            self.infoIconView = infoView

            // Info button

            self.infoButton?.removeFromSuperview()
            let button = UIButton(frame: self.bounds)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AnnotationView.tapGesture))
            self.addGestureRecognizer(tapGesture)
            button.addGestureRecognizer(tapGesture)
            self.addSubview(button)
            self.infoButton = button // MARK: CHECK THIS!!!!!!!
        }


        if self.annotation != nil {
            self.bindUi()
        }
    }



    func layoutUi() {

        self.descriptionLabel?.frame = CGRect(x: 15, y: 20, width: self.frame.size.width - 30, height: 24);
        self.infoButton?.frame = self.bounds // MARK: CHECK THIS!!!!!!
        self.blurEffectView?.frame = self.bounds
//        self.infoIconView?.frame = CGRect(x: self.frame.width - 30, y: 25, width: 14, height: 14)
        self.wikiLabel?.frame = CGRect(x: self.bounds.maxX - 75, y: 35, width: 70, height: 10)
        // MARK: BUUUUUGGGG
    }

    // This method is called whenever distance/azimuth is set
    override open func bindUi() {

        if let annotation = self.annotation as? Annotation {
            let categoria = annotation.categoria
            let distance = annotation.distanceFromUser > 1000 ? String(format: "%.1f km", annotation.distanceFromUser / 1000) : String(format:"%.0f m", annotation.distanceFromUser)

            self.titleLabel?.text = annotation.title
            self.descriptionLabel?.text = String(format: "%@\nDistanza: %@", categoria, distance)
            self.isTappable = annotation.isTappable
        }

    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutUi()
    }


    @objc open func tapGesture() {
        if let annotation = self.annotation as? Annotation {

            print("Annotation \(String(describing: annotation.title!)) tapped.\n")

            let annotationDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AnnotationDetailsVC") as! AnnotationDetailsVC

            annotationDetailVC.titolo = annotation.title
            annotationDetailVC.categoria = annotation.categoria
            annotationDetailVC.wikiUrl = annotation.wikiUrl

            annotationDetailVC.modalPresentationStyle = .overCurrentContext

            let rootViewController = self.window?.rootViewController
            rootViewController?.present(annotationDetailVC, animated: true, completion: nil)
        }
    }
}


