//
//  CustomSearchController.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 15.06.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//
import UIKit

protocol CustomSearchControllerDelegate: class {
   
    func didStartSearching()
    
    func didTapOnSearchButton()
    
    func didTapOnCancelButton()
    
    func didChangeSearchText(searchText: String)
    
}

class CustomSearchController: UISearchController, UISearchBarDelegate {

    weak var customSearchBar: CustomSearchBar!
    weak var customDelegate: CustomSearchControllerDelegate!
    
    override init(searchResultsController: UIViewController!) {
        
        super.init(searchResultsController: searchResultsController)
//        configureSearchBar(frame: searchBarFrame,
//						   font: searchBarFont,
//						   textColor: searchBarTextColor,
//						   bgColor: searchBarTintColor)
		
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    func configureSearchBar(frame: CGRect, font: UIFont, textColor: UIColor, bgColor: UIColor) {
        
        customSearchBar = CustomSearchBar(frame: frame, font: font, textColor: textColor)
        customSearchBar.barTintColor = bgColor
        // customSearchBar.tintColor = textColor
        customSearchBar.backgroundColor = UIColor.clear
        customSearchBar.showsBookmarkButton = false
        customSearchBar.showsCancelButton = true
        customSearchBar.delegate = self
        
    }*/
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        customDelegate.didStartSearching()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        customSearchBar.resignFirstResponder()
        customDelegate.didTapOnSearchButton()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        customSearchBar.resignFirstResponder()
        customDelegate.didTapOnCancelButton()
    }

}
