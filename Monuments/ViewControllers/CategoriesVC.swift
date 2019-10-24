//
//  CategoriesVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 06.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

protocol CategoriesVCDelegate: class {
    func updateVisibleAnnotations(sender: UIViewController)
}

class CategoriesVC: UIViewController {
    
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
                        self.dismiss(animated: false, completion: nil)
                    })
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Save the current state of categories
        UserDefaults.standard.set(global.categories, forKey: selectedCategoriesKey)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Table view data source

extension CategoriesVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return global.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.selectedBackgroundView?.backgroundColor = UIColor.clear
        
        // Configure the cell...
        let categoryKey = CategoryKey.allCases[indexPath.row]
        let subtitleLabel: UILabel = cell.viewWithTag(1) as! UILabel
        subtitleLabel.text = String.localizedStringWithCounts(categoryKey.rawValue, 0)
        
        let uncheckedIcon = #imageLiteral(resourceName: "Checked")
        let checkedIcon = #imageLiteral(resourceName: "Unchecked")
        let iconImageView = cell.viewWithTag(2) as! UIImageView
        if let categoryStatus = global.categories[categoryKey.rawValue] {
            iconImageView.image = categoryStatus ? uncheckedIcon : checkedIcon
        }
        
        return cell
    }
}

// MARK: - Table View Delegate

extension CategoriesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoryKey = CategoryKey.allCases[indexPath.row]
        if let categoryStatus = global.categories[categoryKey.rawValue] {
            global.categories[categoryKey.rawValue] = !categoryStatus
        }
        tableView.reloadRows(at: [indexPath], with: .none)
        self.delegate?.updateVisibleAnnotations(sender: self)
    }
}
