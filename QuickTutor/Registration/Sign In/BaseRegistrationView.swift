//
//  BaseRegistrationView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class BaseRegistrationView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(22)
        label.numberOfLines = 0
        label.text = "This is a test"
        return label
    }()
    
    func setupViews() {
        setupMainView()
        setupTitleLabel()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: getTopAnchor(), left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 30, paddingBottom: 0, paddingRight: 60, width: 0, height: 90)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
