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
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 4
        iv.backgroundColor = Colors.gray
        iv.clipsToBounds = true
        return iv
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
        label.textColor = Colors.learnerPurple
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
        if let image = UIImage(named:"ic_details")?.maskWithColor(color: UIColor.white) {
            button.setImage(image, for: .normal)
        }
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
            self.profileImageView.sd_setImage(with: tutor2.profilePicUrl)
        }
        
        // Changed hart icon into message icon, so don't need the following code snippets
        /*
        if let savedTutorIds = CurrentUser.shared.learner.savedTutorIds {
            savedTutorIds.contains(tutor.uid) ? messageButton.setImage(UIImage(named:"heartIconFilled"), for: .normal) : messageButton.setImage(UIImage(named:"heartIcon"), for: .normal)
        }
         */
    }
    
    @objc func handleMessageButton() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = tutor?.uid, uid != tutorId else { return }
        if let savedTutorIds = CurrentUser.shared.learner.savedTutorIds {
            savedTutorIds.contains(tutorId) ? unsaveTutor() : saveTutor()
        } else {
            saveTutor()
        }
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
