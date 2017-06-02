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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .clear
        
        createDismissButton()
        
        let lateralOffset: CGFloat = 10.0
        let widget = UIView(frame: CGRect(x: lateralOffset, y: 50, width: self.view.frame.size.width - lateralOffset * 2, height: self.view.frame.size.height - 100))
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = widget.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.cornerRadius = 5
        
        widget.addSubview(blurEffectView)
        
        
        titleLabel.frame = CGRect(x: widget.bounds.minX + 10, y: widget.bounds.minY + 10, width: widget.bounds.width - 20, height: 50)
        titleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 28)
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 2
        titleLabel.sizeToFit()
        widget.addSubview(titleLabel)
        
        let wikiPicture = UIImageView(frame: CGRect(x: widget.bounds.minX + 10, y: widget.bounds.minY + 75, width: 75, height: 75))
        wikiPicture.image = #imageLiteral(resourceName: "WikiIcon")
        widget.addSubview(wikiPicture)
        
        let textView = UITextView(frame: CGRect(x: widget.bounds.minX + 10, y: widget.bounds.minY + 160, width: widget.bounds.width - 20, height: 300))
        textView.textColor = UIColor.white
        textView.backgroundColor = .clear
        textView.font = defaultFont
        textView.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\nExcepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"
        
        widget.addSubview(textView)
        
        
        self.view.addSubview(widget)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentDetails(title: String) {
        print("yea")
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
