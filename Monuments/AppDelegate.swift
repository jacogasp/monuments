//
//  AppDelegate.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 08/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import CoreData
import SwiftyBeaver
import CoreLocation.CLLocationManager
import AVFoundation.AVCaptureDevice
import SwiftUI

let logger = SwiftyBeaver.self
let preloadDataKey = "didPreloadData"
let selectedCategoriesKey = "selectedCategories"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var authorizationsNeeded: [AuthorizationRequestType]?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let console = ConsoleDestination()
        console.levelColor.debug = "🐞 "
        console.levelColor.error = "❌ "
        console.levelColor.info = "ℹ️ "
        console.levelColor.verbose = "📣 "
        console.levelColor.warning = "⚠️ "
        logger.addDestination(console)
        
        logger.info("Running application...\n\n")
        
        
        // Environment
        let env = Environment()
        logger.info("Found \(env.activeCategories.filter{$0.isSelected}.count) active categories")
                
        // Wait for Launch Screen
        Thread.sleep(forTimeInterval: 1.0)
        
        // Decide initial controller
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var viewController: UIViewController
        
        // Set default tint color
        self.window?.tintColor = EnvironmentConfiguration().defaultColor
        
        // On boarding
        if let authorizationsNeeded = authorizationRequestsNeeded() {
            let onboardingViewController = storyBoard.instantiateViewController(identifier: "OnboardingViewController") as! OnboardingViewController
            onboardingViewController.authorizationsNeeded = authorizationsNeeded
            viewController = onboardingViewController
            viewController.endAppearanceTransition()
            
        } else {
            viewController = UIViewController()
        }
        
        self.window?.rootViewController = UIHostingController(rootView: MonumentsView().environmentObject(env))
        
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types
		// of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits
		// the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
		// Games should use this method to pause the game.

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers,
		// and store enough application state information to restore your application to its current state in case
		// it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate:
		// when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the
		// changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "mapViewRegion")
        defaults.synchronize()
    }

    // MARK: - Preload Data
     
    func loadPlistFile<T>(forResource resource: String, forType type: T.Type) -> T where T: Decodable {
         guard let plistUrl = Bundle.main.url(forResource: resource, withExtension: "plist") else {
             fatalError("Cannot locate file \(resource).plist")
         }
         do {
             let plistData = try Data(contentsOf: plistUrl)
             let decoder = PropertyListDecoder()
             let decodedData = try decoder.decode(type.self, from: plistData)
             return decodedData
         } catch {
             fatalError("Cannot decode data, error: \(error)")
         }
     }
    
    func encodeWikipediaToJSON(wikiData: [String:String]?) -> String? {
        if let wikiData = wikiData {
            do {
                let json = try JSONSerialization.data(withJSONObject: wikiData, options: [])
                return String(data: json, encoding: .utf8)
            } catch {
                print(error)
            }
        }
        return nil
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

