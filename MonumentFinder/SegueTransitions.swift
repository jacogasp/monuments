//
//  SegueTransitions.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 06.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class UIStoryboardSegueFromRight: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)

    dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { finished in src.present(dst, animated: false, completion: nil) })
    }
}

class UIStoryboardSegueFromLeft: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { finished in src.present(dst, animated: false, completion: nil) })
    }
}

class UIStoryboardSeguePushFromBottom: UIStoryboardSegue {
    override func perform() {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        
        src.view.transform = CGAffineTransform(translationX: 0, y: 0)
        dst.view.transform = CGAffineTransform(translationX: 0, y: src.view.frame.size.height)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            src.view.transform = CGAffineTransform(translationX: 0, y: -src.view.frame.size.height)
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
            
        }, completion: {finished in src.present(dst, animated: false, completion: nil)})
    }
}
