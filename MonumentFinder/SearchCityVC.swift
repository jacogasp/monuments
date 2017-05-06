//
//  SearchCityVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 02.04.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import MapKit

class SearchCityVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var searchController: UISearchController!
    var shouldShowSearchResults = false
    weak var tblSearchResult: UITableView!
    var dataArray:[String] = []
    var filteredArray: [String] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        for i in 0...10 {
            dataArray.append("Item \(i)")
        }
     
        let qu = UIView(frame: CGRect(x: 20, y:20, width: 100, height: 100))
        qu.backgroundColor = UIColor.green
        self.view.addSubview(qu)
        
        let tblSearchResult = UITableView(frame: view.bounds)
        self.view.addSubview(tblSearchResult)
        
        self.tblSearchResult = tblSearchResult
        
        tblSearchResult.delegate = self
        tblSearchResult.dataSource = self
        
        configureSearchController()
    }

    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        //searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        tblSearchResult.tableHeaderView = searchController.searchBar
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tblSearchResult.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tblSearchResult.reloadData()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tblSearchResult.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        // Filter the data array and get only those countries that match the search text.
        filteredArray = dataArray.filter({ (country) -> Bool in
            let countryText: NSString = country as NSString
            
            //return (countryText.rangeOfString(searchString!, options: NSString.CompareOptions.CaseInsensitiveSearch).location) != NSNotFound
            return true
        })
        
        // Reload the tableview.
        tblSearchResult.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = dataArray[indexPath.row]
        
        // Instantiate a cell
        let cellIdentifier = "ElementCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        // Adding the right informations
        cell.textLabel?.text = element
        cell.detailTextLabel?.text = "dio"
        
        // Returning the cell
        return cell
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
