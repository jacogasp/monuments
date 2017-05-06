//
//  ImpostazioniVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 02.04.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class Impostazione {
    var titolo: String
    var icona: UIImage?
    
    init(titolo: String, icona: UIImage?) {
        self.titolo = titolo
        self.icona = icona
    }
}



class ImpostazioniVC: UITableViewController {
    var impostazioni: [Impostazione] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.lightGray
        
        impostazioni.append(Impostazione(titolo: "Gestisci città", icona: UIImage(named: "Map_Icon_Setting")))
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
        
        return impostazioni.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellaImpostazioni", for: indexPath) as UITableViewCell?
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellaImpostazioni")
        }
        
        let impostazione = impostazioni[indexPath.row]
        cell!.textLabel?.text = impostazione.titolo
        cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        if let iconaImage = impostazione.icona {
            cell!.imageView?.image = iconaImage
        }
    
        
        return cell!
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.isSelected = false
            //let segue = UIStoryboardSegue(identifier: "cittaSettingSegue", source: self, destination: GestisciCittaTableVC)
           performSegue(withIdentifier: "toCittaSetting", sender: self)
            
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
        
    }*/
 

}


