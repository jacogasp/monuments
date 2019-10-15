//
//  OnboardingViewController.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 09/10/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var slides: [OnboardingSlideView] = []
    private let locationManager = CLLocationManager()
    public var authorizationsNeeded = [AuthorizationRequestType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        locationManager.delegate = self
        
        slides = createOnboardingSlideViews(for: authorizationsNeeded)
        setupScrollView(forSlides: slides)
        
        if slides.count > 1 {
            pageControl.numberOfPages = slides.count
            pageControl.currentPage = 0
            view.bringSubviewToFront(pageControl)
        } else {
            pageControl.removeFromSuperview()
        }
        
        displayAlertIfNeeded(for: .location)
        displayAlertIfNeeded(for: .camera)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewDidAppear")
//        displayAlertIfNeeded(for: .location)
//        displayAlertIfNeeded(for: .camera)
    }
    
    private func presentViewController() {
        self.performSegue(withIdentifier: "toViewController", sender: self)
    }
    
    private func showAlertToSettings(for requestType: AuthorizationRequestType) {
        
        var title = ""
        var message = ""
        
        switch requestType {
        case .location:
            title = "Location Services required"
            message = "Please go to Settings to allow permission"
        case .camera:
            title = "Camera Access required"
            message = "Please go to Settings to allow access to camera"
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        // redirect the users to settings
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Onboarding Slides
    
    /// Create onboarding slides view according to authorization statues
    func createOnboardingSlideViews(for requestTypes: [AuthorizationRequestType]) -> [OnboardingSlideView] {
        
        var slides: [OnboardingSlideView] = []
        
        for requestType in requestTypes {
            
            let slide = Bundle.main.loadNibNamed("OnboardingSlide", owner: self, options: nil)?.first as! OnboardingSlideView
            
            switch requestType {
            case .location:
                slide.imageView.image = #imageLiteral(resourceName: "LocalizationService")
                slide.titleLabel.text = "Location Services"
                slide.descriptionLabel.text = "Monuments requires access to your location to find objects around you"
                slide.button.setTitle("Enable Location Services", for: .normal)
                slide.button.addTarget(self, action: #selector(self.requestLocationAuthorization(_:)), for: .touchUpInside)
            case .camera:
                slide.imageView.image = #imageLiteral(resourceName: "Camera")
                slide.titleLabel.text = "Camera Access"
                slide.descriptionLabel.text = "Monuments requires access to the front camera fo show you objectes with Augmented Reality"
                slide.button.setTitle("Enable Camera", for: .normal)
                slide.button.addTarget(self, action: #selector(self.requestCameraAccess(_:)), for: .touchUpInside)
            }
            slides.append(slide)
        }
        
        return slides
    }
    
    
    private func setupScrollView(forSlides slides: [OnboardingSlideView]) {
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        
        scrollView.isPagingEnabled = true
        
        for i in 0..<slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0,
                                     width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    // MARK: - Authorization Requests
    
    private func displayAlertIfNeeded(for requestType: AuthorizationRequestType) {
        switch requestType {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            if status == .denied || status == .restricted {
                showAlertToSettings(for: .camera)
            }
        case .location:
            let status = CLLocationManager.authorizationStatus()
            if status == .denied || status == .restricted {
                showAlertToSettings(for: .location)
            }
        }
    }
    
    @objc private func requestLocationAuthorization(_ sender: Any) {
        logger.info("Request location authorizaton")
        locationManager.requestWhenInUseAuthorization()
    }
    
    @objc private func requestCameraAccess(_ sender: Any) {
        logger.info("Request camera access")
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                self.presentViewController()
            } else {
//                self.showAlertToSettings(for: .camera)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate

extension OnboardingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if slides.count > 1 {
            let pageIndex = round(scrollView.contentOffset.x / self.view.frame.width)
            pageControl.currentPage = Int(pageIndex)
            
            let maximumHorizontalOffset = scrollView.contentSize.width - scrollView.frame.width
            let currentHorizontalOffset = scrollView.contentOffset.x
            
            // vertical
            let maximumVerticalOffset = scrollView.contentSize.height - scrollView.frame.height
            let currentVerticalOffset = scrollView.contentOffset.y
            
            let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
            let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
            
            let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
            slides[0].imageView.transform = CGAffineTransform(scaleX: (0.5 - percentOffset.x) / 0.5,
                                                              y: (0.5 - percentOffset.x) / 0.5)
            slides[1].imageView.transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension OnboardingViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if slides.count > 1 {
                scrollView.scrollRectToVisible(CGRect(x: view.frame.width,
                                                      y: 0,
                                                      width: view.frame.width,
                                                      height: view.frame.height), animated: true)
            } else {
                self.presentViewController()
            }
        case .notDetermined: ()
        default: () // showAlertToSettings(for: .location)
        }
    }
}
