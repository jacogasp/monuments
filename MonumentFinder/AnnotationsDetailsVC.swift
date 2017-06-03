//
//  AnnotationsDetailsVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 15.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftyJSON
import Alamofire

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
        
        if titolo != nil {
            getWikiSummary(titolo: titolo!)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getWikiSummary(titolo: String) {
        print("Start query...\n")
        let parameters = [
            "action": "query",
            "format": "json",
            "prop": "extracts|pageimages",
            "list": "",
            "titles": titolo,
            "exintro": 1,
            "explaintext": 1,
            "pithumbsize": "300"

        ] as [String : Any]
        
        // https://en.wikipedia.org/w/api.php?action=query&titles=Alban%20Stolz&prop=pageimages&pithumbsize=300
        
        let url = "https://en.wikipedia.org/w/api.php"
        
        Alamofire.request(url, parameters: parameters).responseJSON { response in
            print("\(String(describing: response.request))")
            if let value = response.result.value {
                print("\(value)")
                
                let json = JSON(value)
                if let pages = json["query"]["pages"].dictionary {
                    if let page = pages.first {
                        if page.key != "-1" {
                            let details = page.value
                            
                            let extract = details["extract"].stringValue
                            if !(extract.isEmpty) {
                                self.textField.text = extract
                            } else {
                            self.textField.text = "Nessuna informazione."
                            }

                            
                            let thumbnailUrl = details["thumbnail"]["source"].stringValue
                            if thumbnailUrl != "" {
                                self.getWikiPicture(url: thumbnailUrl)
                            }
                            
                        } else {
                            self.textField.text = "Nessuna informazione."
                        }
                    } else {
                        self.textField.text = "Nessuna informazione"
                    }
                } else {
                  self.textField.text = "Nessuna informazione."
                }
            } else {
                self.textField.text = "Nessuna informazione."
            }
        }

    }
    
    func getWikiPicture(url: String) {
        Alamofire.request(url).responseImage { response in
            if let image = response.result.value {
                //print("image downloaded: \(image)")
                self.wikiImageView.image = image
            }
        }
    }

    
}
