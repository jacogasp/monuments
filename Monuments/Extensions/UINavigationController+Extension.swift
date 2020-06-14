//
//  UINavigationController+Extension.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 03/05/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import UIKit

extension UINavigationController {
        
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: {
            print("dismiss")
        })
    }
}
