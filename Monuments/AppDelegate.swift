//
//  AppDelegate.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 08/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("Avvio applicazione...\n\n")
        
        let config = EnvironmentConfiguration()
        let dataCollection = DataCollection()
        dataCollection.readFromDatabase()
        readMonumentTagsFromCsv()
        loadCategoriesState()
        
        Theme.apply()
        if let maxDistance = UserDefaults.standard.object(forKey: "maxVisibility") as? Int {
            global.maxDistance = maxDistance
        } else {
            global.maxDistance = config.maxDistance
        }
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
//        if #available(iOS 11.0, *) {
//            if let vc = self.window?.rootViewController as? ViewController {
//                vc.pauseSceneLocationView()
//            }
//        } else {
//            // Fallback on earlier versions
//        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the
		// changes made on entering the background.
//        print("appWillEnterForeground")
//        let nc = NotificationCenter.default
//        nc.post(Notification.init(name: Notification.Name(rawValue: "appWillEnterForeground")))
//        if #available(iOS 11.0, *) {
//            if let vc = self.window?.rootViewController as? ViewController {
//                vc.resumeSceneLocationView()
//            }
//        } else {
//            // Fallback on earlier versions
//        }
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "mapViewRegion")

    }
    // MARK: Custom functions
 
    func readMonumentTagsFromCsv() {
        // Legge il CSV
        let fileURL = Bundle.main.url(forResource: "MonumentTags", withExtension: "csv")
        do {
            let csvString = try NSString.init(contentsOf: fileURL!, encoding: String.Encoding.utf8.rawValue)
            let rows = csvString.components(separatedBy: "\n")
            for row in rows {
                let monumentTagsComponents = row.components(separatedBy: ";")
                if monumentTagsComponents.count > 1 { // TODO: improve this
                    let osmtag = monumentTagsComponents[0]
                    let priority = monumentTagsComponents[1]
                    let description = monumentTagsComponents[2]
                    let category = monumentTagsComponents[3]
                    global.categories.append(MNCategory(osmtag: osmtag,
                                             description: description,
                                             category: category,
                                             priority: Int(priority)!))
                }
            }
        } catch {
            
        }
    }
    
    // If there aren't categories which state was set by user, set the selected state true for all
    func loadCategoriesState() {
        if let selectedOsmTags = UserDefaults.standard.stringArray(forKey: "selectedOsmTags")  {
            global.categories.forEach { $0.selected = (selectedOsmTags.contains($0.osmtag))}
        } else {
            global.categories.forEach {$0.selected = true }
        }
    }
}
