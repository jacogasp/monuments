//
//  CustomSearchBar.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 15.06.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

@objc protocol CustomSearchBarDelegate {
    
    func searchFieldDidChange(searchText: String)
    
    func cancelButtonPressed()
    
}

@IBDesignable

class CustomSearchBar: UIView, UITextFieldDelegate {
    
    @IBOutlet var customSearchBarDelegate: CustomSearchBarDelegate?
    
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func cancelAction(_ sender: Any) {
        
        print("culo1")
        customSearchBarDelegate?.cancelButtonPressed()
    }
    
    let nibName = "CustomSearchBar"
    var view: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        xibSetup()
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(searchFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    
    func xibSetup() {
       
        view = Bundle(for: type(of: self)).loadNibNamed(nibName, owner: self, options: nil)!.first as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.clear
        addSubview(view)
        
    }
    
    
    override func draw(_ rect: CGRect) {
        
        let lineWidth: CGFloat = 2.5
        
        let startPoint = CGPoint(x: 0, y: frame.size.height - lineWidth * 0.5)
        let endPoint = CGPoint(x: frame.size.width, y: frame.size.height - lineWidth * 0.5)
        
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = defaultColor.cgColor
        shapeLayer.lineWidth = lineWidth
        
        layer.addSublayer(shapeLayer)
        self.backgroundColor = UIColor.clear
        
        // super.draw(rect)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
    }
    
    func searchFieldDidChange(_ searchField: UITextField) {
        
        customSearchBarDelegate?.searchFieldDidChange(searchText: searchField.text!)
        
    }

    
}

/*
class CustomSearchBar: UISearchBar {
    
    var font: UIFont! = defaultFont
    var textColor: UIColor! = defaultColor
    
    var newTextField: UITextField?
    var newCancelButton: UIButton?
    
    
    init(frame: CGRect, font: UIFont, textColor: UIColor) {
        
        super.init(frame: frame)
        //self.frame = frame
        self.font = font
        self.textColor = textColor
        
        searchBarStyle = .minimal
        isTranslucent = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func getViewElement<T>(type: T.Type) -> T? {
        
        let svs = subviews.flatMap { $0.subviews }
        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    
    
    override func draw(_ rect: CGRect) {
        if let searchField: UITextField = getViewElement(type: UITextField.self), let cancelButton: UIButton = getViewElement(type: UIButton.self) {
            
            searchField.font = font
            searchField.textColor = textColor
            searchField.cornerRadius = 0.0
            cancelButton.backgroundColor = defaultColor
            cancelButton.tintColor = UIColor.white
            
            searchField.translatesAutoresizingMaskIntoConstraints = false
            cancelButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint(item: searchField, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
            
            NSLayoutConstraint(item: searchField, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: cancelButton, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
            
            NSLayoutConstraint(item: cancelButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
            
            NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
            
            NSLayoutConstraint(item: cancelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100).isActive = true
            
            NSLayoutConstraint(item: searchField, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
            
            NSLayoutConstraint(item: searchField, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
            
            NSLayoutConstraint(item: cancelButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true

        }
        
        
        // Draw line
        
        let startPoint = CGPoint(x: 0, y: frame.size.height)
        let endPoint = CGPoint(x: frame.size.width, y: frame.size.height)
        
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = textColor.cgColor
        shapeLayer.lineWidth = 2.5
        
        layer.addSublayer(shapeLayer)
        
        super.draw(rect)
        
    }

}*/
