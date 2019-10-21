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

class AnnotationDetailsVC: UIViewController, UIScrollViewDelegate {
    
    var monument: Monument?
    
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
        
        if let monument = self.monument {
            self.titleLabel.text = monument.name
            self.subtitleLabel.text = String.localizedStringWithCounts(monument.category!, 1)
        }
        
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
        
        logger.debug("Start querying Wikipedia")
        
        let wikiUrl = localizedWikiUrl(localizedPageId: pageid)
        let url = wikiUrl.0
        let parameters = wikiUrl.1
        
        Alamofire.request(url, parameters: parameters).responseJSON { response in
                        
            switch response.result {
            case .success:
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                        if let pages = json?["query"]?["pages"] as? [String:AnyObject] {
                            if let firstPage = pages.first {
                                if firstPage.key == "-1" { throw WikipediaError.noPagesFound }
                                
                                if let pageContent = firstPage.value as? [String:AnyObject] {
                                    guard let extract = pageContent["extract"] as? String else { throw WikipediaError.noExtractFound }
                                    self.textField.text = extract
                                    
                                    if let thumbnailUrl = pageContent["thumbnail"]?["source"] as? String {
                                        self.getWikiPicture(url: thumbnailUrl)
                                    }
                                }
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                        self.textField.text = NSLocalizedString("No informations found.", comment: "")
                    }
                    
                }
                
            case .failure(let error):
                logger.error("Failed to load wikipedia data with error: \(error)")
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
                logger.debug("Query completed")
            }
        }
    }
    
    func localizedWikiUrl(localizedPageId: String) -> (String, [String: String]) {
    
        let lang = (localizedPageId.components(separatedBy: ":").first)!
        let pageid = (localizedPageId.components(separatedBy: ":").last)!
        
        var parameters = [
            "action": "query",
            "format": "json",
            "prop": "extracts|pageimages",
            "list": "",
            "exintro": "1",
            "explaintext": "1",
            "pithumbsize": "600"]
        
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

enum WikipediaError: Error, CustomStringConvertible {
    case noPagesFound
    case noExtractFound
    
    var description: String {
        switch self {
        case .noPagesFound:
            return "No pages found."
        case .noExtractFound:
            return "No extract found."
        }
    }
}
