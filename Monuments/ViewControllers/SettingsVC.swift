//
//  SettingsVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 06.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

/* TODOs:
 - Quando la nuova visibilità viene selezionata, non ha effetto immediato sul ViewController ma bisogna usare
 lo slider perché prenda il nuovo valore
 */

import UIKit

struct Option {
    var title: String!
    var icon: UIImage?
    var subOptions: [Any]?
    let config = EnvironmentConfiguration()
    
    init(title: String,  subOptions: [Any]?, icon: UIImage) {
        self.title = title
        self.icon = icon
        self.subOptions = subOptions
    }
}

class SettingCell: UITableViewCell {
    @IBOutlet weak var disclosureDetail: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var settingLabel: UILabel!
    
    var isExpanded = false
    
    override func layoutSubviews() {
        self.backgroundColor = .clear
    }
}

class SubSettingCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var selectedDistanceImageView: UIImageView!
    
    override func layoutSubviews() {
        self.backgroundColor = .clear
    }
}

protocol SettingsViewControllerDelegate: class {
    func displayARDebug(isVisible: Bool)
    func displayDebugFeatures(isVisible: Bool)
    func scaleLocationNodesRelativeToDistance(_ shouldScale: Bool)
    func changeMaxVisibility(newValue value: Int)
}

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    var cellDescriptors: NSMutableArray!
    var visibleRowsPerSection = [[Int]]()
    
    weak var delegate: SettingsViewControllerDelegate?
    var debugFeatures = true
    let arSwitch = UISwitch()
    let debugSwitch = UISwitch()
    let scaleLocationNodesSwitch = UISwitch()
    
    var mainVC: UIViewController?
    
    var visibleOptions = [String]()
    var options: [Option?]  = [
        Option(title: "Mappa", subOptions: nil, icon: #imageLiteral(resourceName: "Map")),
        Option(title: "Visibilità",
               subOptions: [
                ("100 m", 100),
                ("150 m", 150),
                ("300 m", 300),
                ("500 m", 500),
                ("1 km", 1000),
                ("5 km", 5000),
                ("10 km", 10000)
            ],
               icon: #imageLiteral(resourceName: "Glasses")
        ),
        Option(title: "Debug", subOptions: ["Scale with distance", "AR features", "Debug options"], icon: #imageLiteral(resourceName: "Settings")),
        Option(title: "Info", subOptions: nil, icon: #imageLiteral(resourceName: "Info")),
    ]
    var savedDistance = 500       // Default value if none is stored
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var drawerView: BWGradientView!
    @IBAction func dismiss(_ sender: Any) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.transform = CGAffineTransform(translationX: -self.view.frame.size.width, y: 0)
        }, completion: { _ in
            self.dismiss(animated: false, completion: ({
                NotificationCenter.default.post(name: Notification.Name("reloadAnnotations"), object: nil)})
            ) })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareArSwitch()       // TODO: Remove this and put it in settings
        prepareDebugSwitch()    // TODO: Remove this and put it in settings
        prepareScaleLocationNodesSwitch()
        setupPanGesture()
        
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
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
    
    // MARK: - Pan Gesture
    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismiss))
        self.view.addGestureRecognizer(panGesture)
    }
    
    @objc func handleDismiss(_ sender: UIPanGestureRecognizer) {
        let percent = max(-sender.translation(in: view).x, 0) / self.view.frame.width
        
        switch sender.state {
        case .changed:
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 1,
                options: .curveEaseOut,
                animations: {
                    self.view.transform = CGAffineTransform(translationX: -percent * self.drawerView.frame.width, y: 0)
                }
            )
        case .ended:
            let velocity = -sender.velocity(in: view).x
            if percent < 0.5 || velocity > 1000 {
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 1,
                    options: .curveEaseOut,
                    animations: {
                        self.view.transform = .identity
                }
                )
            } else {
                let visibleFrame = self.drawerView.frame.origin.x + self.drawerView.frame.width
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: -visibleFrame, y: 0)
                }, completion: { _ in
                    self.dismiss(animated: false, completion: {
                            logger.verbose("Dismiss drawer")
                    })
                })
            }
        default:
            break
        }
    }
    
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // If the actual cell exists, than it is a default setting cell
        if let option = options[indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")! as! SettingCell
            cell.settingLabel.text = option.title
            
            // Insert proper setting icon
            if let icon = option.icon {
                cell.iconImageView.image = icon
            }
            return cell
            
        } else { // If the cell it is empty, than the row is expanded
            //  Get the index of the parent Cell (containing the data) and the subSettingCell
            let parentCellIndex = getParentCellIndex(expansionIndex: indexPath.row)
            let subSettingIndex = indexPath.row - parentCellIndex - 1
            
            if let option = options[parentCellIndex] {
                let expandedCell = tableView.dequeueReusableCell(withIdentifier: "subSettingCell") as! SubSettingCell
                expandedCell.selectionStyle = .none
                
                if let subOptions = option.subOptions {
                    // TODO fix if tap the first cell
                    if option.title == "Visibilità" {
                        let currentSubOptionRow = subOptions[subSettingIndex] as! (String, Int)
                        expandedCell.label.text = currentSubOptionRow.0     // String name
                        expandedCell.accessoryView = .none
                        
                        // If the setting is the Max Distance highlight the current saved maxDistance value
                        let savedMaxVisibility = UserDefaults.standard.integer(forKey: "maxVisibilityIndex")
                        expandedCell.selectedDistanceImageView.isHidden = (subSettingIndex != savedMaxVisibility)
                    }
                    
                    if option.title == "Debug" { // Debug options
                        expandedCell.label.text = (subOptions[subSettingIndex] as! String)
                        switch subSettingIndex {
                        case 0:
                            expandedCell.accessoryView = self.scaleLocationNodesSwitch
                        case 1:
                            expandedCell.accessoryView = self.arSwitch
                        case 2:
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
    
    //  Get parent cell index for selected ExpansionCell
    private func getParentCellIndex(expansionIndex: Int) -> Int {
        
        var selectedCell: Option?
        var selectedCellIndex = expansionIndex
        
        while selectedCell == nil && selectedCellIndex >= 0 {
            selectedCellIndex -= 1
            selectedCell = options[selectedCellIndex]
        }
        return selectedCellIndex
    }
    
    // Expand cell at given index
    private func expandCell(tableView: UITableView, index: Int) {
        var rowsIndexes = [IndexPath]()
        if let subOptions = options[index]?.subOptions {
            for i in 1...subOptions.count {
                options.insert(nil, at: index + i)
                rowsIndexes.append(IndexPath(row: index + i, section: 0))
            }
            tableView.beginUpdates()
            tableView.insertRows(at: rowsIndexes, with: .automatic)
            tableView.endUpdates()
        }
    }
    
    // Contract cell at given index
    private func contractCell(tableView: UITableView, index: Int) {
        
        if let subOptions = options[index]?.subOptions {
            var rowsIndexes = [IndexPath]()
            for i in 1...subOptions.count {
                options.remove(at: index+1)
                rowsIndexes.append(IndexPath(row: index + i, section: 0))
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: rowsIndexes, with: .automatic)
            tableView.endUpdates()
        }
    }
    
    // MARK: didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch options[indexPath.row]?.title {
        case "Mappa":
            NotificationCenter.default.post(name: NSNotification.Name("pauseSceneLocationView"), object: nil)
            performSegue(withIdentifier: "toMapVC", sender: nil)
            return
        case "Info":
            NotificationCenter.default.post(name: NSNotification.Name("pauseSceneLocationView"), object: nil)
            performSegue(withIdentifier: "toCreditsVC", sender: nil)
            return
        default:
            // Expandable cell
            if options[indexPath.row] != nil {
                let cell = tableView.cellForRow(at: indexPath) as! SettingCell
                if !cell.isExpanded {
                    cell.isExpanded = true
                    UIView.animate(withDuration: 0.1,
                                   animations: {
                                    cell.disclosureDetail.transform = CGAffineTransform.identity.rotated(by: .pi / 2)
                    })
                    expandCell(tableView: tableView, index: indexPath.row)
                } else {
                    cell.isExpanded = false
                    UIView.animate(withDuration: 0.1,
                                   animations: {
                                    cell.disclosureDetail.transform = CGAffineTransform.identity.rotated(by: 0)
                    })
                    contractCell(tableView: tableView, index: indexPath.row)
                }
            } else {          // The cell is a subSettingCell
                let parentCellIndex = getParentCellIndex(expansionIndex: indexPath.row)
                let parentCellOption = options[parentCellIndex]!
                
                if parentCellOption.title == "Visibilità" {
                    let childCellSubIndex = indexPath.row - parentCellIndex - 1
                    let selectedDistance = (parentCellOption.subOptions![childCellSubIndex]
                        as! (String, Int)).1
                    global.maxDistance = selectedDistance
                    delegate?.changeMaxVisibility(newValue: selectedDistance)
                    UserDefaults.standard.set(childCellSubIndex, forKey: "maxVisibilityIndex")
                    
                    tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: Debug switches
    func prepareArSwitch() {
        arSwitch.addTarget(self, action: #selector(hideShowArFeatures), for: UIControl.Event.valueChanged)
        if let state = UserDefaults.standard.object(forKey: "switchArFeaturesState") as? Bool {
            arSwitch.setOn(state, animated: false)
        } else {
            arSwitch.setOn(false, animated: false)
        }
    }
    
    func prepareDebugSwitch() {
        debugSwitch.addTarget(self, action: #selector(hideShowDebugFeatures), for: UIControl.Event.valueChanged)
        if let state = UserDefaults.standard.object(forKey: "switchDebugState") as? Bool {
            debugSwitch.setOn(state, animated: false)
        } else {
            debugSwitch.setOn(false, animated: false)
        }
    }
    
    func prepareScaleLocationNodesSwitch() {
        scaleLocationNodesSwitch.addTarget(self,
                                           action: #selector(scaleLocationNodesWithDistance),
                                           for: UIControl.Event.valueChanged)
        if let state = UserDefaults.standard.object(forKey: "scaleRelativeTodistance") as? Bool {
            scaleLocationNodesSwitch.setOn(state, animated: false)
        } else {
            scaleLocationNodesSwitch.setOn(false, animated: false)
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
    
    @objc func scaleLocationNodesWithDistance(sender: UISwitch) {
        delegate?.scaleLocationNodesRelativeToDistance(sender.isOn)
        UserDefaults.standard.set(scaleLocationNodesSwitch.isOn, forKey: "scaleRelativeTodistance")
    }
}
