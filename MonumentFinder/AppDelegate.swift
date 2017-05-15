//
//  AppDelegate.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 08/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import CSV

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        

        
        
        print("Avvio applicazione...\n\n")
        
        leggiFiltriDaCsv()
        caricaFiltriAttivi()

        
        let defaults = UserDefaults.standard
        
        if let savedCity = defaults.object(forKey: "savedCity") {
            selectedCity = savedCity as! String
            print("Città salvata: \(savedCity).")

        } else {
            print("Nessuna città savata. AlertView")
        }
 
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let defaults = UserDefaults.standard
        defaults.set(selectedCity, forKey: "savedCity")
    }
    
    func leggiFiltriDaCsv() {
        // Legge il CSV
        if let path = Bundle.main.path(forResource: "MonumentTags", ofType: "csv") {
            do {
                let stream = InputStream(fileAtPath: path)!
                var csv = try! CSV(stream: stream, hasHeaderRow: true, delimiter: ";")
                while let _ = csv.next() {
                    let filtro = Filtro(categoria: csv["Categoria"]!, nome: csv["Filtri (ita)"]!, osmtag: csv["OSMtags"]!, peso: csv["Peso"]!)
                    filtri.append(filtro)
                }
            }
        }
    }
    
    func firstLaunch() {
        let defaults = UserDefaults.standard
        let valoriDiDefault = ["celleSelezionate": [String]()]
        defaults.register(defaults: valoriDiDefault)
    }
    
    // Se sono presenti categorie attive salvate in memoria le carica su disco, altrimenti setta tutto visibile di default.
    
    func caricaFiltriAttivi() {
        let defaults = UserDefaults.standard
        if let celleSelezionate = defaults.stringArray(forKey: "celleSelezionate") {
            for filtro in filtri {
                filtro.selected = celleSelezionate.contains(filtro.nome)
            }
        } else {
            for filtro in filtri {
                filtro.selected = true
            }
        }
    }
}

