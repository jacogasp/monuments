//
//  SideMenuViewCell.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 02/05/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import UIKit

class SideMenuViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    let fontSize: CGFloat = 20.0
    let fontName = "HelveticaNeue-Regular"
    let imageSize: CGFloat = 25.0
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .clear
        textLabel?.font = UIFont(name: fontName, size: fontSize)
        textLabel?.textColor = .white
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
    }

    // MARK: - Handlers
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
