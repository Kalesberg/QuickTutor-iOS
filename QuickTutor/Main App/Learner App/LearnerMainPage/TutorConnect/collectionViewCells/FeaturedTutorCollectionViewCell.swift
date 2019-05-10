//
//  FeaturedCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit
import Firebase

class TutorCollectionViewCell: UICollectionViewCell {
    
    var tutor: AWTutor?
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 4
        if #available(iOS 11.0, *) {
            iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.setImage(UIImage(named: "saveButton"), for: .normal)
        return button
    }()
    
    let infoContainerView: UIView = {
        let view = UIView()
        view.layer.borderColor = Colors.gray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        view.backgroundColor = Colors.darkBackground
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(10)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(10)
        label.textAlignment = .right
        label.text = "$60/hr"
        return label
    }()
    
    let subjectLabel: UILabel = {
        let label = UILabel()
        label.text = "Math"
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.font = Fonts.createBlackSize(12)
        return label
    }()
    
    let starView: StarView = {
        let view = StarView()
        return view
    }()
    
    let starLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.purple
        label.text = "0"
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(12)
        return label
    }()
    
    var profileImageViewHeightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupProfileImageView()
        setupSaveButton()
        setupInfoContainerView()
        setupNameLabel()
        setupPriceLabel()
        setupSubjectLabel()
        setupStarView()
        setupStarLabel()
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        profileImageViewHeightAnchor = profileImageView.heightAnchor.constraint(equalToConstant: 115)
        profileImageViewHeightAnchor?.isActive = true
    }
    
    func setupSaveButton() {
        addSubview(saveButton)
        saveButton.anchor(top: profileImageView.topAnchor, left: nil, bottom: nil, right: profileImageView.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 30, height: 30)
        saveButton.addTarget(self, action: #selector(handleSaveButton), for: .touchUpInside)
    }
    
    func setupInfoContainerView() {
        insertSubview(infoContainerView, belowSubview: profileImageView)
        infoContainerView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: -1, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: infoContainerView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 13)
    }
    
    func setupPriceLabel() {
        addSubview(priceLabel)
        priceLabel.anchor(top: infoContainerView.topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 40, height: 13)
    }
    
    func setupSubjectLabel() {
        addSubview(subjectLabel)
        subjectLabel.anchor(top: nameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 15)
    }
    
    func setupStarView() {
        addSubview(starView)
        starView.anchor(top: subjectLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 6, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 50, height: 10)
        starView.tintStars(color: Colors.purple)
    }
    
    func setupStarLabel() {
        addSubview(starLabel)
        starLabel.anchor(top: nil, left: starView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 10, paddingRight: 0, width: 30, height: 20)
        addConstraint(NSLayoutConstraint(item: starLabel, attribute: .centerY, relatedBy: .equal, toItem: starView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func updateUI(_ tutor: AWTutor) {
        self.tutor = tutor
        nameLabel.text = tutor.formattedName
        subjectLabel.text = tutor.featuredSubject
        priceLabel.text = "$\(tutor.price!)/hr"
        profileImageView.sd_setImage(with: URL(string: tutor.profilePicUrl.absoluteString)!, completed: nil)
        if !CurrentUser.shared.learner.savedTutorIds.isEmpty {
            let savedTutorIds = CurrentUser.shared.learner.savedTutorIds
            savedTutorIds.contains(tutor.uid) ? saveButton.setImage(UIImage(named:"saveButtonFilled"), for: .normal) : saveButton.setImage(UIImage(named:"saveButton"), for: .normal)
        }
        guard let reviewCount = tutor.reviews?.count else { return }
        starLabel.text = "\(reviewCount)"
    }
    
    @objc func handleSaveButton() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = tutor?.uid, uid != tutorId else { return }
        if !CurrentUser.shared.learner.savedTutorIds.isEmpty {
            let savedTutorIds = CurrentUser.shared.learner.savedTutorIds
            savedTutorIds.contains(tutorId) ? unsaveTutor() : saveTutor()
        } else {
            saveTutor()
        }
    }
    
    func saveTutor() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = tutor?.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).setValue(1)
        saveButton.setImage(UIImage(named: "saveButtonFilled"), for: .normal)
        CurrentUser.shared.learner.savedTutorIds.append(tutorId)
        NotificationCenter.default.post(name: NotificationNames.SavedTutors.didUpdate, object: nil)
    }
    
    func unsaveTutor() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = tutor?.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).removeValue()
        saveButton.setImage(UIImage(named: "saveButton"), for: .normal)
        CurrentUser.shared.learner.savedTutorIds.removeAll(where: { (id) -> Bool in
            return id == tutorId
        })
        NotificationCenter.default.post(name: NotificationNames.SavedTutors.didUpdate, object: nil)
    }
    
    func updateSaveButton() {
        guard let tutorId = tutor?.uid else { return }
        let savedTutorIds = CurrentUser.shared.learner.savedTutorIds
        savedTutorIds.contains(tutorId) ? saveButton.setImage(UIImage(named:"saveButtonFilled"), for: .normal) : saveButton.setImage(UIImage(named:"saveButton"), for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        updateSaveButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SavedTutorService {
    
    let tutorId: String
    let saveButton: UIButton
    
    func saveTutor() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).setValue(1)
        saveButton.setImage(UIImage(named: "saveButtonFilled"), for: .normal)
        CurrentUser.shared.learner.savedTutorIds.append(tutorId)
        NotificationCenter.default.post(name: NotificationNames.SavedTutors.didUpdate, object: nil)
    }
    
    func unsaveTutor() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).removeValue()
        saveButton.setImage(UIImage(named: "saveButton"), for: .normal)
        CurrentUser.shared.learner.savedTutorIds.removeAll(where: { (id) -> Bool in
            return id == tutorId
        })
        NotificationCenter.default.post(name: NotificationNames.SavedTutors.didUpdate, object: nil)
    }
    
    func loadSavedTutors(completion: @escaping([AWTutor]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let myGroup = DispatchGroup()
        var tutors = [AWTutor]()
        Database.database().reference().child("saved-tutors").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let tutorIds = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
            tutorIds.forEach({ uid, _ in
                myGroup.enter()
                FirebaseData.manager.fetchTutor(uid, isQuery: false, { tutor in
                    guard let tutor = tutor else {
                        myGroup.leave()
                        return
                    }
                    if tutor.uid != Auth.auth().currentUser?.uid {
                        tutors.append(tutor)
                    }
                    myGroup.leave()
                })
            })
            myGroup.notify(queue: .main) {
                completion(tutors)
            }
        }
    }

    init(tutorId: String, saveButton: UIButton) {
        self.tutorId = tutorId
        self.saveButton = saveButton
    }
}
