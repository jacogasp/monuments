//
//  CategoriesVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 06.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class MNCategory {
    let osmtag: String          // OpenStreetMap tag
    let description: String     // Longname of tag (singular noun)
    let category: String        // Longname of the categorie (plural noun)
    let priority: Int           // In case a MNMonument has multiple osmtags, lower is the number higher is the priority
    var selected = false
    init(osmtag: String, description: String, category: String, priority: Int) {
        self.osmtag = osmtag
        self.description = description
        self.category = category
        self.priority = priority
    }
}

protocol CategoriesVCDelegate: class {
    func updateVisibleAnnotations()
}

class CategoriesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: CategoriesVCDelegate?
    var parentVC: UIViewController?

    @IBAction func dismiss(_ sender: Any) {
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.transform = CGAffineTransform(translationX: self.view.frame.size.width, y: 0)
                       },
                       completion: { _ in
                        self.dismiss(animated: false, completion: { () in
                            print("Dismiss CategoriesVC")
                            guard let parentVC = self.parentVC else {
                                NotificationCenter.default.post(name: Notification.Name("reloadAnnotations"),
                                                                object: nil)
                                return
                            }
                            if parentVC.isKind(of: MapVC.self) {
                                self.delegate?.updateVisibleAnnotations()
                            }
                        })
                    })
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Enter in CategoriesVC\n")
        // Clear background color of tableView
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let selectedCells = categories.filter {$0.selected}.map { $0.category }
        UserDefaults.standard.set(selectedCells, forKey: "selectedCells")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.selectedBackgroundView?.backgroundColor = UIColor.clear
        
        // Configure the cell...
        let category = categories[indexPath.row]
        let subtitleLabel: UILabel = cell.viewWithTag(1) as! UILabel
        subtitleLabel.text = category.category
        
        let iconaSelezionato = UIImage(named: "Check_Icon")
        let iconaDeselezionato = UIImage(named: "Uncheck_Icon")
        let iconaView = cell.viewWithTag(2) as! UIImageView
        iconaView.image = category.selected ? iconaSelezionato : iconaDeselezionato
        
        return cell
    }
    
    // ---- DID SELECT ----
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        if category.selected {
            category.selected = false
        } else {
            category.selected = true
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
