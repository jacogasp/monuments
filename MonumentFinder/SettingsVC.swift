//
//  SettingsVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 06.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

struct Option {
    var option: String!
    var subOptions: [Any]?
    
    init(option: String, subOptions: [Any]?) {
        self.option = option
        self.subOptions = subOptions
    }
}

class SettingCell: UITableViewCell {
    
    @IBOutlet weak var disclosureDetail: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var settingLabel: UILabel!
    
}

class SubSettingCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var selectedDistanceImageView: UIImageView!
}

protocol SettingsViewControllerDelegate {
    func displayARDebug(isVisible: Bool)
    func displayDebugFeatures(isVisible: Bool)
}

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var cellDescriptors: NSMutableArray!
    var visibleRowsPerSection = [[Int]]()
    
    var delegate: SettingsViewControllerDelegate?
    var debugFeatures = true
    let arSwitch = UISwitch()
    let debugSwitch = UISwitch()
    
    var options: [Option?]?
    var visibleOptions = [String]()
    let iconeSettings = ["Mappa_Icon", "Lingue_Icon", "Credits_Icon", "Binocolo", "Bug_icon"]
    
    var savedDistance = 500       // Default value if none is stored

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func dismiss(_ sender: Any) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.transform = CGAffineTransform(translationX: -self.view.frame.size.width, y: 0)
        }, completion: { finished in self.dismiss(animated: false, completion: nil) })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        options = getData()
        
        prepareArSwitch()
        prepareDebugSwitch()
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        } else {
            // Fallback on earlier versions
        }

        // Clear background color of tableView
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.isMultipleTouchEnabled = false
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    // MARK: Prepare tableView
    
    func getData() -> [Option?] {
        let options = [
            Option(option: "Mappa", subOptions: nil),
            Option(option: "Lingua", subOptions: nil),
            Option(option: "Info", subOptions: nil),
            Option(option: "Visibilità", subOptions: [("100 m", 100), ("150 m", 150), ("300 m", 300), ("500 m", 500), ("1 km", 1000), ("5 km", 5000), ("10 km", 10000)]),
            Option(option: "Debug", subOptions: ["AR features", "Debug options"])
        ]
        
        return options
    }
    
    // MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let options = options {
            return options.count
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Default setting cell
        if let option = options?[indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")! as! SettingCell
            cell.settingLabel.text = option.option
            
            // Insert proper setting icon per each row
            var j = 0
            for i in 0..<tableView.numberOfRows(inSection: indexPath.section) {
                if options?[i] != nil {            // It's settingCell
                    if i == indexPath.row {
                        let icona = UIImage(named: iconeSettings[j])
                        cell.iconImageView.image = icona
                        cell.disclosureDetail.isHidden = (j == 0 || j == 3 || j == 4) ? false : true      // Rows with disclosure detail arrow
                    } else {
                        j += 1
                    }
                }
            }
            return cell
            
        } else { // Row is expanded
            if let option = options?[getParentCellIndex(expansionIndex: indexPath.row)] {
                let expandedCell = tableView.dequeueReusableCell(withIdentifier: "subSettingCell") as! SubSettingCell
                expandedCell.selectionStyle = .none
                
                //  Get the index of the parent Cell (containing the data)
                let parentCellIndex = getParentCellIndex(expansionIndex: indexPath.row)
                //  Get the index of subSettingCell (e.g. if there are multiple ExpansionCells)
                let subSettingIndex = indexPath.row - parentCellIndex - 1
                
                if let subOptions = option.subOptions {
                    
                    if parentCellIndex == 3 { // maxVisibility
                        let currentSubOptionRow = subOptions[subSettingIndex] as! (String,Int)
                        expandedCell.label.text = currentSubOptionRow.0     // String name
                        expandedCell.accessoryView = .none
                        
                        // If the setting is the Max Distance highlight the current saved maxDistance value
                        if let savedMaxVisibilyIndex = UserDefaults.standard.object(forKey: "maxVisibilityIndex") {
                            expandedCell.selectedDistanceImageView.isHidden = (subSettingIndex == savedMaxVisibilyIndex as! Int) ? false : true
                        } else {
                            expandedCell.selectedDistanceImageView.isHidden = (subSettingIndex == 3) ? false : true
                        }
                    }
                    
                    if parentCellIndex == 4 { // Debug options
                        expandedCell.label.text = (subOptions[subSettingIndex] as! String)
                        switch subSettingIndex {
                        case 0:
                            expandedCell.accessoryView = self.arSwitch
                        case 1:
                            expandedCell.accessoryView = self.debugSwitch
                        default:
                            break
                        }
                        
                    }

                    return expandedCell
                }
            }
        }
        return UITableViewCell()
    }
    
    /*  Get parent cell index for selected ExpansionCell  */
    private func getParentCellIndex(expansionIndex: Int) -> Int {
        
        var selectedCell: Option?
        var selectedCellIndex = expansionIndex
        
        while(selectedCell == nil && selectedCellIndex >= 0) {
            selectedCellIndex -= 1
            selectedCell = options?[selectedCellIndex]
        }
        return selectedCellIndex
    }
    
    /*  Expand cell at given index    */
    private func expandCell(tableView: UITableView, index: Int) {
        var rowsIndexes = [IndexPath]()
        if let subOptions = options?[index]?.subOptions {
            for i in 1...subOptions.count {
                options?.insert(nil, at: index + i)
                rowsIndexes.append(IndexPath(row: index + i, section: 0))
            }
            tableView.beginUpdates()
            tableView.insertRows(at: rowsIndexes, with: .automatic)
            tableView.endUpdates()
        }
    }
    
    /*  Contract cell at given index    */
    private func contractCell(tableView: UITableView, index: Int) {

        if let subOptions = options?[index]?.subOptions {
            var rowsIndexes = [IndexPath]()
            for i in 1...subOptions.count {
                options?.remove(at: index+1)
                rowsIndexes.append(IndexPath(row: index + i, section: 0))
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: rowsIndexes, with: .automatic)
            tableView.endUpdates()

        }
    }
    
    /* didSelectRowAt */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "toMapVC", sender: nil)
            return
        case 1:
            // performSegue(withIdentifier: "to", sender: nil)
            break
        case 2:
            performSegue(withIdentifier: "toCreditsVC", sender: nil)
            return
        default:
            if options?[indexPath.row] != nil {
                let cell = tableView.cellForRow(at: indexPath) as! SettingCell
                if(indexPath.row + 1 >= (options?.count)!) {
                    UIView.animate(withDuration: 0.1, animations: { cell.disclosureDetail.transform = CGAffineTransform.identity.rotated(by: .pi / 2)})
                    expandCell(tableView: tableView, index: indexPath.row)
                } else {
                    // If next cell is not nil, then cell is not expanded
                    if(options?[indexPath.row+1] != nil) {
                        UIView.animate(withDuration: 0.1, animations: { cell.disclosureDetail.transform = CGAffineTransform.identity.rotated(by: .pi / 2) })
                        expandCell(tableView: tableView, index: indexPath.row)
                        // Close Cell (remove ExpansionCells)
                    } else {
                        UIView.animate(withDuration: 0.1, animations: { cell.disclosureDetail.transform = CGAffineTransform.identity.rotated(by: 0)  })
                        contractCell(tableView: tableView, index: indexPath.row)
                    }
                }
            } else {          // cell is a subsettingCell
                let parentCellIndex = getParentCellIndex(expansionIndex: indexPath.row)
                
                if parentCellIndex == 3 {        // maxVisibility setting
                    let childCellSubIndex = indexPath.row - parentCellIndex - 1
                    let selectedDistance = (options![parentCellIndex]!.subOptions![childCellSubIndex] as! (String, Int)).1
                    maxDistance = Double(selectedDistance)
                    UserDefaults.standard.set(maxDistance, forKey: "maxVisibility")
                    UserDefaults.standard.set(childCellSubIndex, forKey: "maxVisibilityIndex")
                    tableView.reloadData()
                }
            }
        }
        
        // If the cell is not nil -> settingCell

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    // MARK: Debug switches
    
    func prepareArSwitch() {
        arSwitch.addTarget(self, action: #selector(hideShowArFeatures), for: UIControlEvents.valueChanged)
        if let state = UserDefaults.standard.object(forKey: "switchArFeaturesState") as? Bool {
            arSwitch.setOn(state, animated: false)
        } else {
            arSwitch.setOn(false, animated: false)
        }
    }
    
    
    func prepareDebugSwitch() {
        debugSwitch.addTarget(self, action: #selector(hideShowDebugFeatures), for: UIControlEvents.valueChanged)
        if let state = UserDefaults.standard.object(forKey: "switchDebugState") as? Bool {
            debugSwitch.setOn(state, animated: false)
        } else {
            debugSwitch.setOn(false, animated: false)
        }
    }
    
    @objc func hideShowArFeatures(sender: UISwitch) {
        delegate?.displayARDebug(isVisible: sender.isOn)
        UserDefaults.standard.set(arSwitch.isOn, forKey: "switchArFeaturesState")
    }
    
    @objc func hideShowDebugFeatures(sender: UISwitch ) {
        delegate?.displayDebugFeatures(isVisible: sender.isOn)
        UserDefaults.standard.set(debugSwitch.isOn, forKey: "switchDebugState")
    }
}
