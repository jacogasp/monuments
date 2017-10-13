//
//  MaxVisibilityVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 12/10/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class MaxVisibilityVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var distances = [
        ("100 m", 100.0),
        ("150 m", 150.0),
        ("300 m", 300.0),
        ("500 m", 500.0),
        ("1 km", 1000.0),
        ("2 km", 2000.0),
        ("5 km", 5000.0),
        ("10 km", 10000.0)
        ]

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return distances.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellaDistance", for: indexPath)
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.selectedBackgroundView?.backgroundColor = UIColor.clear
        
        var savedDistance: Double
        if UserDefaults.standard.object(forKey: "maxVisibility") != nil {
            savedDistance = UserDefaults.standard.double(forKey: "maxVisibility")
        } else {
            savedDistance = 500
        }
        let imageView = cell.viewWithTag(5) as! UIImageView
        
        if savedDistance == distances[indexPath.row].1 {
            imageView.isHidden = false
        } else {
            imageView.isHidden = true
        }
    
        let settingLabel: UILabel = cell.viewWithTag(4) as! UILabel
        
        settingLabel.text = distances[indexPath.row].0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        maxDistance = distances[indexPath.row].1
        self.dismiss()
        let defaults = UserDefaults.standard
        defaults.set(maxDistance, forKey: "maxVisibility")
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

}
