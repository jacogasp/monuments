//
//  AnnotationsDetailsVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 15.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class AnnotationDetailsVC: UIViewController, UIScrollViewDelegate {
    
    var monument: MNMonument?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var wikiImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var wikiImageView: UIImageView!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    let bottomBorder = CALayer()

    
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = self.monument?.title
        self.subtitleLabel.text = self.monument?.subtitle
        
        if let url = monument?.wikiUrl {
            getWikiSummary(pageid: url)
        } else {
            self.wikiImageHeightConstraint.constant = 1.0
        }
        
        self.scrollView.scrollsToTop = true
    }
    
    override func viewDidLayoutSubviews() {
        bottomBorder.frame = CGRect(x: 0.5 * (topBar.frame.size.width - view.frame.size.width),
                                  y: topBar.frame.size.height - 1.0,
                                  width: view.frame.size.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.clear.cgColor
        topBar.layer.addSublayer(bottomBorder)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y <= 0) {
            bottomBorder.backgroundColor = UIColor.clear.cgColor
        } else {
            bottomBorder.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWikiSummary(pageid: String) {

        let wikiUrl = localizedWikiUrl(localizedPageId: pageid)
        let url = wikiUrl.0
        let parameters = wikiUrl.1

        print("Start query on wikipedia \(url)\(parameters)...", terminator: " ")

        Alamofire.request(url, parameters: parameters).responseJSON { response in
            //print("\n\(String(describing: response.request))") // Print the complete url for query

            if let value = response.result.value {
                //print("\(value)")  // Print the complete response
                let json = JSON(value)

                if let pages = json["query"]["pages"].dictionary {
                    if let page = pages.first {
                        if page.key != "-1" {
                            let details = page.value

                            let extract = details["extract"].stringValue
                            if !(extract.isEmpty) {
                                self.textField.text = extract + "\nWikipedia."
                            } else {
                            self.textField.text = "Nessuna informazione."
                            }

                            let thumbnailUrl = details["thumbnail"]["source"].stringValue
                            if thumbnailUrl != "" {
                                //print(thumbnailUrl)
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
                self.wikiImageView.image = image
                let ratio = self.wikiImageView.bounds.size.width / image.size.width
                self.wikiImageHeightConstraint.constant = ratio * image.size.height

                self.view.layoutIfNeeded()
                print("Query completed.\n")
            }
        }
    }
    
    func localizedWikiUrl(localizedPageId: String) -> (String, [String: Any]) {
    
        let lang = (localizedPageId.components(separatedBy: ":").first)!
        let pageid = (localizedPageId.components(separatedBy: ":").last)!
        
        var parameters = [
            "action": "query",
            "format": "json",
            "prop": "extracts|pageimages",
            "list": "",
            "exintro": 1,
            "explaintext": 1,
            "pithumbsize": "600"] as [String: Any]
        
        let digits = CharacterSet.decimalDigits
        
        for c in pageid.unicodeScalars {
            if !digits.contains(c) {
                parameters["titles"] =  pageid
                break
            } else {
                parameters["pageids"] =  pageid
            }
        }
        
        switch lang {
        case "it":
            return ("https://it.wikipedia.org/w/api.php", parameters)
        case "de":
            return ("https://de.wikipedia.org/w/api.php", parameters)
        default:
            return ("https://en.wikipedia.org/w/api.php", parameters)
        }
    }
}
