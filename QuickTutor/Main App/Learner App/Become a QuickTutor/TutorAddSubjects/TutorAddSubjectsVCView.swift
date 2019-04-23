//
//  TutorAddSubjectsVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class TutorAddSubjectsVCView: QuickSearchVCView {
    
    let accessoryViewHeight: CGFloat = 80
    
    let selectedSubjectsCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceHorizontal = true
        cv.delaysContentTouches = false
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        cv.register(QuickSearchSubcategoryCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    let accessoryView: RegistrationAccessoryView = {
        let view = RegistrationAccessoryView()
        view.layer.shadowOffset = CGSize(width: 0, height: -5)
        view.layer.shadowRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
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
        label.text = "Add up to 20 subjects."
        label.textAlignment = .left
        label.textColor = .white
        label.font = Fonts.createBoldSize(14)
        label.numberOfLines = 0
        return label
    }()
    
    let requestSessionButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.purple
        return button
    }()
    
    var selectedSubjectsHeightAnchor: NSLayoutConstraint?
    var collectionViewTopAnchor: NSLayoutConstraint?
    
    override func setupViews() {
        super.setupViews()
        setupSelectedSubjectsCV()
        setupAccessoryView()
        setupAccessoryTextLabel()
//        setupRequestSessionButton()
        let backIcon = UIImageView(image: UIImage(named:"newBackButton"))
        searchBarContainer.searchBar.leftView = backIcon
        searchBarContainer.cancelEditingButton.setTitle("Done", for: .normal)
        setupObservers()
        searchBarContainer.mockLeftViewButton.isHidden = false
        if TutorRegistrationService.shared.subjects.count > 0 {
            showSelectedSubjectsCVIfNeeded()
            updateAccessoryViewTextLabel()
            selectedSubjectsCV.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
    
    func setupSelectedSubjectsCV() {
        addSubview(selectedSubjectsCV)
        selectedSubjectsCV.anchor(top: searchBarContainer.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        selectedSubjectsHeightAnchor = selectedSubjectsCV.heightAnchor.constraint(equalToConstant: 0)
        selectedSubjectsHeightAnchor?.isActive = true
        layoutIfNeeded()
        selectedSubjectsCV.delegate = self
        selectedSubjectsCV.dataSource = self
    }
    
    func setupAccessoryView() {
        addSubview(accessoryView)
        accessoryView.anchor(top: nil, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: accessoryViewHeight)
    }
    
    func setupAccessoryTextLabel() {
        accessoryView.addSubview(accessoryTextLabel)
        accessoryTextLabel.anchor(top: accessoryView.topAnchor, left: accessoryView.leftAnchor, bottom: accessoryView.bottomAnchor, right: accessoryView.nextButton.leftAnchor, paddingTop: 5, paddingLeft: 20, paddingBottom: 5, paddingRight: 5, width: 0, height: 0)
    }
    
    func setupRequestSessionButton() {
        addSubview(requestSessionButton)
        requestSessionButton.anchor(top: nil, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 65)
        requestSessionButton.addTarget(self, action: #selector(handleRequestSession), for: .touchUpInside)
        layoutIfNeeded()
    }
    
    @objc func handleRequestSession() {
        let vc = SessionRequestVC()
//        navigationController?.pushViewController(vc, animated: true)
    }

    
    override func setupCollectionView() {
        addSubview(collectionView)
        collectionView.anchor(top: nil, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        collectionViewTopAnchor = collectionView.topAnchor.constraint(equalTo: searchBarContainer.bottomAnchor, constant: 10)
        collectionViewTopAnchor?.isActive = true
        layoutIfNeeded()
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSubjectAdded(_:)), name: Notifications.tutorDidAddSubject.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSubjectRemoved(_:)), name: Notifications.tutorDidRemoveSubject.name, object: nil)
    }
    
    
    @objc func handleSubjectAdded(_ notification: Notification) {
        showSelectedSubjectsCVIfNeeded()
        updateAccessoryViewTextLabel()
        selectedSubjectsCV.reloadData()
        let indexPath = IndexPath(item: selectedSubjectsCV.numberOfItems(inSection: 0) - 1, section: 0)
        selectedSubjectsCV.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
    @objc func handleSubjectRemoved(_ notification: Notification) {
        updateAccessoryViewTextLabel()
        selectedSubjectsCV.reloadData()
    }
    
    func showSelectedSubjectsCVIfNeeded() {
        guard selectedSubjectsHeightAnchor?.constant != 50 else { return }
        selectedSubjectsHeightAnchor?.constant = 50
        collectionViewTopAnchor?.constant = 60
        layoutIfNeeded()
    }
    
    func updateAccessoryViewTextLabel() {
        let remainingSubjectsCount = 20 - TutorRegistrationService.shared.subjects.count
        accessoryTextLabel.text = "Add up to \(remainingSubjectsCount) more subjects."
    }
    
    func showRemovePromptFor(subject: String) {
        let ac = UIAlertController(title: "Remove subject?", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { (action) in
            TutorRegistrationService.shared.removeSubject(subject)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            ac.dismiss(animated: true, completion: nil)
        }))
        parentContainerViewController?.present(ac, animated: true, completion: nil)
    }
}

extension TutorAddSubjectsVCView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TutorRegistrationService.shared.subjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! QuickSearchSubcategoryCell
        cell.titleLabel.text = TutorRegistrationService.shared.subjects[indexPath.item]
        cell.backgroundColor =  Colors.purple
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 60
        width = TutorRegistrationService.shared.subjects[indexPath.item].estimateFrameForFontSize(12).width + 40
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
        showRemovePromptFor(subject: TutorRegistrationService.shared.subjects[indexPath.item])
    }
}
