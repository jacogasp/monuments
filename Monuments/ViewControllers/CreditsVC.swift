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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        // Do any additional setup after loading the view.
        if let textPath = Bundle.main.url(forResource: "Info_credits", withExtension: "rtf") {
            do {
                let attributedStringWithRtf: NSAttributedString = try NSAttributedString(
					url: textPath,
					options: [
						NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf
					],
					documentAttributes: nil)
                self.textView.attributedText = attributedStringWithRtf
            } catch {
                print("We got an error reading rtf \(error)")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            NotificationCenter.default.post(name: NSNotification.Name("resumeSceneLocationView"), object: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
