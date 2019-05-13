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
    
    let shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
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
        view.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.backgroundColor = Colors.newBackground
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
        setupShadowView()
        setupInfoContainerView()
        setupProfileImageView()
//        setupSaveButton()
        setupNameLabel()
        setupPriceLabel()
        setupSubjectLabel()
        setupStarView()
        setupStarLabel()
    }
    
    func setupShadowView() {
        addSubview(shadowView)
        shadowView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-4)
            make.height.equalToSuperview().offset(-8)
        }
    }
    
    func setupInfoContainerView() {
        shadowView.addSubview(infoContainerView)
        infoContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupProfileImageView() {
        infoContainerView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(150)
        }
    }
    
    func setupSaveButton() {
        addSubview(saveButton)
        saveButton.anchor(top: profileImageView.topAnchor, left: nil, bottom: nil, right: profileImageView.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 30, height: 30)
        saveButton.addTarget(self, action: #selector(handleSaveButton), for: .touchUpInside)
    }
    
    func setupNameLabel() {
        infoContainerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(13)
        }
    }
    
    func setupPriceLabel() {
        infoContainerView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(nameLabel.snp.height)
        }
    }
    
    func setupSubjectLabel() {
        infoContainerView.addSubview(subjectLabel)
        subjectLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(nameLabel.snp.left)
            make.centerX.equalToSuperview()
            make.height.equalTo(15)
        }
    }
    
    func setupStarView() {
        infoContainerView.addSubview(starView)
        starView.snp.makeConstraints { make in
            make.top.equalTo(subjectLabel.snp.bottom).offset(6)
            make.left.equalTo(subjectLabel.snp.left)
            make.width.equalTo(50)
            make.height.equalTo(10)
        }
    }
    
    func setupStarLabel() {
        infoContainerView.addSubview(starLabel)
        starLabel.snp.makeConstraints { make in
            make.left.equalTo(starView.snp.right).offset(5)
            make.centerY.equalTo(starView.snp.centerY)
            make.width.equalTo(30)
            make.height.equalTo(20)
        }
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
    
    private func addShadow() {
        shadowView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: .zero, radius: 4)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        addShadow()
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
