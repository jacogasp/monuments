//
//  LeftMenuViewController.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 02/05/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import UIKit

struct Setting {
    
    // MARK: - Properties
    
    let name: String!
    var image: UIImage!
    var viewControllerType: UIViewController.Type?
    
    var toViewController: UIViewController? {
        guard let viewControllerType = self.viewControllerType else { return nil }
        return viewControllerType.init()
    }
    
    init(name: String, image: UIImage) {
        self.name = name
        self.image = image
    }
    
    init(name: String, image: UIImage, viewControllerType: UIViewController.Type) {
        self.name = name
        self.image = image
        self.viewControllerType = viewControllerType
    }
}

class LeftMenuViewController: SideViewController {
    
    // MARK: - Properties
    
    let rowHeight: CGFloat = 64
    var gradientView: BWGradientView!
    let startColor = #colorLiteral(red: 0.9294117647, green: 0.1294117647, blue: 0.2274509804, alpha: 1)
    let endColor = #colorLiteral(red: 0.737254902, green: 0.2666666667, blue: 0.2039215686, alpha: 1)
    var titleLabel: UILabel!
    let titleName = "Monuments"
    let titleFont = "TrajanPro-Regular"
    let titleFontSize: CGFloat = 48
    var tableView: UITableView!
    let cellIdentifier = "LeftMenuCellIdentifier"
    
    let settings: [Setting] = [
        Setting(name: "Map", image: #imageLiteral(resourceName: "Map"), viewControllerType: MapVC.self),
        Setting(name: "Settings", image: #imageLiteral(resourceName: "Settings")),
        Setting(name: "Info", image: #imageLiteral(resourceName: "Info"))
    ]
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setups
        setupBackgroundView()
        setupTitleLabel()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    // MARK: - Handlers
    
    private func setupBackgroundView() {
        let gradientView = BWGradientView()
        gradientView.frame = self.drawerView.bounds
        gradientView.startColor = startColor
        gradientView.endColor = endColor
        self.drawerView.addSubview(gradientView)
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        let bounds = CGRect(x: 0, y: 20, width: drawerView.bounds.width, height: 64)
        titleLabel.frame = bounds.insetBy(dx: 18, dy: 0)
        
        titleLabel.autoresizingMask = [.flexibleWidth]
        titleLabel.text = self.titleName
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: titleFont, size: titleFontSize)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.2
        self.drawerView.addSubview(titleLabel)
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()    // Fix to hide empty rows
        tableView.isScrollEnabled = false
        
        self.drawerView.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.widthAnchor.constraint(equalTo: drawerView.widthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        tableView.centerXAnchor.constraint(equalTo: drawerView.centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: drawerView.centerYAnchor).isActive = true
    }
}

// MARK: - TableViewDelegate

extension LeftMenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let settingCell = tableView.cellForRow(at: indexPath) as? SideMenuViewCell {
            settingCell.isSelected = false
            if let toViewController = settings[indexPath.row].toViewController {
                self.navigationController?.pushViewController(toViewController, animated: true)
            }
        }
    }
}

// MARK: TableViewDataSource
extension LeftMenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            return cell
        } else {
            let cell = SideMenuViewCell()
            let setting = settings[indexPath.row]
            cell.textLabel?.text = setting.name
            cell.imageView?.image =  setting.image
            cell.imageView?.tintColor = .white
            
            let accessoryImageView = UIImageView()
            accessoryImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            accessoryImageView.image = #imageLiteral(resourceName: "Chevron")
            accessoryImageView.tintColor = .white
            cell.accessoryView = accessoryImageView
            return cell
        }
    }
}
