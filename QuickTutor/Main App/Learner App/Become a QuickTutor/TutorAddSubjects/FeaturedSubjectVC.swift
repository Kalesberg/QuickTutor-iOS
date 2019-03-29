//
//  FeaturedSubjectVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 2/18/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class FeaturedSubjectVC: BaseRegistrationController {
    
    var subjects = [String]()
    var featuredSubject: String?
    
    let contentView: FeaturedSubjectVCView = {
        let view = FeaturedSubjectVCView()
        return view
    }()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Featured Subject"
        progressView.isHidden = true
        subjects = CurrentUser.shared.tutor.subjects ?? [String]()
        contentView.subjectsCV.delegate = self
        contentView.subjectsCV.dataSource = self
        loadFeatuedSubject()
    }
    
    override func setupNavBar() {
        super.setupNavBar()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"newCheck"), style: .plain, target: self, action: #selector(saveChanges))
    }
    
    @objc func saveChanges() {
        if let featuredSubject = featuredSubject {
            CurrentUser.shared.tutor.featuredSubject = featuredSubject
        }
        navigationController?.popViewController(animated: true)
    }
    
    func loadFeatuedSubject() {
        if let subject = CurrentUser.shared.tutor.featuredSubject {
            guard let item = subjects.firstIndex(where: { $0 == subject }) else { return }
            contentView.subjectsCV.selectItem(at: IndexPath(item: item, section: 0), animated: false, scrollPosition: .top)
        }
    }
    
}

class FeaturedSubjectVCView: BaseRegistrationView {
    
    var subjects = [String]()
    
    let subjectsCV: SubjectsCollectionView = {
        let cv = SubjectsCollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        cv.isUserInteractionEnabled = true
        return cv
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createSize(12)
        label.text = "Your featured subject will be at the top of your profile. Be sure to select your favorite or most experienced subject. You can change your featured subject at any time"
        label.numberOfLines = 0
        return label
    }()
    
    var subjectsHeightAnchor: NSLayoutConstraint?
    
    override func updateTitleLabel() {
        titleLabel.text = "Set Featured Subject"
    }
    
    override func setupViews() {
        super.setupViews()
        setupSubjectsCV()
        setupInfoLabel()
    }
    
    func setupSubjectsCV() {
        addSubview(subjectsCV)
        subjectsCV.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        subjectsHeightAnchor = subjectsCV.heightAnchor.constraint(equalToConstant: 300)
        subjectsHeightAnchor?.isActive = true
    }
    
    func setupInfoLabel() {
        addSubview(infoLabel)
        infoLabel.anchor(top: subjectsCV.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
    }
    
    func updateHeight() {
        let height = subjectsCV.collectionViewLayout.collectionViewContentSize.height
        subjectsHeightAnchor?.constant = height
        layoutIfNeeded()
    }
}

extension FeaturedSubjectVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! PillCollectionViewCell
        cell.titleLabel.text = subjects[indexPath.item]
        contentView.updateHeight()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 60
        width = subjects[indexPath.item].estimateFrameForFontSize(14).width + 20
        return CGSize(width: width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        TutorRegistrationService.shared.setFeaturedSubject(subjects[indexPath.item])
        featuredSubject = subjects[indexPath.item]
    }
}


