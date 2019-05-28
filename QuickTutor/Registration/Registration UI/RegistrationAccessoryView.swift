//
//  RegistrationAccessoryView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class RegistrationAccessoryView: UIView {
    
    let nextButton: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.purple
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.setTitle("CONTINUE", for: .normal)
        button.layer.cornerRadius = 4
        return button
    }()
    
    var nextButtonWidthAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupMainView()
        setupNextButton()
    }
    
    func setupMainView() {
        backgroundColor = Colors.accessoryBackground
        addDropShadow()
    }
    
    func setupNextButton() {
        addSubview(nextButton)
        nextButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 20, paddingRight: 30, width: 0, height: 0)
        nextButtonWidthAnchor = nextButton.widthAnchor.constraint(equalToConstant: 120)
        nextButtonWidthAnchor?.isActive = true
    }
    
    func addDropShadow() {
        layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.2, offset: CGSize(width: 0, height: -5), radius: 10)
        nextButton.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.2, offset: .zero, radius: 4)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
