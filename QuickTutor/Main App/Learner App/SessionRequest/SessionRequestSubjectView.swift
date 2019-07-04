//
//  SessionRequestSubjectView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol SessionRequestSubjectsViewDeleagte {
    func sessionRequestSubjectView(_ subjectView: SessionRequestSubjectView, didUpdate height: CGFloat)
    func sessionRequestSubjectView(_ subjectView: SessionRequestSubjectView, didSelect subject: String)
}

class SessionRequestSubjectView: BaseSessionRequestViewSection {
    
    var dataSource: TutorDataSource?
    var delegate: SessionRequestSubjectsViewDeleagte?
    
    let collectionView: SubjectsCollectionView = {
        let cv = SubjectsCollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        cv.isUserInteractionEnabled = true
        return cv
    }()
    
    var collectionViewHeightAnchor: NSLayoutConstraint?
    
    override func setupViews() {
        super.setupViews()
        setupCollectionView()
        titleLabel.text = "What subject would you like to learn?"
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionViewHeightAnchor = collectionView.heightAnchor.constraint(equalToConstant: 100)
        collectionViewHeightAnchor?.isActive = true
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func updateUI() {
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        collectionViewHeightAnchor?.constant = height
        layoutIfNeeded()
        updateHeight()
    }
    
    
    private func updateHeight() {
        var height: CGFloat = 60
        if let subjectHeight = collectionViewHeightAnchor?.constant {
            height += subjectHeight
        }
        delegate?.sessionRequestSubjectView(self, didUpdate: height)
    }
}

extension SessionRequestSubjectView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.tutor?.subjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! PillCollectionViewCell
        if let subjects = dataSource?.tutor?.subjects {
            cell.titleLabel.text = subjects[indexPath.item]
        }
        updateUI()
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
        if let subjects = dataSource?.tutor?.subjects {
            width = subjects[indexPath.item].estimateFrameForFontSize(14, extendedWidth: true).width + 20
        }
        return CGSize(width: width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let subject = dataSource?.tutor?.subjects?[indexPath.item] else { return }
        delegate?.sessionRequestSubjectView(self, didSelect: subject)
    }
    
}
