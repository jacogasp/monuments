//
//  FiltriTableVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 13/01/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

/*
class Filtro {
    let categoria: String
    let nome: String
    let osmtag: String
    let peso: String
    var selected = false
    init(categoria: String, nome: String, osmtag: String, peso: String) {
        self.categoria = categoria
        self.nome = nome
        self.osmtag = osmtag
        self.peso = peso
    }
}
 */

class FiltriTableVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Evita che la navigationBar si nasconda con il tap
        print("Entering in FiltriTableVC...")
        let navigationController = self.navigationController
        navigationController?.hidesBarsOnTap = false
        
        //tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        scriviCelleSelezionate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filtri.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellaFiltri", for: indexPath)

        // Configure the cell...
        let filtro = filtri[indexPath.row]
        let filtroLabel: UILabel = cell.viewWithTag(1) as! UILabel
        filtroLabel.text = filtro.nome
        
        let iconaSelezionato = UIImage(named: "Check_Icon")
        let iconaDeselezionato = UIImage(named: "Uncheck_Icon")
        let iconaView = cell.viewWithTag(2) as! UIImageView
        iconaView.image = filtro.selected ? iconaSelezionato : iconaDeselezionato

        return cell
    }
    
    // ---- DID SELECT ----
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filtro = filtri[indexPath.row]
        if filtro.selected {
            filtro.selected = false
        } else {
            filtro.selected = true
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func scriviCelleSelezionate() {
        let celleSelezionate = filtri.filter{$0.selected}.map{$0.nome}
        let defaults = UserDefaults.standard
        defaults.set(celleSelezionate, forKey: "celleSelezionate")
    }
}
