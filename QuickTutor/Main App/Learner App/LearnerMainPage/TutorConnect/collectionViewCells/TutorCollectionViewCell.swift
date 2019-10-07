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
import SkeletonView
import Cosmos
import Lottie

class TutorCollectionViewCell: UICollectionViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: TutorCollectionViewCell.self)
    }
    
    var tutor: AWTutor?
    
    let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.isSkeletonable = true
        view.clipsToBounds = true
        return view
    }()
    
    let maskBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.isSkeletonable = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 5
        iv.isHidden = true
        
        return iv
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.setImage(UIImage(named: "heartIcon"), for: .normal)
        button.setImage(UIImage(named:"heartIconFilled"), for: .selected)
        button.isHidden = true
        
        return button
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSemiBoldSize(14)
        label.textColor = UIColor.white
        label.isSkeletonable = true
        label.linesCornerRadius = 4
        
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createMediumSize(12)
        label.text = "$60/hr"
        label.isHidden = true
        
        return label
    }()
    
    let subjectLabel: UILabel = {
        let label = UILabel()
        label.text = "Math"
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.font = Fonts.createBoldSize(14)
        label.isSkeletonable = true
        label.linesCornerRadius = 4
        
        return label
    }()

    let ratingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 3
        
        return stackView
    }()
    
    let starView: CosmosView = {
        let view = CosmosView()
        view.isHidden = true
        
        view.settings.emptyImage = UIImage(named: "ic_star_empty")
        view.settings.filledImage = UIImage(named: "ic_star_filled")
        view.settings.totalStars = 5
        view.settings.starMargin = 3
        view.settings.fillMode = .precise
        view.settings.updateOnTouch = false
        view.settings.starSize = 10
        
        return view
    }()
    
    let starLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.purple
        label.text = "0"
        label.textAlignment = .left
        label.font = Fonts.createSemiBoldSize(12)
        label.isHidden = true
        
        return label
    }()
    
    var profileImageViewHeightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupContainerView()
        setupProfileImageView()
        setupMaskBackgroundView()
        
        setupSaveButton()
        setupNameLabel()
        setupSubjectLabel()
        setupPriceLabel()
        setupRatingStackView()
        setupStarView()
        setupStarLabel()
    }
    
    func setupContainerView() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().offset(-8)
        }
    }
    
    func setupProfileImageView() {
        containerView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(183)
        }
    }
    
    func setupMaskBackgroundView() {
        containerView.addSubview(maskBackgroundView)
        maskBackgroundView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(profileImageView.snp.bottom)
            make.height.equalTo(50)
        }
        
        let width = (UIScreen.main.bounds.width - 55) / 2
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: width, height: 50)
        gradientLayer.colors = [UIColor.clear,
                                UIColor.black.withAlphaComponent(0.8)].map({$0.cgColor})
        gradientLayer.locations = [0, 1]
        maskBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
        maskBackgroundView.layer.cornerRadius = 5
        maskBackgroundView.clipsToBounds = true
    }
    
    func setupSaveButton() {
        contentView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        saveButton.addTarget(self, action: #selector(handleSaveButton), for: .touchUpInside)
    }
    
    func setupNameLabel() {
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.bottom.equalTo(profileImageView.snp.bottom).offset(-10)
            make.right.equalToSuperview().offset(-8)
        }
    }
    
    func setupSubjectLabel() {
        containerView.addSubview(subjectLabel)
        subjectLabel.snp.makeConstraints { make in
            make.top.equalTo(maskBackgroundView.snp.bottom).offset(7)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    func setupPriceLabel() {
        containerView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(subjectLabel.snp.bottom).offset(4)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    func setupRatingStackView() {
        containerView.addSubview(ratingStackView)
        ratingStackView.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(9)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    func setupStarView() {
        ratingStackView.addArrangedSubview(starView)
        starView.snp.makeConstraints { make in
            make.width.equalTo(61)
        }
    }
    
    func setupStarLabel() {
        ratingStackView.addArrangedSubview(starLabel)
    }
    
    func updateUI(_ tutor: AWTutor) {
        self.tutor = tutor
        nameLabel.text = tutor.formattedName
        subjectLabel.text = tutor.featuredSubject
        
        priceLabel.isHidden = false
        priceLabel.text = "$\(tutor.price ?? 5) per hour"
        
        profileImageView.isHidden = false
        profileImageView.sd_setImage(with: URL(string: tutor.profilePicUrl.absoluteString)!,
                                     placeholderImage: UIImage(named: "ic_avatar_placeholder"))
        
        saveButton.isHidden = false
        if !CurrentUser.shared.learner.savedTutorIds.isEmpty {
            let savedTutorIds = CurrentUser.shared.learner.savedTutorIds
            saveButton.isSelected = savedTutorIds.contains(tutor.uid)
        }
        
        starLabel.isHidden = false
        if let rating = tutor.tRating, rating > 0 {
            starView.isHidden = false
            starView.rating = rating
            
            guard let reviewCount = tutor.reviews?.count else {
                if let address = tutor.region {
                    starLabel.text = address
                }
                return
            }
            starLabel.text = "\(reviewCount)"
        } else {
            starView.isHidden = true
            starView.rating = 0
            
            if let experienceSubject = tutor.experienceSubject, let experiencePeriod = tutor.experiencePeriod, !experienceSubject.isEmpty {
                if experiencePeriod == 0.5 {
                    starLabel.text = "6 Months Experience in \(experienceSubject)"
                } else {
                    starLabel.text = "\(Int(experiencePeriod)) Years Experience in \(experienceSubject)"
                }
            } else if let address = tutor.region {
                starLabel.text = address
            }
        }
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
        saveButton.isSelected = true
        CurrentUser.shared.learner.savedTutorIds.append(tutorId)
        NotificationCenter.default.post(name: NotificationNames.SavedTutors.didUpdate, object: nil)
    }
    
    func unsaveTutor() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = tutor?.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).removeValue()
        saveButton.isSelected = false
        CurrentUser.shared.learner.savedTutorIds.removeAll(where: { (id) -> Bool in
            return id == tutorId
        })
        NotificationCenter.default.post(name: NotificationNames.SavedTutors.didUpdate, object: nil)
    }
    
    func updateSaveButton() {
        guard let tutorId = tutor?.uid else { return }
        let savedTutorIds = CurrentUser.shared.learner.savedTutorIds
        saveButton.isSelected = savedTutorIds.contains(tutorId)
    }
    
    private func addShadow() {
        containerView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: .zero, radius: 5)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isSkeletonable = true
        
        setupViews()
//        addShadow()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        updateSaveButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class QTWideTutorCollectionViewCell: TutorCollectionViewCell {
    
    var cellWidth: CGFloat = 0
    
    override func setupMaskBackgroundView() {
        containerView.addSubview(maskBackgroundView)
        maskBackgroundView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(profileImageView.snp.bottom)
            make.height.equalTo(50)
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: cellWidth, height: 50)
        gradientLayer.colors = [UIColor.clear,
                                UIColor.black.withAlphaComponent(0.8)].map({$0.cgColor})
        gradientLayer.locations = [0, 1]
        maskBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
        maskBackgroundView.layer.cornerRadius = 5
        maskBackgroundView.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        cellWidth = (UIScreen.main.bounds.size.width - 55) / 2
        super.init(frame: frame)
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TutorLoadMoreCollectionViewCell: UICollectionViewCell {
    let loadingView: LOTAnimationView = {
        let lottieView = LOTAnimationView(name: "loading11")
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopAnimation = true
        return lottieView
    }()
    
    static var reuseIdentifier: String {
        return String(describing: TutorLoadMoreCollectionViewCell.self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isSkeletonable = true
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalToSuperview()
        }
        
        contentView.backgroundColor = Colors.newScreenBackground
        loadingView.play()
    }
}

class SavedTutorService {
    
    let tutorId: String
    let saveButton: UIButton
    
    func saveTutor() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).setValue(1)
        saveButton.isSelected = true
        CurrentUser.shared.learner.savedTutorIds.append(tutorId)
        NotificationCenter.default.post(name: NotificationNames.SavedTutors.didUpdate, object: nil)
    }
    
    func unsaveTutor() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).removeValue()
        saveButton.isSelected = false
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
