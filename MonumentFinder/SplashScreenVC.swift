//
//  SplashScreenVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 22/11/2017.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class SplashScreenVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        perform(#selector(presentViewController), with: nil, afterDelay: 1.0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func presentViewController() {
        performSegue(withIdentifier: "toViewController", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
