//
//  AnnotationView.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 25/09/2019.
//  Copyright © 2019 Jacopo Gasparetto. All rights reserved.
//

import UIKit

@IBDesignable
class AnnotationView: UIView {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var moreImageView: UIImageView!
    
    var view: UIView!
    var distanceFromUser = 0.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    
    var annotation: Monument? {
        didSet {
            bindUi()
        }
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let nibName = String(describing:  AnnotationView.self)
        let bundle = Bundle(for: AnnotationView.self)
        
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    func bindUi() {
        titleLabel.text = annotation?.name
        categoryImageView.image = UIImage(named: "Theatre")
        moreImageView.isHidden = annotation?.wikiUrl == nil
        
        let distance = distanceFromUser > 1000 ? String(format: "%.1f Km", distanceFromUser / 1000) :
            String(format: "%.0f m", distanceFromUser)
        distanceLabel.text = distance
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = layer.frame.height / 2
        layer.masksToBounds = true
        view.backgroundColor = .white
    }
}
