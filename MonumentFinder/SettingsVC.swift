//
//  SettingsVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 06.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let options = ["Mappa", "Cerca", "Gestisci città", "Lingua", "Info/Credits"]
    let iconeSettings = ["Mappa_Icon", "Search_Icon", "City_Icon", "Lingue_Icon", "Info_Icon"]

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func dismiss(_ sender: Any) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.transform = CGAffineTransform(translationX: -self.view.frame.size.width, y: 0)
        }, completion: { finished in self.dismiss(animated: false, completion: nil) })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Clear background color of tableView
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        
        tableView.separatorStyle = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellaSettings", for: indexPath)
        
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.selectedBackgroundView?.backgroundColor = UIColor.clear
        
        let settingLabel: UILabel = cell.viewWithTag(3) as! UILabel
        settingLabel.text = options[indexPath.row]
        
        let icona = UIImage(named: iconeSettings[indexPath.row])
        let iconaView = cell.viewWithTag(4) as! UIImageView
        iconaView.image = icona
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            performSegue(withIdentifier: "toMapID", sender: nil)
        }
        if indexPath.row == 2 {
            performSegue(withIdentifier: "toSelectCity", sender: nil)
        }
    }
}
