//
//  FiltriVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 06.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class FiltriVC: UIViewController {

    @IBAction func dismiss(_ sender: Any) {

        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.transform = CGAffineTransform(translationX: self.view.frame.size.width, y: 0)
        }, completion: { finished in self.dismiss(animated: false, completion: nil) })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*
        view.backgroundColor = UIColor.clear
        let origin = CGPoint(x: view.frame.size.width - view.frame.size.width * 0.75, y: 0.0)
        let size = CGSize(width: view.frame.size.width * 0.75, height: view.frame.size.height)
        let contenitore = UIView(frame: CGRect(origin: origin, size: size))
        contenitore.backgroundColor = UIColor.green
        view.addSubview(contenitore)
        */
        
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
