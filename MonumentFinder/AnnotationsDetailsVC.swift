//
//  AnnotationsDetailsVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 15.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class AnnotationsDetailsVC: UIViewController {
    
    let titleLabel = UILabel()
    let scrollView = UIScrollView()
    let wikiPicture = UIImageView()
    let textView = UITextView()
    let widget = UIView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        
        createDismissButton()
        createWidget()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createWidget() {
        //let containerView = UIView()
        widget.backgroundColor = UIColor.clear
        self.view.addSubview(widget)
        
        // Constraints to super view
        
        widget.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15.0).isActive = true
        widget.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15.0).isActive = true
        widget.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50.0).isActive = true
        widget.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50.0).isActive = true
        widget.translatesAutoresizingMaskIntoConstraints = false
        
        // Create Blur
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = widget.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.cornerRadius = 5
        
        widget.addSubview(blurEffectView)


        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        widget.addSubview(scrollView)
 
        
        createTitleLabel()
        createWikiPicture()
        createTextView()
        
    }
    
    func createTitleLabel() {
        // Add titleLabel
        titleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 36)
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 2
        titleLabel.sizeToFit()
        
        scrollView.addSubview(titleLabel)
        
        titleLabel.leadingAnchor.constraint(equalTo: widget.leadingAnchor, constant: 10.0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: widget.trailingAnchor, constant: -10.0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 5.0).isActive = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func createWikiPicture() {
        
        wikiPicture.image = #imageLiteral(resourceName: "WikiIcon")
        scrollView.addSubview(wikiPicture)
        
        wikiPicture.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10.0).isActive = true
        wikiPicture.leadingAnchor.constraint(equalTo: widget.leadingAnchor, constant: 10.0).isActive = true
        wikiPicture.heightAnchor.constraint(equalToConstant: 75).isActive = true
        wikiPicture.widthAnchor.constraint(equalToConstant: 75).isActive = true
        wikiPicture.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func createTextView() {

        scrollView.addSubview(textView)
        
        textView.isEditable = false
        textView.textColor = UIColor.white
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.font = defaultFont
        textView.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\nExcepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"
        
        textView.topAnchor.constraint(equalTo: wikiPicture.bottomAnchor, constant: 10.0).isActive = true
        textView.leadingAnchor.constraint(equalTo: widget.leadingAnchor, constant: 5.0).isActive = true
        textView.trailingAnchor.constraint(equalTo: widget.trailingAnchor, constant: -5).isActive = true
        textView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func createDismissButton() {
        let button = UIButton(frame: self.view.bounds)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dissmissController))
        self.view.addGestureRecognizer(tapGesture)
        button.addGestureRecognizer(tapGesture)
        
        self.view.addSubview(button)
    }
    
    func dissmissController() {
        dismiss(animated: true, completion: nil)
    }
    
    
}
