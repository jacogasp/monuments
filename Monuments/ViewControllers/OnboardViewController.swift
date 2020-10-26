//
//  OnboardViewController.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 11/10/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import CoreLocation.CLLocationManager
import AVFoundation.AVCaptureDevice

class OnboardViewController: UIPageViewController {

    // MARK: - Properties

    var authorizationsNeeded: [AuthorizationRequestType] = []
    let pageControl = UIPageControl()
    var locationManager: CLLocationManager?

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)

            if let firstRequest = authorizationsNeeded.first {
                displayAlertIfNeeded(for: firstRequest)
                if firstRequest == .location {
                    locationManager = CLLocationManager()
                    locationManager?.delegate = self
                }
            }
        }

        if authorizationsNeeded.count > 1 {
            pageControl.numberOfPages = authorizationsNeeded.count
            pageControl.currentPage = 0
            pageControl.pageIndicatorTintColor = .gray
            pageControl.currentPageIndicatorTintColor = EnvironmentConfiguration().defaultColor
            pageControl.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(pageControl)
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        }
    }

    // MARK: - Pages Setup

    private(set) lazy var pages: [UIViewController] = {
        var viewControllers: [UIViewController] = []
        for authorization in self.authorizationsNeeded {
            let viewController = self.createPageViewController(for: authorization)
            viewControllers.append(viewController)
        }
        return viewControllers
    }()

    private func createPageViewController(for requestType: AuthorizationRequestType) -> UIViewController {

        let viewController = UIViewController()
        let slide = Bundle.main.loadNibNamed("OnboardingSlide", owner: self, options: nil)?.first as! OnboardSlideView
        slide.frame = self.view.bounds

        switch requestType {
            case .location:
                slide.imageView.image = #imageLiteral(resourceName: "LocalizationService")
                slide.titleLabel.text = "Location Services"
                slide.descriptionLabel.text = "Monuments requires access to your location to find objects around you"
                slide.button.setTitle("Enable Location Services", for: .normal)
                slide.button.addTarget(self, action: #selector(self.enableLocationServicesTouched(_:)), for: .touchUpInside)
            case .camera:
                slide.imageView.image = #imageLiteral(resourceName: "Camera")
                slide.titleLabel.text = "Camera Access"
                slide.descriptionLabel.text = "Monuments requires access to the front camera fo show you objectes with Augmented Reality"
                slide.button.setTitle("Enable Camera", for: .normal)
                slide.button.addTarget(self, action: #selector(self.enableCameraAccessTouched(_:)), for: .touchUpInside)
        }

        slide.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.addSubview(slide)
        return viewController
    }

    // MARK: - Page Controller Actions

    private func moveToNextPage() {
        setViewControllers([self.pages[pageControl.currentPage + 1]], direction: .forward, animated: true, completion: {
            _ in
            self.pageControl.currentPage += 1
            self.displayAlertIfNeeded(for: self.authorizationsNeeded[self.pageControl.currentPage])
        })
    }

    // MARK: - Buttons Actions

    @objc func enableLocationServicesTouched(_ sender: Any) {
        self.requestAuthorization(for: .location)
    }

    @objc func enableCameraAccessTouched(_ sender: Any) {
        self.requestAuthorization(for: .camera)
    }

    /// Request authorization for request type and check if it was previously denied by user
    private func requestAuthorization(for requestType: AuthorizationRequestType) {
        // Check whether authorization was previously denied and in case display alert

        switch requestType {
            case .location:
                if let locationManager = self.locationManager {
                    locationManager.requestWhenInUseAuthorization()
                }
            case .camera:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                    if granted {
                        logger.info("Camera Access authorized")
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "toViewController", sender: nil)
                        }
                    } else {
                        self.displayAlertIfNeeded(for: .camera)
                    }
                })
        }
    }

    // MARK: - Alerts

    private func displayAlertIfNeeded(for requestType: AuthorizationRequestType) {
        switch requestType {
            case .camera:
                let status = AVCaptureDevice.authorizationStatus(for: .video)
                if status == .denied || status == .restricted {
                    showAlertToSettings(for: .camera)
                    logger.info("Camera access denied.")
                }
            case .location:
                let status = CLLocationManager.authorizationStatus()
                if status == .denied || status == .restricted {
                    showAlertToSettings(for: .location)
                    logger.info("Location authorization denied.")
                }
        }
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
}

// MARK: - PageViewController Delegate

extension OnboardViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print("ciao")

        if let viewControllerIndex = self.pages.firstIndex(of: previousViewControllers[0]) {
            if viewControllerIndex == 0 {
                self.pageControl.currentPage = viewControllerIndex + 1
            } else {
                self.pageControl.currentPage = viewControllerIndex - 1
            }
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController,
            willTransitionTo pendingViewControllers: [UIViewController]) {
        print("ohi")
    }
}

// MARK: - Location Manager Delegate

extension OnboardViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                logger.info("Location Services authorized")
                if pageControl.numberOfPages == 0 {
                    self.performSegue(withIdentifier: "toViewController", sender: nil)
                } else {
                    moveToNextPage()
                }
            case .restricted, .denied:
                self.showAlertToSettings(for: .location)
            default:
                ()
        }
    }
}
