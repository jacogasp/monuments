//
//  AppDelegate.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 07/09/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import SwiftyBeaver
import CoreLocation.CLLocationManager
import AVFoundation.AVCaptureDevice

let logger = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let console = ConsoleDestination()
        console.levelColor.debug = "🐞 "
        console.levelColor.error = "❌ "
        console.levelColor.info = "ℹ️ "
        console.levelColor.verbose = "📣 "
        console.levelColor.warning = "⚠️ "
        logger.addDestination(console)

        logger.info("Running application...\n\n")
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

// MARK: - Authorizations

enum AuthorizationRequestType {
    case location, camera
}

extension AppDelegate {

    private func authorizationRequestsNeeded() -> [AuthorizationRequestType]? {
        var requests: [AuthorizationRequestType]?

        let locationStatus = CLLocationManager.authorizationStatus()
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)

        let locationNeeded = locationStatus == .notDetermined || locationStatus == .restricted || locationStatus == .denied
        let cameraNeeded = cameraStatus == .notDetermined || cameraStatus == .restricted || cameraStatus == .denied

        if locationNeeded { requests?.append(.location) ?? (requests = [.location]) }
        if cameraNeeded { requests?.append(.camera) ?? (requests = [.camera])}
        return requests
    }
}
