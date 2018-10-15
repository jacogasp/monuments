//
//  FiltriVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 06.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

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

protocol FiltriVCDelegate: class {
    func updateVisibleAnnotations()
}

class FiltriVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: FiltriVCDelegate?
    var parentVC: UIViewController?

    @IBAction func dismiss(_ sender: Any) {
    
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.transform = CGAffineTransform(translationX: self.view.frame.size.width, y: 0)
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
           
            guard self.parentVC != nil else {       // BRUTTO DA SISTEMARE
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name("reloadAnnotations"), object: nil)
                return
            }
            // If the parent VC is Map, recalculate whose annotations are visible according to the selected filters
            if self.parentVC!.isKind(of: MapVC.self) {
                self.delegate?.updateVisibleAnnotations()
            }
        })
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Enter in FiltriVC\n")
        // Clear background color of tableView
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        scriviCelleSelezionate()
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
        return filtri.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellaFiltri", for: indexPath)
        
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.selectedBackgroundView?.backgroundColor = UIColor.clear
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filtro = filtri[indexPath.row]
        if filtro.selected {
            filtro.selected = false
        } else {
            filtro.selected = true
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func scriviCelleSelezionate() {
        let celleSelezionate = filtri.filter {$0.selected}.map {$0.nome}
        let defaults = UserDefaults.standard
        defaults.set(celleSelezionate, forKey: "celleSelezionate")
    }
}
