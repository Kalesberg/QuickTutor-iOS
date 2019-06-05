//
//  ProfileVCHeaderCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 11/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class ProfileVCHeaderCell: UICollectionReusableView {
    var parentViewController: ProfileVC? {
        didSet {
            profileToggleView.profileDelegate = parentViewController
        }
    }
    
    var didClickProfileHeader: (() -> ())?
    var didClickDayModelButton: (() -> ())?
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 45
        iv.clipsToBounds = true
        return iv
    }()
    
    let dayModeButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "ic_profile_day"), for: .normal)
        return button
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBlackSize(20)
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 5
        
        return stackView
    }()
    
    let featuredLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createSize(14)
        return label
    }()
    
    let ratingLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.purple
        label.text = "5.0"
        label.font = Fonts.createBlackSize(14)
        return label
    }()
    
    let starIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "ic_star_filled"))
        iv.contentMode = .scaleAspectFit
        iv.image = iv.image!.withRenderingMode(.alwaysTemplate)
        iv.tintColor = Colors.purple
        return iv
    }()
    
    let viewProfileView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let viewProfileLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "View profile"
        label.font = Fonts.createSemiBoldSize(16)
        return label
    }()
    
    let actionsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "rightArrow"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    let profileToggleView: MockCollectionViewCell = {
        let view = MockCollectionViewCell()
        return view
    }()
    
    func setupViews() {
        setupMainView()
        setupProfileImageView()
        setupDayModeButton()
        setupNameLabel()
        setupStackView()
        setupViewProfileView()
        setupProfileToggleView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.newScreenBackground
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(90)
            make.height.equalTo(90)
        }
    }
    
    func setupDayModeButton() {
        addSubview(dayModeButton)
        dayModeButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView).offset(-6)
            make.right.equalToSuperview().offset(-14)
            make.width.equalTo(32)
            make.height.equalTo(32)
        }
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top).offset(22)
            make.left.equalTo(profileImageView.snp.right).offset(20)
            make.right.greaterThanOrEqualToSuperview().offset(-20)
        }
    }
    
    func setupStackView() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(nameLabel.snp.left)
            make.height.equalTo(20)
        }
        
        stackView.addArrangedSubview(featuredLabel)
        stackView.addArrangedSubview(ratingLabel)
        stackView.addArrangedSubview(starIcon)
        starIcon.snp.makeConstraints { make in
            make.width.equalTo(11)
            make.height.equalTo(11)
        }
    }
    
    func setupViewProfileView() {
        addSubview(viewProfileView)
        viewProfileView.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.left)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        viewProfileView.addSubview(viewProfileLabel)
        viewProfileLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        viewProfileView.addSubview(actionsButton)
        actionsButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
    }
    
    func setupProfileToggleView() {
        addSubview(profileToggleView)
        profileToggleView.snp.makeConstraints { make in
            make.left.equalTo(viewProfileView.snp.left)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(viewProfileView.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
        profileToggleView.profileDelegate = parentViewController
    }
    
    func updateUI() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserFetchService.shared.getUserOfCurrentTypeWithId(uid) { (user) in
            guard let user = user else { return }
            self.nameLabel.text = user.formattedName
            self.profileImageView.sd_setImage(with: user.profilePicUrl, completed: nil)
            if AccountService.shared.currentUserType == .learner {
                self.featuredLabel.isHidden = true
            } else {
                self.featuredLabel.isHidden = false
                self.featuredLabel.text = CurrentUser.shared.tutor.featuredSubject?.capitalizingFirstLetter()
            }
        }
        
        if AccountService.shared.currentUserType == .learner {
            ratingLabel.text = "\(CurrentUser.shared.learner.lRating ?? 5.0)"
        } else {
            ratingLabel.text = "\(CurrentUser.shared.tutor.tRating ?? 5.0)"
        }
    }
    
    func setupTargets() {
        actionsButton.isUserInteractionEnabled = false
        viewProfileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelfTap)))
        dayModeButton.addTarget(self, action: #selector(onClickBtnDayMode), for: .touchUpInside)
    }
    
    @objc
    func handleSelfTap() {
        didClickProfileHeader?()
    }
    
    @objc
    func onClickBtnDayMode() {
        didClickDayModelButton?()
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

