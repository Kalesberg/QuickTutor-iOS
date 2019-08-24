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
    
    let contentView: FeaturedSubjectVCView = {
        let view = FeaturedSubjectVCView()
        return view
    }()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Featured Topic"
        progressView.isHidden = true
        subjects = CurrentUser.shared.tutor.subjects ?? [String]()
        contentView.subjectsCV.delegate = self
        contentView.subjectsCV.dataSource = self
        loadFeatuedSubject()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideTabBar(hidden: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideTabBar(hidden: false)
    }
    
    override func setupNavBar() {
        super.setupNavBar()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"newCheck"), style: .plain, target: self, action: #selector(saveChanges))
    }
    
    @objc func saveChanges() {
        guard let uid = Auth.auth().currentUser?.uid, let index = contentView.subjectsCV.indexPathsForSelectedItems?.first else { return }
        let subject = subjects[index.item]
        Database.database().reference().child("tutor-info").child(uid).child("sbj").setValue(subject)
        CurrentUser.shared.tutor.featuredSubject = subject
        navigationController?.popViewController(animated: true)
    }    
    
    func loadFeatuedSubject() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("tutor-info").child(uid).child("sbj").observeSingleEvent(of: .value) { (snapshot) in
            guard let subject = snapshot.value as? String else { return }
            self.insertFeaturedSubjectIfNeeded(subject)
            guard let item = self.subjects.firstIndex(where: { $0 == subject }) else { return }
            self.contentView.subjectsCV.selectItem(at: IndexPath(item: item, section: 0), animated: false, scrollPosition: .top)
        }
        
    }
    
    func insertFeaturedSubjectIfNeeded(_ subject: String) {
        if subjects.isEmpty {
            subjects.append(subject)
            contentView.subjectsCV.reloadData()
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
        label.text = "Your featured topic resides on the top section of your profile, next to your name. Make sure you choose the topic you are most experienced in. You can change your featured topic at any time"
        label.numberOfLines = 0
        return label
    }()
    
    var subjectsHeightAnchor: NSLayoutConstraint?
    
    override func updateTitleLabel() {
        titleLabel.text = "Set Featured Topic"
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
        infoLabel.anchor(top: subjectsCV.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 60)
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
        width = subjects[indexPath.item].estimateFrameForFontSize(14, extendedWidth: true).width + 20
        return CGSize(width: width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        TutorRegistrationService.shared.setFeaturedSubject(subjects[indexPath.item])
    }
}


