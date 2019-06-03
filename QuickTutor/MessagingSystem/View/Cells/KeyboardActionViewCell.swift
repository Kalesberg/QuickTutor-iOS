//
//  KeyboardActionViewCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/24/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class KeyboardActionViewCell: UICollectionViewCell {
    let icon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Session"
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createSize(12)
        return label
    }()

    func updateUI(title: String, image: UIImage) {
        icon.image = image
        titleLabel.text = title
    }
    
    func setupViews() {
        backgroundColor = Colors.newScreenBackground
        setupTitleLabel()
        setupButton()
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 12.5, paddingRight: 0, width: 0, height: 14)
    }
    
    private func setupButton() {
        addSubview(icon)
        icon.anchor(top: nil, left: leftAnchor, bottom: titleLabel.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 12, paddingRight: 0, width: 0, height: 45)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
