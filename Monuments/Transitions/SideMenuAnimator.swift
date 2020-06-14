//
//  SideMenuAnimator.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 02/05/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class SideMenuAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Properties
    
    var isPresenting = true
    let duration: TimeInterval = 0.25
    let drawerWidthRatio: CGFloat = 0.75
    
    // MARK: - Handlers
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        let containerView = transitionContext.containerView
        
        let animationDuration = transitionDuration(using: transitionContext)
        let finalWidth = fromViewController.view.bounds.width * drawerWidthRatio
        
        if isPresenting {
            // Add the Menu ViewController to container
            containerView.addSubview(toViewController.view)
            
            // Init frame off screen
            toViewController.view.transform = .identity
            toViewController.view.frame.origin = CGPoint(x: 0, y: 0)
            toViewController.view.transform = CGAffineTransform(translationX: -finalWidth, y: 0)
        }
        
        let transform = {
            fromViewController.view.transform = CGAffineTransform(translationX: -finalWidth, y: 0)
        }
        
        let identity = {
            toViewController.view.transform = .identity
        }
        
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                self.isPresenting ? identity() : transform()
                print("fromViewController: \(fromViewController.view.transform.tx), toViewController: \(toViewController.view.transform.tx)")
        }, completion: { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
