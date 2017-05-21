//
//  SelectCityVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 07.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import SQLite

var cities: [String] = []
var shouldReloadCities = true

class SelectCityVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss()
    }
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (shouldReloadCities || cities.isEmpty) {
            getCitiesFromSQL()
            shouldReloadCities = false
        }
        
        // Clear background color of tableView
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellaCitta", for: indexPath)
        
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.selectedBackgroundView?.backgroundColor = UIColor.clear
        
        // Configure the cell...
        let cittaLabel: UILabel = cell.viewWithTag(5) as! UILabel
        cittaLabel.text = cities[indexPath.row]
        
        let selectedImgView = cell.viewWithTag(6) as! UIImageView
        let image = UIImage(named: "Check_Icon")
        
        if cities[indexPath.row] == selectedCity {
            selectedImgView.image = image
        } else {
            selectedImgView.image = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCity = cities[indexPath.row]
        print("Città selezionata: \(selectedCity)\n")
        dismiss()
        reloadDb()
        tableView.reloadData()
    }
    
    func reloadDb() {
        monumenti = []
        let monumentiReader = MonumentiClass()
        monumentiReader.leggiDatabase(city: selectedCity)
        print("Rilettura monumenti dal database... Monumenti letti dal database: \(monumenti.count)\n")
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("reloadAnnotations"), object: nil)
    }
    
    
    func dismiss() {
        
        let src: UIViewController! = self
        let dst: UIViewController! = self.presentingViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        
        dst.view.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.size.height)
        
        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut, animations: {
            src.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
            
        }, completion: { finished in
            self.dismiss(animated: false, completion: nil)
        })

    }
    
    func getCitiesFromSQL() {
        print("Get cities list...")
        var unsortedCities: [String] = []
        if let path = Bundle.main.path(forResource: "db", ofType: "sqlite") {
            do {
                let db = try Connection(path)
                
                for row in try db.prepare("select name from sqlite_master where type='table'") {
                    unsortedCities.append(row[0] as! String)
                }
                cities = unsortedCities.sorted{$0 < $1}
                
            } catch {
                print("Errore nel connettersi al database: \(error).")
            }
        } else {
            print ("Database not found.")
        }
    } // End getCitiesFromSQL

}
