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
        button.backgroundColor = Colors.purple
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
        backgroundColor = Colors.darkBackground
        layer.cornerRadius = 4
        layer.borderColor = Colors.gray.cgColor
        layer.borderWidth = 1
        layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: .zero, radius: 4)
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        let modeText = AccountService.shared.currentUserType.rawValue
        titleLabel.text = modeText.capitalized + " mode"
    }
    
    func setupPrimaryButton() {
        addSubview(primaryButton)
        primaryButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(60)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        primaryButton.addTarget(self, action: #selector(handlePrimaryButton), for: .touchUpInside)
    }
    
    func setupSecondaryButton() {
        addSubview(secondaryButton)
        secondaryButton.snp.makeConstraints { make in
            make.right.equalTo(primaryButton.snp.left).offset(-10)
            make.width.equalTo(75)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        secondaryButton.addTarget(self, action: #selector(handleSecondaryButton), for: .touchUpInside)
    }

    @objc func handlePrimaryButton() {
        primaryButton.backgroundColor = Colors.purple
        primaryButton.isSelected = true
        secondaryButton.backgroundColor = Colors.gray
        secondaryButton.isSelected = false
        let newUserType: UserType = AccountService.shared.currentUserType == .learner ? .tutor : .learner
        delegate?.mockCollectionViewCellDidSelectPrimaryButton(self)
        profileDelegate?.profleModeToggleView(self, shouldSwitchTo: newUserType)
    }
    
    @objc func handleSecondaryButton() {
        secondaryButton.backgroundColor = Colors.purple
        secondaryButton.isSelected = true
        primaryButton.backgroundColor = Colors.gray
        primaryButton.isSelected = false
        delegate?.mockCollectionViewCellDidSelectSecondaryButton(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupMainView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
