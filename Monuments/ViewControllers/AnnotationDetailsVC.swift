//
//  AnnotationsDetailsVC.swift
//  MonumentFinder
//
//  Created by Jacopo Gasparetto on 15.05.17.
//  Copyright © 2017 Jacopo Gasparetto. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

protocol AnnotationDetailsDelegate: class {
    func annotationDetails(_ annotationDetails: AnnotationDetailsVC, viewControllerDidDisapper animated: Bool)
}

class AnnotationDetailsVC: UIViewController {
    
    struct Constants {
        static let indicatorYOffset = CGFloat(8.0)
        static let snapMovementSensitivity = CGFloat(0.7)
        static let dragIndicatorSize = CGSize(width: 36.0, height: 5.0)
        static let fullView: CGFloat = 100
        static var partialView: CGFloat {
            return UIScreen.main.bounds.height - 120
        }
    }
    
    var monument: Monument?
    weak var delegate: AnnotationDetailsDelegate?
    var comingFromMapViewController: Bool = false
    var height: CGFloat!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var wikiImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var wikiImageView: UIImageView!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    let bottomBorder = CALayer()
    
    @IBAction func dismissButton(_ sender: Any) {
        if comingFromMapViewController {
            hideAndRemoveFromParent()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let monument = self.monument {
            self.titleLabel.text = monument.name
            self.subtitleLabel.text = String.localizedStringWithCounts(monument.category!, 1)
        }
        
        if let _ = self.parent as? MapVC {
            comingFromMapViewController = true
            makeTopRoundCorners(radius: 10)
            self.addDragIndicatorView(to: self.view)
            self.setupPanGensture()
            self.height = monument?.wikiUrl != nil ?  Constants.fullView : Constants.partialView
        }

        if let url = monument?.wikiUrl {
            getWikiSummary(pageid: url)
        } else {
            self.wikiImageView.removeFromSuperview()
            self.textField.removeFromSuperview()
        }
        
        self.scrollView.scrollsToTop = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Open the view controller with proper height if presented by the Map VC
        if comingFromMapViewController {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                let frame = self?.view.frame
                let yComponent = self?.monument?.wikiUrl != nil ? Constants.fullView : Constants.partialView
                self?.view.frame = CGRect(x: 0, y: yComponent, width: frame!.width, height: frame!.height - 100)
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        let x = 0.5 * (topBar.frame.size.width - view.frame.size.width)
        let y = topBar.frame.size.height - 1.0
        bottomBorder.frame = CGRect(x: x, y: y, width: view.frame.size.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.clear.cgColor
        topBar.layer.addSublayer(bottomBorder)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Animate the view controller until it disappears and remove it from the parent view controller
    public func hideAndRemoveFromParent() {
        
        UIView.animate(withDuration: 0.3, animations: {
            let y =  UIScreen.main.bounds.height
            self.view.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: ({_ in
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.delegate?.annotationDetails(self, viewControllerDidDisapper: true)
        }))
    }
    
    // MARK: Round Corners
    private func makeTopRoundCorners(radius: CGFloat) {
        self.view.clipsToBounds = true
        self.view.layer.cornerRadius = radius
        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    // MARK: Drag Indicator
    private lazy var dragIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = Constants.dragIndicatorSize.height / 2.0
        return view
    }()
    
    /// Add the drag indicator view only if coming from MapViewController
    func addDragIndicatorViewIfNeeded() {
        if comingFromMapViewController == true && monument?.wikiUrl != nil {
            addDragIndicatorView(to: self.view)
        }
    }
    
    func addDragIndicatorView(to view: UIView) {
        view.addSubview(dragIndicatorView)
        dragIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        dragIndicatorView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: Constants.indicatorYOffset).isActive = true
        dragIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dragIndicatorView.widthAnchor.constraint(equalToConstant: Constants.dragIndicatorSize.width).isActive = true
        dragIndicatorView.heightAnchor.constraint(equalToConstant: Constants.dragIndicatorSize.height).isActive = true
        view.bringSubviewToFront(dragIndicatorView)
    }
    
    // MARK: Pan Gesture
    func setupPanGensture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture))
        panGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        let y = self.view.frame.minY
        
        // If the finger is in between the full view and the partial view, move the the frame accordingly with the translation
        // and anchor the translation point to the top (CGPoint.zero) of the view controller itself in order to have a smooth animation
        if (y + translation.y >= self.height) && (y + translation.y <= UIScreen.main.bounds.maxY) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration = velocity.y < 0 ? Double((y - self.height) / -velocity.y) : Double((UIScreen.main.bounds.maxY - y) / velocity.y )
            
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.maxY, width: self.view.frame.width, height: self.view.frame.height)
                } else {
                    self.view.frame = CGRect(x: 0, y: self.height, width: self.view.frame.width, height: self.view.frame.height)
                }
                
            }, completion: { [weak self] _ in
                if (velocity.y >= 0) {
                    // Exit
                    self?.hideAndRemoveFromParent()
                } else {
                    self?.scrollView.isScrollEnabled = true
                }
            })
        }
    }
    
    // MARK: - Wikipedia
    
    func getWikiSummary(pageid: String) {
        
        logger.debug("Start querying Wikipedia")
        
        let wikiUrl = localizedWikiUrl(localizedPageId: pageid)
        let url = wikiUrl.0
        let parameters = wikiUrl.1
        
        Alamofire.request(url, parameters: parameters).responseJSON { response in
            
            switch response.result {
            case .success:
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                        if let pages = json?["query"]?["pages"] as? [String:AnyObject] {
                            if let firstPage = pages.first {
                                if firstPage.key == "-1" { throw WikipediaError.noPagesFound }
                                
                                if let pageContent = firstPage.value as? [String:AnyObject] {
                                    guard let extract = pageContent["extract"] as? String else { throw WikipediaError.noExtractFound }
                                    self.textField.text = extract
                                    
                                    if let thumbnailUrl = pageContent["thumbnail"]?["source"] as? String {
                                        self.getWikiPicture(url: thumbnailUrl)
                                    }
                                }
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                        self.textField.text = NSLocalizedString("No information found.", comment: "")
                    }
                }
                
            case .failure(let error):
                logger.error("Failed to load wikipedia data with error: \(error)")
            }
        }
    }
    
    func getWikiPicture(url: String) {
        Alamofire.request(url).responseImage { response in
            if let image = response.result.value {
                self.wikiImageView.image = image
                let ratio = self.wikiImageView.bounds.size.width / image.size.width
                self.wikiImageHeightConstraint.constant = ratio * image.size.height
                
                self.view.layoutIfNeeded()
                logger.debug("Query completed")
            }
        }
    }
    
    func localizedWikiUrl(localizedPageId: String) -> (String, [String: String]) {
        
        let lang = (localizedPageId.components(separatedBy: ":").first)!
        let pageid = (localizedPageId.components(separatedBy: ":").last)!
        
        var parameters = [
            "action": "query",
            "format": "json",
            "prop": "extracts|pageimages",
            "list": "",
            "exintro": "1",
            "explaintext": "1",
            "pithumbsize": "600"]
        
        let digits = CharacterSet.decimalDigits
        
        for c in pageid.unicodeScalars {
            if !digits.contains(c) {
                parameters["titles"] =  pageid
                break
            } else {
                parameters["pageids"] =  pageid
            }
        }
        
        switch lang {
        case "it":
            return ("https://it.wikipedia.org/w/api.php", parameters)
        case "de":
            return ("https://de.wikipedia.org/w/api.php", parameters)
        default:
            return ("https://en.wikipedia.org/w/api.php", parameters)
        }
    }
}

// MARK: - ScrollView Delegate

extension AnnotationDetailsVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y <= 0) {
            bottomBorder.backgroundColor = UIColor.clear.cgColor
        } else {
            bottomBorder.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }
}

// MARK: - Gesture Recognizer Delegate

extension AnnotationDetailsVC: UIGestureRecognizerDelegate {
    // Solution
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y
        
        let y = view.frame.minY
        if (y == Constants.fullView && scrollView.contentOffset.y == 0 && direction > 0) || (y == Constants.partialView) {
            scrollView.isScrollEnabled = false
        } else {
            scrollView.isScrollEnabled = true
        }
        return false
    }
}

// MARK: - Wikipedia Errors

enum WikipediaError: Error, CustomStringConvertible {
    case noPagesFound
    case noExtractFound
    
    var description: String {
        switch self {
        case .noPagesFound:
            return "No pages found."
        case .noExtractFound:
            return "No extract found."
        }
    }
}
