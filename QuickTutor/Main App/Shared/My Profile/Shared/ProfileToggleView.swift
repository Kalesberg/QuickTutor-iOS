//
//  ProfileToggleView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 11/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol ProfileModeToggleViewDelegate: class {
    func profleModeToggleView(_ profileModeToggleView: MockCollectionViewCell, shouldSwitchTo side: UserType)
}

protocol MockCollectionViewCellDelegate: class {
    func mockCollectionViewCellDidSelectPrimaryButton( _ cell: MockCollectionViewCell)
    func mockCollectionViewCellDidSelectSecondaryButton( _ cell: MockCollectionViewCell)
}

extension MockCollectionViewCellDelegate {
    func mockCollectionViewCellDidSelectSecondaryButton( _ cell: MockCollectionViewCell) {}
}

class MockCollectionViewCell: UIView {
    
    var numberOfButtons = 1 {
        didSet {
            secondaryButton.isHidden = numberOfButtons == 1
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(16)
        label.text = "Learner mode"
        return label
    }()
    
    let primaryButton: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.currentUserColor()
        button.layer.cornerRadius = 4
        button.setTitle("Switch", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(12)
        return button
    }()
    
    let secondaryButton: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.gray
        button.layer.cornerRadius = 4
        button.setTitle("In-person", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(12)
        button.isHidden = true
        return button
    }()
    
    
    weak var profileDelegate: ProfileModeToggleViewDelegate?
    weak var delegate: MockCollectionViewCellDelegate?
    
    func setupViews() {
        setupMainView()
        setupTitleLabel()
        setupPrimaryButton()
        setupSecondaryButton()
    }
    
    func setupMainView() {
        layer.cornerRadius = 4
        layer.borderColor = Colors.gray.cgColor
        layer.borderWidth = 2
        backgroundColor = Colors.newBackground
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let modeText = AccountService.shared.currentUserType.rawValue
        titleLabel.text = modeText.capitalized + " mode"
    }
    
    func setupPrimaryButton() {
        addSubview(primaryButton)
        primaryButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 60, height: 30)
        addConstraint(NSLayoutConstraint(item: primaryButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        primaryButton.addTarget(self, action: #selector(handlePrimaryButton), for: .touchUpInside)
    }
    
    func setupSecondaryButton() {
        addSubview(secondaryButton)
        secondaryButton.anchor(top: nil, left: nil, bottom: nil, right: primaryButton.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 75, height: 30)
        addConstraint(NSLayoutConstraint(item: secondaryButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        secondaryButton.addTarget(self, action: #selector(handleSecondaryButton), for: .touchUpInside)
    }

    @objc func handlePrimaryButton() {
        primaryButton.backgroundColor = Colors.currentUserColor()
        primaryButton.isSelected = true
        secondaryButton.backgroundColor = Colors.gray
        secondaryButton.isSelected = false
        let newUserType: UserType = AccountService.shared.currentUserType == .learner ? .tutor : .learner
        delegate?.mockCollectionViewCellDidSelectPrimaryButton(self)
        profileDelegate?.profleModeToggleView(self, shouldSwitchTo: newUserType)
    }
    
    @objc func handleSecondaryButton() {
        secondaryButton.backgroundColor = Colors.currentUserColor()
        secondaryButton.isSelected = true
        primaryButton.backgroundColor = Colors.gray
        primaryButton.isSelected = false
        delegate?.mockCollectionViewCellDidSelectSecondaryButton(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}