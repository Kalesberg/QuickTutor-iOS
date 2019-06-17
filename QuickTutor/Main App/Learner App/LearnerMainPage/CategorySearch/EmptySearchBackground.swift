//
//  EmptySearchBackground.swift
//  QuickTutor
//
//  Created by Zach Fuller on 6/11/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class EmptySearchBackground: UIView {
    
    let icon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "emptySearchBackground")
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBlackSize(20)
        label.textColor = .white
        label.text = "No Tutors Available."
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(15)
        label.textColor = .gray
        label.numberOfLines = 2
        label.text = "Try adjusting your filters or \nsearching for something similar!"
        return label
    }()
    
    func setupViews() {
        setupIcon()
        setupTitleLabel()
        setupSubtitleLabel()
    }
    
    func setupIcon() {
        addSubview(icon)
        icon.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 72, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 143, height: 172)
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: icon.bottomAnchor, left: icon.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 300, height: 24)
    }
    
    func setupSubtitleLabel() {
        addSubview(subtitleLabel)
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 300, height: 50)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
