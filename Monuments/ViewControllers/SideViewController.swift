//
//  SideViewController.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 26/04/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class SideViewController: UIViewController {
    
    // MARK: - Properties
    
    enum Direction: CGFloat {
        case left = -1
        case right = 1
    }
    
    var drawerView: UIView!
    var delegate: SideMenuControllerDelegate?
    var direction = Direction.left
    let drawerWidth = UIScreen.main.bounds.width * 3 / 4
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        // Setups
        setupTapGesture()
        setupDrawerView()
        setupPanGesture()
    }
    
    // MARK: - Handlers
    
    func setupDrawerView() {
        drawerView = UIView()
        drawerView.frame = CGRect(x: 0, y: 0, width: drawerWidth, height: self.view.bounds.height)
        self.view.addSubview(drawerView)
    }
    
    func setupPanGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.drawerView.addGestureRecognizer(gesture)
    }
    
    func setupTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: self.drawerView)
        let percent = translation.x / self.drawerView.frame.width * direction.rawValue
        switch pan.state {
        case .began:
            print("BEGAN", self.view.transform.tx)
        case .changed:
            if percent > 0 {
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 1,
                    options: .curveEaseOut,
                    animations: {
                        self.navigationController?.view.transform = CGAffineTransform(translationX: translation.x, y: 0)
                    })
            }
        case .ended:
            if percent < 0.5 {
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 1,
                    options: .curveEaseOut,
                    animations: {
                        self.navigationController?.view.transform = .identity
                })
            } else {
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 1,
                    options: .curveEaseOut,
                    animations: {
                        self.navigationController?.view.frame.origin.x = self.drawerView.bounds.width * self.direction.rawValue
                })
                self.dismiss(animated: false, completion: { self.delegate?.didDisappeared() })
            }
        default:
            break
        }
    }
    
    
    @objc func handleTapGesture(_ tap: UITapGestureRecognizer) {
        logger.verbose("Dismiss SideMenu")
        self.dismiss(animated: true, completion: {
            self.delegate?.didDisappeared()
        })
    }
}

// MARK: - GestureRecognizer Delegate

extension SideViewController: UIGestureRecognizerDelegate {
    // Fix to prevent subviews receivece touch
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
}
