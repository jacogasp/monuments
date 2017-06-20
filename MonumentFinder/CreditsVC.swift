//
//  CretitsViewController.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 20.06.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class CreditsVC: UIViewController {

    @IBOutlet weak var textView: UITextView!

    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        // Do any additional setup after loading the view.
        if let textPath = Bundle.main.url(forResource: "Info_credits", withExtension: "rtf") {
            do {
                let attribuitedStringWithRtf: NSAttributedString = try NSAttributedString(url: textPath, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil)
                self.textView.attributedText = attribuitedStringWithRtf
            } catch {
                print("We got an error reading rtf \(error)")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
