//
//  QTLearnerAddInterestsView.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTLearnerAddInterestsView: QuickSearchVCView {

    let accessoryViewHeight: CGFloat = 80
    
    let selectedInterestsCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.newScreenBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceHorizontal = true
        cv.delaysContentTouches = false
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        cv.register(QuickSearchSubcategoryCell.self, forCellWithReuseIdentifier: "cellId")
        cv.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.2, offset: CGSize(width: 0, height: 3), radius: 4)
        return cv
    }()
    
    let accessoryView: RegistrationAccessoryView = {
        let view = RegistrationAccessoryView()
        return view
    }()
    
    var hideAccessoryView = false {
        didSet {
            self.accessoryView.isHidden = hideAccessoryView
            let margin: CGFloat = 10
            let bottomPadding: CGFloat = hideAccessoryView ? 0 : accessoryViewHeight + margin
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomPadding, right: 0)
        }
    }
    
    let accessoryTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Add up to 12 interests."
        label.textAlignment = .left
        label.textColor = .white
        label.font = Fonts.createBoldSize(14)
        label.numberOfLines = 0
        return label
    }()
    
    var selectedInterestsHeightAnchor: NSLayoutConstraint?
    var collectionViewTopAnchor: NSLayoutConstraint?
    
    override func setupViews() {
        super.setupViews()
        setupSelectedInterestsCV()
        setupAccessoryView()
        setupAccessoryTextLabel()
        let backIcon = UIImageView(image: UIImage(named:"newBackButton"))
        searchBarContainer.searchBar.leftView = backIcon
        searchBarContainer.cancelEditingButton.setTitle("Done", for: .normal)
        setupObservers()
        searchBarContainer.mockLeftViewButton.isHidden = false
        searchBarContainer.filtersButton.isHidden = true
        if LearnerRegistrationService.shared.interests.count > 0 {
            showSelectedInterestsCVIfNeeded(animated: false)
            selectedInterestsCV.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
        updateAccessoryViewTextLabel()
    }
    
    func setupSelectedInterestsCV() {
        insertSubview(selectedInterestsCV, at: 2)
        selectedInterestsCV.anchor(top: searchBarContainer.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        selectedInterestsHeightAnchor = selectedInterestsCV.heightAnchor.constraint(equalToConstant: 0)
        selectedInterestsHeightAnchor?.isActive = true
        selectedInterestsCV.delegate = self
        selectedInterestsCV.dataSource = self
    }
    
    func setupAccessoryView() {
        addSubview(accessoryView)
        accessoryView.anchor(top: nil, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: accessoryViewHeight)
    }
    
    func setupAccessoryTextLabel() {
        accessoryView.addSubview(accessoryTextLabel)
        accessoryTextLabel.anchor(top: accessoryView.topAnchor, left: accessoryView.leftAnchor, bottom: accessoryView.bottomAnchor, right: accessoryView.nextButton.leftAnchor, paddingTop: 5, paddingLeft: 20, paddingBottom: 5, paddingRight: 5, width: 0, height: 0)
    }
    
    override func setupCollectionView() {
        insertSubview(collectionView, at: 0)
        collectionView.anchor(top: nil, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionViewTopAnchor = collectionView.topAnchor.constraint(equalTo: searchBarContainer.bottomAnchor, constant: 0)
        collectionViewTopAnchor?.isActive = true
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLearnerDidAddInterest(_:)), name: Notifications.learnerDidAddInterest.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLearnerDidRemoveInterest(_:)), name: Notifications.learnerDidRemoveInterest.name, object: nil)
    }
    
    
    @objc func handleLearnerDidAddInterest(_ notification: Notification) {
        showSelectedInterestsCVIfNeeded(animated: true)
        updateAccessoryViewTextLabel()
        selectedInterestsCV.reloadData()
        let indexPath = IndexPath(item: selectedInterestsCV.numberOfItems(inSection: 0) - 1, section: 0)
        selectedInterestsCV.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
    @objc func handleLearnerDidRemoveInterest(_ notification: Notification) {
        updateAccessoryViewTextLabel()
        selectedInterestsCV.reloadData()
        
        if LearnerRegistrationService.shared.interests.isEmpty {
            selectedInterestsHeightAnchor?.constant = 0
            collectionViewTopAnchor?.constant = 0
            layoutIfNeeded()
        }
    }
    
    func showSelectedInterestsCVIfNeeded(animated: Bool) {
        guard selectedInterestsHeightAnchor?.constant != 50 else { return }
        selectedInterestsHeightAnchor?.constant = 50
        collectionViewTopAnchor?.constant = 50
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }
    
    func updateAccessoryViewTextLabel() {
        let remainingInterestsCount = QTConstants.learnerMaxInterests - LearnerRegistrationService.shared.interests.count
        accessoryTextLabel.text = "Add up to \(remainingInterestsCount) more intersts."
        
        if 0 < LearnerRegistrationService.shared.interests.count {
            accessoryView.nextButton.isUserInteractionEnabled = true
            accessoryView.nextButton.backgroundColor = Colors.purple
        } else {
            accessoryView.nextButton.isUserInteractionEnabled = false
            accessoryView.nextButton.backgroundColor = Colors.gray
        }
    }
    
    func showRemovePromptFor(interest: String) {
        let ac = UIAlertController(title: "Remove interest?", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Remove", style: .destructive) { (action) in
            LearnerRegistrationService.shared.removeInterest(interest)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        parentContainerViewController?.present(ac, animated: true, completion: nil)
    }
}

extension QTLearnerAddInterestsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LearnerRegistrationService.shared.interests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! QuickSearchSubcategoryCell
        cell.titleLabel.text = LearnerRegistrationService.shared.interests[indexPath.item]
        cell.backgroundColor = Colors.purple
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 60
        width = LearnerRegistrationService.shared.interests[indexPath.item].estimateFrameForFontSize(12, extendedWidth: true).width + 40
        return CGSize(width: width, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! QuickSearchSubcategoryCell
        cell.backgroundColor = Colors.purple.darker(by: 10)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! QuickSearchSubcategoryCell
        cell.backgroundColor = Colors.purple
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showRemovePromptFor(interest: LearnerRegistrationService.shared.interests[indexPath.item])
    }
}
