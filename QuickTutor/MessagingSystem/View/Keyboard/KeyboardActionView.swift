//
//  KeyboardActionView.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/24/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class KeyboardActionView: UIView {
    var delegate: KeyboardAccessoryViewDelegate?
    var chatPartnerId: String?

    let actionCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(KeyboardActionViewCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()

    func setupViews() {
        setupMainView()
        setupActionCollection()
    }

    func setupMainView() {
        layer.cornerRadius = 12
        if #available(iOS 11.0, *) {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        backgroundColor = Colors.newScreenBackground
        clipsToBounds = true
    }
    
    private func setupActionCollection() {
        actionCV.delegate = self
        actionCV.dataSource = self
        addSubview(actionCV)
        actionCV.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

let actionTuples = [("Send Media", #imageLiteral(resourceName: "picUploadIcon")), ("Schedule Session", #imageLiteral(resourceName: "requestSessionButton")), ("Share Username", #imageLiteral(resourceName: "shareUsernameIcon"))]

extension KeyboardActionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! KeyboardActionViewCell
        let title = actionTuples[indexPath.item].0
        let image = actionTuples[indexPath.item].1
        cell.updateUI(title: title, image: image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 3, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            delegate?.handleSendingImage()
        } else if indexPath.item == 1 {
            delegate?.handleSessionRequest()
        } else {
            delegate?.shareUsernameForUserId()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? KeyboardActionViewCell else { return }
        UIView.animate(withDuration: 0.2) {
            cell.icon.alpha = 0.6
            cell.titleLabel.alpha = 0.6
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? KeyboardActionViewCell else { return }
        UIView.animate(withDuration: 0.2) {
            cell.icon.alpha = 1.0
            cell.titleLabel.alpha = 1.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
