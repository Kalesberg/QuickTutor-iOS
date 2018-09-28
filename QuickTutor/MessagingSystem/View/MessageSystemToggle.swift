//
//  MessageSystemToggle.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

enum UserType: String {
    case learner
    case tutor
    case tRegistration
    case lRegistration
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
        cv.backgroundColor = Colors.currentUserColor()
        cv.delegate = self
        cv.dataSource = self
        cv.register(MessagingSystemToggleCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()

    let bar: UIView = {
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = .white
        return bar
    }()

    var leftAnchorConstraint: NSLayoutConstraint?

    func setupViews() {
        setupCollectionView()
        setupHorizontalBar()
        setupForUserType()
    }

    private func setupCollectionView() {
        addSubview(cv)
        cv.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        selectFirstSection()
    }

    func setupHorizontalBar() {
        addSubview(bar)
        leftAnchorConstraint = bar.leftAnchor.constraint(equalTo: leftAnchor)
        leftAnchorConstraint?.isActive = true
        bar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
        bar.heightAnchor.constraint(equalToConstant: 3).isActive = true
    }
    
    func selectFirstSection() {
        let selectedIndexPath = IndexPath(row: 0, section: 0)
        cv.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .bottom)
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
        animateBarToItem(indexPath.item)
        delegate?.scrollTo(index: indexPath.item, animated: true)
    }
    
    func animateBarToItem(_ item: Int) {
        leftAnchorConstraint?.constant = item == 0 ? 0 : frame.size.width / 2
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
}
