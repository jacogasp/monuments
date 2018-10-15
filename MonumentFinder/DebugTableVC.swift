//
//  DebugTableVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 23/10/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class DebugTableVC: UITableViewController {
    let trackingSwitch = UISwitch()
    let scaleSwitch = UISwitch()
    
    let cellTitleLabels = [
        "Mostra AR tracking points",
        "Scala con la distanza"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.headerView(forSection: 0)?.textLabel?.text = "Mostra/nascondi debug features"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cellTitleLabels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "debugCell", for: indexPath)

        // Configure the cell...
        let label: UILabel = cell.viewWithTag(40) as! UILabel
        label.text = cellTitleLabels[indexPath.row]

        switch indexPath.row {
        case 0:
            cell.selectionStyle = .none
            cell.accessoryView = trackingSwitch
        case 1:
            cell.selectionStyle = .none
            cell.accessoryView = scaleSwitch
        default:
            break
        }
        
        return cell
    }
    
    func setupSwitch(_ mySwitch: UISwitch) {
        
        var key = ""
        switch mySwitch {
        case trackingSwitch:
            key = "trackingSwitchState"
        case scaleSwitch:
            key = "scaleSwitchState"
        default:
            break
        }
        
        if mySwitch == trackingSwitch {
            mySwitch.addTarget(self, action: #selector(hideShowDebugFeatures), for: UIControlEvents.valueChanged)
            if let state = UserDefaults.standard.object(forKey: key) as? Bool {
                mySwitch.setOn(state, animated: false)
            } else {
                mySwitch.setOn(false, animated: false)
            }
        }
    
    }
    
    @objc func hideShowDebugFeatures(sender: UISwitch ) {
        
        var activateNotificationName = ""
        var deactivateNotificationName = ""
        
        switch sender {
        case trackingSwitch:
            activateNotificationName = "activateTrackingDebug"
            deactivateNotificationName = "deactivateTrackingDebug"
        case scaleSwitch:
            activateNotificationName = "activateScaleWithDistance"
            deactivateNotificationName = "deactivateScaleWithDistance"
        default:
            break
        }
        if sender.isOn {
            NotificationCenter.default.post(name: NSNotification.Name(activateNotificationName), object: nil)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(deactivateNotificationName), object: nil)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
	forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array,
			// and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
