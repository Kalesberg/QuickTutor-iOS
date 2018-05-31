//
//  FileReportActionsheetCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class FileReportActionsheetCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createSize(16)
        return label
    }()
    
    func setupViews() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        backgroundColor = UIColor(hex: "272731")
    }
    
    @objc func darken() {
        backgroundColor = backgroundColor?.darker(by: 15)
        titleLabel.textColor = titleLabel.textColor.darker(by: 15)
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                darken()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
