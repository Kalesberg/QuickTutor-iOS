//
//  TutorCardInfoView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol TutorCardInfoViewDelegate {
    func infoView(_ infoView: TutorCardInfoView, didUpdate height: CGFloat)
}

class TutorCardInfoView: UIView {
    
    var dataSource: TutorDataSource?
    var delegate: TutorCardInfoViewDelegate?
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = Fonts.createSize(16)
        label.numberOfLines = 0
        return label
    }()
    
    let subjectsCV: SubjectsCollectionView = {
        let cv = SubjectsCollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        return cv
    }()
    
    let seeAllView: MockCollectionViewCell = {
        let cell = MockCollectionViewCell()
        cell.primaryButton.setTitle("See all", for: .normal)
        cell.titleLabel.text = "Tutored in 11 sessions."
        cell.titleLabel.font = Fonts.createSize(14)
        return cell
    }()
    
    var subjectCVHeightAnchor: NSLayoutConstraint?
    var bioHeightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupBioLabel()
        setupSubjectsCV()
        setupSeeAllView()
    }
    
    func setupBioLabel() {
        addSubview(bioLabel)
        bioLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        bioHeightAnchor = bioLabel.heightAnchor.constraint(equalToConstant: 105)
        bioHeightAnchor?.isActive = true
    }
    
    func setupSubjectsCV() {
        addSubview(subjectsCV)
        subjectsCV.anchor(top: bioLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        subjectCVHeightAnchor = subjectsCV.heightAnchor.constraint(equalToConstant: 100)
        subjectCVHeightAnchor?.isActive = true
        subjectsCV.delegate = self
        subjectsCV.dataSource = self
    }
    
    func setupSeeAllView() {
        addSubview(seeAllView)
        seeAllView.anchor(top: subjectsCV.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    func updateUI() {
        let height = subjectsCV.collectionViewLayout.collectionViewContentSize.height
        subjectCVHeightAnchor?.constant = height
        layoutIfNeeded()
        updateHeight()
    }
    
    func updateUI(_ tutor: AWTutor) {
        bioLabel.text = tutor.tBio
        bioHeightAnchor?.constant = bioLabel.heightForLabel(text: tutor.tBio, font: Fonts.createSize(16), width: UIScreen.main.bounds.width - 40)
        if let numSessions = tutor.tNumSessions {
            seeAllView.titleLabel.text = "Tutored in \(numSessions) sessions."
        }
        layoutIfNeeded()
        updateHeight()
    }
    
    func updateHeight() {
        var height: CGFloat = 90
        if let bioHeight = bioHeightAnchor?.constant {
            height += bioHeight
        }
        if let subjectHeight = subjectCVHeightAnchor?.constant {
            height += subjectHeight
        }
        delegate?.infoView(self, didUpdate: height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TutorCardInfoView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            width = subjects[indexPath.item].estimateFrameForFontSize(14).width + 20
        }
        return CGSize(width: width, height: 30)
    }
    
}

