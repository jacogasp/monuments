//
//  SecondViewController.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 08/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import Mapbox

class MapVC: UIViewController, MGLMapViewDelegate, ARTrackingManagerDelegate {
    
    //@IBOutlet var mapView: MQMapView!
    var mapView: MQMapView!
    var progressView: UIProgressView!
    var trackingManager = ARTrackingManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MQMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.attributionButton.isEnabled = false
        mapView.attributionButton.isHidden = true
        mapView.showsUserLocation = true
        
        view.addSubview(mapView)
        
        if let currentCoordinate = trackingManager.locationManager.location?.coordinate {
            mapView.setCenter(currentCoordinate, zoomLevel: 13, animated: true)
        }
        
        // Offline notification handlers
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackProgressDidChange),
											   name: NSNotification.Name.MGLOfflinePackProgressChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveError),
											   name: NSNotification.Name.MGLOfflinePackError, object: nil)
        NotificationCenter.default.addObserver(self,
											   selector: #selector(offlinePackDidReceiveMaximumAllowedMapboxTiles),
											   name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached,
											   object: nil)
    }
    
    internal func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        // Start downloading tiles and resources for z13-16.
        startOfflinePackDownload()
    }
    
    deinit {
        // Remove offline pack observers.
        NotificationCenter.default.removeObserver(self)
    }
    
    func startOfflinePackDownload() {
        // Create a region that includes the current viewport and any tiles needed to view it when zoomed further in.
        // Because tile count grows exponentially with the maximum zoom level, you should be conservative with your
		// `toZoomLevel` setting.
        let region = MGLTilePyramidOfflineRegion(
                styleURL: mapView.styleURL,
                bounds: mapView.visibleCoordinateBounds,
                fromZoomLevel: mapView.zoomLevel,
                toZoomLevel: 16)
        
        // Store some data for identification purposes alongside the downloaded resources.
        let userInfo = ["name": "My Offline Pack"]
        let context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
        
        // Create and register an offline pack with the shared offline storage object.
        
        MGLOfflineStorage.shared().addPack(for: region, withContext: context) { (pack, error) in
                guard error == nil else {
                    // The pack couldn’t be created for some reason.
                print("Error: \(error?.localizedDescription)")
                return
            }
            
            // Start downloading.
            pack!.resume()
        }
    }
    
    // MARK: - MGLOfflinePack notification handlers
    
    func offlinePackProgressDidChange(notification: NSNotification) {
        // Get the offline pack this notification is regarding,
        // and the associated user info for the pack; in this case, `name = My Offline Pack`
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String] {
            let progress = pack.progress
            // or notification.userInfo![MGLOfflinePackProgressUserInfoKey]!.MGLOfflinePackProgressValue
            let completedResources = progress.countOfResourcesCompleted
            let expectedResources = progress.countOfResourcesExpected
            
            // Calculate current progress percentage.
            let progressPercentage = Float(completedResources) / Float(expectedResources)
            
            // Setup the progress bar.
            if progressView == nil {
                progressView = UIProgressView(progressViewStyle: .default)
                let frame = view.bounds.size
                progressView.frame = CGRect(x: frame.width / 4,
											y: frame.height * 0.75,
											width: frame.width / 2,
											height: 10)
                view.addSubview(progressView)
            }
            
            progressView.progress = progressPercentage
            
            // If this pack has finished, print its size and resource count.
            if completedResources == expectedResources {
                let byteCount = ByteCountFormatter.string(fromByteCount: Int64(pack.progress.countOfBytesCompleted),
														  countStyle: ByteCountFormatter.CountStyle.memory)
                print("Offline pack “\(userInfo["name"])” completed: \(byteCount), \(completedResources) resources")
            } else {
                // Otherwise, print download/verification progress.
                print("Offline pack “\(userInfo["name"])” has \(completedResources) of \(expectedResources) " +
					"resources — \(progressPercentage * 100)%.")
            }
        }
    }
    
    func offlinePackDidReceiveError(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let error = notification.userInfo?[MGLOfflinePackErrorUserInfoKey] as? Error {
            print("Offline pack “\(userInfo["name"])” received error: \(error.localizedDescription)")
        }
    }
    
    func offlinePackDidReceiveMaximumAllowedMapboxTiles(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let maximumCount = notification.userInfo?[MGLOfflinePackMaximumCountUserInfoKey] as? UInt64 {
            print("Offline pack “\(userInfo["name"])” reached limit of \(maximumCount) tiles.")
        }
    }
}
