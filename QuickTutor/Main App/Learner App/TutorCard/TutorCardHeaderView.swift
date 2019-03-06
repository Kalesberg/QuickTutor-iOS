//
//  TutorCardHeaderView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class TutorCardHeaderView: UIView {
    
    var tutor: AWTutor?
    var subject: String?
    weak var delegate: TutorCardHeaderViewDelegate?
    
    let profileImageView: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 4
        button.backgroundColor = Colors.gray
        button.clipsToBounds = true
        return button
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBlackSize(24)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let subjectLabel: UILabel = {
        let label = UILabel()
        label.text = "Politics"
        label.textColor = Colors.purple
        label.textAlignment = .left
        label.font = Fonts.createSize(14)
        return label
    }()
    
    let messageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"chatTabBarIcon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    let detailButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"moreIcon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    func setupViews() {
        setupProfileImageView()
        setupNameLabel()
        setupSubjectLabel()
        setupDetailButton()
        setupMessageButton()
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.addTarget(self, action: #selector(handleImageViewTap), for: .touchUpInside)
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 135, height: 29)
    }
    
    func setupSubjectLabel() {
        addSubview(subjectLabel)
        subjectLabel.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 135, height: 17)
        let bottomConstraint = NSLayoutConstraint(item: subjectLabel, attribute: .bottom, relatedBy: .equal, toItem: profileImageView, attribute: .bottom, multiplier: 1, constant: 15)
        bottomConstraint.priority = UILayoutPriority(rawValue: 999)
        bottomConstraint.isActive = true
    }
    
    func setupDetailButton() {
        addSubview(detailButton)
        detailButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        addConstraint(NSLayoutConstraint(item: detailButton, attribute: .centerY, relatedBy: .equal, toItem: nameLabel, attribute: .centerY, multiplier: 1, constant: 0))
        detailButton.addTarget(self, action: #selector(handleDetailButton), for: .touchUpInside)
    }
    
    func setupMessageButton() {
        addSubview(messageButton)
        messageButton.anchor(top: nil, left: nil, bottom: nil, right: detailButton.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 20, height: 20)
        addConstraint(NSLayoutConstraint(item: messageButton, attribute: .centerY, relatedBy: .equal, toItem: nameLabel, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func updateUI(_ tutor: AWTutor) {
        self.tutor = tutor
        nameLabel.text = tutor.name
        if let subject = subject {
            subjectLabel.text = subject
        }
        DataService.shared.getTutorWithId(tutor.uid) { (tutor2) in
            guard let tutor2 = tutor2 else { return }
            self.profileImageView.sd_setImage(with: tutor2.profilePicUrl, for: .normal, completed: nil)
        }
        
        getConnectionStatus { (connected) in
            self.messageButton.isHidden = !connected
        }
        
        // Changed hart icon into message icon, so don't need the following code snippets
        /*
        if let savedTutorIds = CurrentUser.shared.learner.savedTutorIds {
            savedTutorIds.contains(tutor.uid) ? messageButton.setImage(UIImage(named:"heartIconFilled"), for: .normal) : messageButton.setImage(UIImage(named:"heartIcon"), for: .normal)
        }
         */
    }
    
    @objc func handleImageViewTap() {
        delegate?.tutorCardHeaderViewDidTapProfilePicture(self)
    }
    
    @objc func handleMessageButton() {
        delegate?.tutorCardHeaderViewDidTapMessageIcon()
    }
    
    @objc func handleDetailButton() {
        
    }
    
    func saveTutor() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = tutor?.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).setValue(1)
        messageButton.setImage(UIImage(named: "heartIconFilled"), for: .normal)
        CurrentUser.shared.learner.savedTutorIds?.append(tutorId)
    }
    
    func unsaveTutor() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = tutor?.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).removeValue()
        messageButton.setImage(UIImage(named: "heartIcon"), for: .normal)
        CurrentUser.shared.learner.savedTutorIds?.removeAll(where: { (id) -> Bool in
            return id == tutorId
        })
    }
    
    func getConnectionStatus(completionHandler: ((Bool) -> ())?) {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = tutor?.uid else { return }
        let userTypeString = AccountService.shared.currentUserType.rawValue
    
        Database.database().reference()
            .child("connections")
            .child(uid)
            .child(userTypeString)
            .child(tutorId).observeSingleEvent(of: .value) { (snapshot) in
                if let completionHandler = completionHandler {
                    completionHandler(snapshot.exists())
                }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
