//
//  MessageSystemToggle.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

enum UserType: String {
    case learner = "learner"
    case tutor = "tutor"
	case tRegistration = "tRegistration"
	case lRegistration = "lRegistration"
}

protocol MessagingSystemToggleDelegate {
    func scrollTo(index: Int, animated: Bool)
}

class MessagingSystemToggle: UIView {
    
    var sections = ["Messages", "Sessions"]
    var delegate: MessagingSystemToggleDelegate?
    
    lazy var cv: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.layer.borderColor = UIColor.white.cgColor
        cv.layer.borderWidth = 0.5
        cv.layer.cornerRadius = 6
        cv.delegate = self
        cv.dataSource = self
        cv.register(MessagingSystemToggleCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    func setupViews() {
        setupCollectionView()
        setupSeparator()
        setupForUserType()
    }
    
    private func setupCollectionView() {
        addSubview(cv)
        cv.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        selectFirstSection()
    }
    
    private func setupSeparator() {
        addSubview(separator)
        separator.anchor(top: cv.topAnchor, left: nil, bottom: cv.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0.5, height: 0)
        addConstraint(NSLayoutConstraint(item: separator, attribute: .centerX, relatedBy: .equal, toItem: cv, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func selectFirstSection() {
        let selectedIndexPath = NSIndexPath(row: 0, section: 0)
        cv.selectItem(at: selectedIndexPath as IndexPath, animated: false, scrollPosition: [])
    }
    
    func setupForUserType() {
        sections[0] = AccountService.shared.currentUserType == .learner ? "Messages" : "Messages"
        cv.reloadData()
        selectFirstSection()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MessagingSystemToggle: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! MessagingSystemToggleCell
        cell.label.text = sections[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 2, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.scrollTo(index: indexPath.item, animated: true)
    }
}
