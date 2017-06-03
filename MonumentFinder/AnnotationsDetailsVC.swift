//
//  AnnotationsDetailsVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 15.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class AnnotationDetailsVC: UIViewController {
    
    var titolo: String?
    var categoria: String?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!

    @IBOutlet weak var wikiImageView: UIImageView!
    
    @IBOutlet weak var textField: UITextView!
    
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        titleLabel.text = titolo ?? "Nessun titolo"
        categoryLabel.text = categoria ?? "Nessuna categoria"

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
}
