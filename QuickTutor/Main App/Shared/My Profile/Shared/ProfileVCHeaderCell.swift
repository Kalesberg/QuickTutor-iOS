//
//  ProfileVCHeaderCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 11/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

protocol ProfileVCHeaderCellDelegate: class {
    func profileVCHeaderCellShouldHandleTap(_ cell: ProfileVCHeaderCell)
}

class ProfileVCHeaderCell: UICollectionReusableView {
    
    weak var delegate: ProfileVCHeaderCellDelegate?
    
    var parentViewController: ProfileVC? {
        didSet {
            profileToggleView.profileDelegate = parentViewController
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 4
        iv.clipsToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Zach F."
        label.font = Fonts.createBoldSize(24)
        return label
    }()
    
    let ratingLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.purple
        label.text = "★ 5.0"
        label.font = Fonts.createBoldSize(14)
        return label
    }()
    
    let actionsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "profileEditPencil"), for: .normal)
        return button
    }()
    
    let profileToggleView: MockCollectionViewCell = {
        let view = MockCollectionViewCell()
        return view
    }()
    
    func setupViews() {
        setupMainView()
        setupProfileImageView()
        setupNameLabel()
        setupRatingLabel()
        setupActionsButton()
        setupProfileToggleView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.newBackground
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 25, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 30)
    }
    
    func setupRatingLabel() {
        addSubview(ratingLabel)
        ratingLabel.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nameLabel.rightAnchor, paddingTop: 1, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 17)
    }
    
    func setupActionsButton() {
        addSubview(actionsButton)
        actionsButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 20, height: 20)
        addConstraint(NSLayoutConstraint(item: actionsButton, attribute: .centerY, relatedBy: .equal, toItem: profileImageView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func setupProfileToggleView() {
        addSubview(profileToggleView)
        profileToggleView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        profileToggleView.profileDelegate = parentViewController
    }
    
    func updateUI() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DataService.shared.getUserOfCurrentTypeWithId(uid) { (user) in
            guard let user = user else { return }
            self.nameLabel.text = user.formattedName
            self.profileImageView.sd_setImage(with: user.profilePicUrl, completed: nil)
        }
    }
    
    func setupTargets() {
        actionsButton.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
    }
    
    @objc func handleEditProfile() {
        delegate?.profileVCHeaderCellShouldHandleTap(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        updateUI()
        setupTargets()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

