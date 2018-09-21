//
//  AddTutorCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol AddTutorButtonDelegate {
	func addTutorWithUid(_ uid: String, completion: (() -> Void)?)
}

class AddTutorCell: UICollectionViewCell {
    
    var delegate: AddTutorButtonDelegate?
    var userId: String?
    
    let background: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "4C5E8D")
        view.layer.cornerRadius = 8
        return view
    }()
    
    let profileImageView: UserImageView = {
        let iv = UserImageView()
        iv.imageView.layer.cornerRadius = 45.5
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createSize(12)
        return label
    }()
    
    let statsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createSize(12)
        label.text = "148 hours taught, 14 complete sessions"
        return label
    }()
    
    let addButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "addTutorButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    func setupViews() {
        setupBackground()
        setupProfileImageview()
        setupAddButton()
        setupNameLabel()
        setupLocationLabel()
        setupStatsLabel()
    }
    
    private func setupBackground() {
        addSubview(background)
        background.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    private func setupProfileImageview() {
        addSubview(profileImageView)
        profileImageView.anchor(top: background.topAnchor, left: background.leftAnchor, bottom: background.bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 91, height: 0)
    }
    
    private func setupAddButton() {
        addSubview(addButton)
        addButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 33, height: 33)
        addButton.addTarget(self, action: #selector(addTutor), for: .touchUpInside)
    }
    
    private func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: background.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 25, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 20)
    }
    
    private func setupLocationLabel() {
        addSubview(locationLabel)
        locationLabel.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
    }
    
    private func setupStatsLabel() {
        addSubview(statsLabel)
        statsLabel.anchor(top: locationLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
    }
    
    func updateUI(_ uid: String) {
        self.userId = uid
        DataService.shared.getTutorWithId(uid) { (tutorIn) in
            guard let tutor = tutorIn else { return }
            self.profileImageView.imageView.sd_setImage(with: tutor.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
            self.nameLabel.text = tutor.formattedName.capitalized
            self.locationLabel.text = tutor.region
            guard let hours = tutor.hoursTaught, let sessions = tutor.totalSessions else {
                return
            }
            self.statsLabel.text = "\(hours) hours taught, \(sessions) complete sessions"
        }
    }
	
    @objc func addTutor() {
        guard let uid = userId else { return }
		//delegate?.addTutorWithUid(uid, completion: () -> Void)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
