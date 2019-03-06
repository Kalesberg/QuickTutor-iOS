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
    
    func setupViews() {
        setupMainView()
        setupNextButton()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupNextButton() {
        addSubview(nextButton)
        nextButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 20, paddingRight: 30, width: 120, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
