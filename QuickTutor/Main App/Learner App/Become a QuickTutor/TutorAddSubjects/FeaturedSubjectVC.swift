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
    
    override func updateTitleLabel() {
        titleLabel.text = "Set Featured Subject"
    }
    
    override func setupViews() {
        super.setupViews()
        setupSubjectsCV()
    }
    
    func setupSubjectsCV() {
        addSubview(subjectsCV)
        subjectsCV.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 300)
    }
}

extension FeaturedSubjectVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! PillCollectionViewCell
        cell.titleLabel.text = subjects[indexPath.item]
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
    }
}


