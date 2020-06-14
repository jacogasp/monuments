//
//  ContainerViewController.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 26/04/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    // MARK: - Properties
    
    var leftMenuController: LeftMenuViewController!
    var leftNavigationController: UINavigationController!
    var centerController: ViewController!
    let transition = SideMenuAnimator()
    var isExpanded = false
    let navigationBarColor = #colorLiteral(red: 0.9294117647, green: 0.1294117647, blue: 0.2274509804, alpha: 1)
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHomeController()
    }
    
    // MARK: - Handlers
    
    func setupHomeController() {
        centerController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ViewController") as ViewController
        centerController.delegate = self
        view.addSubview(centerController.view)
        addChild(centerController)
        centerController.didMove(toParent: self)
    }
    
    func setupSideViewController() {
        if leftNavigationController == nil {
            leftMenuController = LeftMenuViewController()
            leftNavigationController = UINavigationController(rootViewController: leftMenuController)
            leftNavigationController.isNavigationBarHidden = true
            leftNavigationController.navigationBar.barTintColor = navigationBarColor
            leftNavigationController.navigationBar.tintColor = .white
            leftNavigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            leftNavigationController.transitioningDelegate = self
            logger.debug("Did add left Side Menu ")
        }
    }
    
    func showLeftSideController() {
        setupSideViewController()
        leftNavigationController.modalPresentationStyle = .overFullScreen
        self.present(leftNavigationController, animated: true, completion: nil)
    }
}

extension ContainerViewController: HomeControllerDelegate {
    func handleMenuToggle() {
        showLeftSideController()
    }
}

extension ContainerViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return transition
    }
}
