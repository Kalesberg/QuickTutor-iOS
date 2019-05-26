//
//  TheChoiceVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/7/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class TheChoiceVCView: UIView {
    
    var userType: UserType = .learner
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "You're all set!"
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createBlackSize(20)
        return label
    }()
    
    let laterLabel: UILabel = {
        let label = UILabel()
        label.text = "You can always become a tutor later."
        label.textAlignment = .center
        label.textColor = Colors.grayText
        label.font = Fonts.createBlackSize(14)
        return label
    }()
    
    let buttonContainer: UIView = {
        let view = UIView()
        view.layer.borderColor = Colors.gray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        return view
    }()
    
    let choiceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "What would you like to do now?"
        label.font = Fonts.createBoldSize(14)
        return label
    }()
    
    let learnButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.purple
        button.layer.cornerRadius = 4
        button.setTitle("Learn", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(14)
        return button
    }()
    
    let tutorButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.gray
        button.layer.cornerRadius = 4
        button.setTitle("Tutor", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(14)
        return button
    }()
    
    let startButton: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.purple
        button.layer.cornerRadius = 4
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(14)
        return button
    }()
    
    func setupViews() {
        setupMainView()
        setupButtonContainer()
        setupLearnButton()
        setupTutorButton()
        setupChoiceLabel()
        setupTitleLabel()
        setupLaterLabel()
        setupStartButton()
    }
    
    func setupMainView(){
        backgroundColor = Colors.darkBackground
    }
    
    func setupButtonContainer() {
        addSubview(buttonContainer)
        buttonContainer.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 270, height: 122)
        addConstraint(NSLayoutConstraint(item: buttonContainer, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: buttonContainer, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -61))
    }
    
    func setupLearnButton() {
        addSubview(learnButton)
        learnButton.anchor(top: nil, left: buttonContainer.leftAnchor, bottom: buttonContainer.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 0, width: 110, height: 40)
        learnButton.addTarget(self, action: #selector(chooseLearner), for: .touchUpInside)
    }
    
    func setupTutorButton() {
        addSubview(tutorButton)
        tutorButton.anchor(top: nil, left: nil, bottom: buttonContainer.bottomAnchor, right: buttonContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 20, width: 110, height: 40)
        tutorButton.addTarget(self, action: #selector(chooseTutor), for: .touchUpInside)
    }
    
    func setupChoiceLabel() {
        addSubview(choiceLabel)
        choiceLabel.anchor(top: buttonContainer.topAnchor, left: buttonContainer.leftAnchor, bottom: nil, right: buttonContainer.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: leftAnchor, bottom: buttonContainer.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 118, paddingRight: 0, width: 0, height: 30)
    }
    
    func setupLaterLabel() {
        addSubview(laterLabel)
        laterLabel.anchor(top: buttonContainer.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
    }
    
    func setupStartButton() {
        addSubview(startButton)
        startButton.anchor(top: laterLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 102, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 180, height: 44)
        addConstraint(NSLayoutConstraint(item: startButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        
    }
    
    @objc func chooseLearner() {
        tutorButton.backgroundColor = Colors.gray
        learnButton.backgroundColor = Colors.purple
        userType = .learner
    }
    
    @objc func chooseTutor() {
        tutorButton.backgroundColor = Colors.purple
        learnButton.backgroundColor = Colors.gray
        userType = .tutor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
