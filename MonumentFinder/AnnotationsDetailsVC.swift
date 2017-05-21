//
//  AnnotationsDetailsVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 15.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class AnnotationsDetailsVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentDetails(title: String) {
        print("yea")
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
