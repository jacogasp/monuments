//
//  SettingsVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 06.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var debugFeatures = true
    let debugSwitch = UISwitch()
    
    let options = ["Mappa", "Lingua", "Info", "Visibilità", "Debug"]
    let iconeSettings = ["Mappa_Icon", "Lingue_Icon", "Credits_Icon", "Binocolo", "Bug_icon"]

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func dismiss(_ sender: Any) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.transform = CGAffineTransform(translationX: -self.view.frame.size.width, y: 0)
        }, completion: { finished in self.dismiss(animated: false, completion: nil) })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        } else {
            // Fallback on earlier versions
        }

        // Clear background color of tableView
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UserDefaults.standard.set(debugSwitch.isOn, forKey: "switchDebugState")
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

        switch indexPath.row {
        case 3:
            settingLabel.text = "Visibilità"
            cell.accessoryType = .disclosureIndicator
        case 4:
            settingLabel.text = "Debug"
            prepareSwitch()
            cell.selectionStyle = .none
            cell.accessoryView = debugSwitch
        default:
            settingLabel.text = options[indexPath.row]
        }
        let icona = UIImage(named: iconeSettings[indexPath.row])
        let iconaView = cell.viewWithTag(4) as! UIImageView
        iconaView.image = icona
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            performSegue(withIdentifier: "toMapID", sender: nil)
        }
        if indexPath.row == 1 {
           // performSegue(withIdentifier: "toSelectCity", sender: nil)
        }
        
        if indexPath.row == 2 {
            performSegue(withIdentifier: "toCreditsVC", sender: nil)
        }
        
        if indexPath.row == 3 {
            performSegue(withIdentifier: "toMaxVisibilityVC", sender: nil)
        }
    }
    
    // MARK: Debug switch
    
    func prepareSwitch() {
        debugSwitch.addTarget(self, action: #selector(hideShowDebugFeatures), for: UIControlEvents.valueChanged)
        if let state = UserDefaults.standard.object(forKey: "switchDebugState") as? Bool {
            debugSwitch.setOn(state, animated: false)
        } else {
            debugSwitch.setOn(false, animated: false)
        }
    }
    
    @objc func hideShowDebugFeatures(sender: UISwitch ) {

        if sender.isOn {
            NotificationCenter.default.post(name: NSNotification.Name("activateDebugMode"), object: nil)
          //  sender.setOn(false, animated: true)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("deactivateDebugMode"), object: nil)
   //         sender.setOn(true, animated: true)
        }
    }
}
