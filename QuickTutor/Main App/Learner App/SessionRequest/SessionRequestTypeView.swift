//
//  SessionRequestTypeView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol SessionRequestTypeViewDelegate: class {
    func sessionRequestTypeView( _ typeView: SessionRequestTypeView, didSelect type: String)
}

class SessionRequestTypeView: BaseSessionRequestViewSection {
    
    weak var delegate: SessionRequestTypeViewDelegate?
    
    let sessionTypes = ["In-person", "Online"]
    
    let collectionView: SubjectsCollectionView = {
        let cv = SubjectsCollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        cv.isUserInteractionEnabled = true
        return cv
    }()
    
    override func setupViews() {
        super.setupViews()
        setupCollectionView()
        titleLabel.text = "Type"
        separator.removeFromSuperview()
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension SessionRequestTypeView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! PillCollectionViewCell
        cell.titleLabel.text = sessionTypes[indexPath.item]
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
        width = sessionTypes[indexPath.item].estimateFrameForFontSize(14).width + 20
        return CGSize(width: width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.sessionRequestTypeView(self, didSelect: sessionTypes[indexPath.item].lowercased())
    }
}

