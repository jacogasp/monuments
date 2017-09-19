//
//  AnnotationsDetailsVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 15.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage
import SQLite

class AnnotationDetailsVC: UIViewController {
    
    var titolo: String?
    var categoria: String?
    var wikiUrl: String?
    
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
        
        
        
//        if let pageid = readSqlWiki(nome: titolo!) {
//            getWikiSummary(pageid: pageid)
//        } else {
//            self.textField.text = "Nessuna informazione."
//            print("No wikipedia data found in sql.\n")
//        }
        
        getWikiSummary(pageid: wikiUrl!)
        
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
                                self.textField.text = extract
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
                //print("image downloaded: \(image)")
                self.wikiImageView.image = image
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
            "pithumbsize": "300"
            ] as [String : Any]
        
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
    
    func readSqlWiki(nome: String) -> String? {
        
        let table = Table(selectedCity)
        
        let nomeSQL = Expression<String>("nome")
        let wikiSQL = Expression<String>("wiki")
        
        if let path = Bundle.main.path(forResource: "db", ofType: "sqlite") {
            do {
                let db = try Connection(path)
                //print("Succesfully connected to the sql database.")
                
                let query = table.select(wikiSQL).filter(nomeSQL == nome)
                if let row = try db.pluck(query) {
                    print("Search for wikipedia in sql...", terminator: " ")
                    let wikiId = row[wikiSQL]
                    if wikiId.isEmpty {
                        return nil
                    } else {
                        print ("Wikipedia data found in sql.")
                        return wikiId
                    }
                }
                
            } catch {
                print("Errore nel connettersi al database: \(error)")
            }
        }
        return nil
    }
}
