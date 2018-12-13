//
//  SavedTutorsVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 11/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class SavedTutorsVC: UIViewController {
    
    var datasource = [FeaturedTutor]()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.darkBackground
        cv.allowsMultipleSelection = false
        cv.alwaysBounceVertical = true
        cv.register(TutorCollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.darkBackground
        navigationItem.title = "Saved"
        navigationController?.navigationBar.barTintColor = Colors.newBackground
        navigationController?.navigationBar.backgroundColor = Colors.newBackground
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
    }
    
    func loadSavedTutors() {
        
    }
}

class TutorCardView: UIView, TutorDataSource {
    
    var tutor: AWTutor?
    var subject: String?
    var parentViewController: UIViewController?
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.canCancelContentTouches = true
        sv.isDirectionalLockEnabled = true
        sv.isExclusiveTouch = false
        sv.backgroundColor = Colors.darkBackground
        sv.layer.cornerRadius = 10
        return sv
    }()
    
    let headerView: TutorCardHeaderView = {
        let view = TutorCardHeaderView()
        return view
    }()
    
    let infoView: TutorCardInfoView = {
        let view = TutorCardInfoView()
        return view
    }()
    
    let reviewsView: TutorCardReviewsView = {
        let view = TutorCardReviewsView()
        return view
    }()
    
    let policiesView: TutorCardPoliciesView = {
        let view = TutorCardPoliciesView()
        return view
    }()
    
    let connectView: TutorCardConnectView = {
        let view = TutorCardConnectView()
        return view
    }()
    
    var infoHeightAnchor: NSLayoutConstraint?
    var reviewsHeightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupScrollView()
        setupHeaderView()
        setupInfoView()
        setupReviewsView()
        setupPoliciesView()
        setupConnectView()
    }
    
    func setupScrollView() {
        addSubview(scrollView)
        scrollView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupHeaderView() {
        scrollView.addSubview(headerView)
        headerView.anchor(top: scrollView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    func setupInfoView() {
        scrollView.addSubview(infoView)
        infoView.anchor(top: headerView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        infoHeightAnchor = infoView.heightAnchor.constraint(equalToConstant: 0)
        infoHeightAnchor?.isActive = true
    }
    
    func setupReviewsView() {
        scrollView.addSubview(reviewsView)
        reviewsView.anchor(top: infoView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        reviewsHeightAnchor = reviewsView.heightAnchor.constraint(equalToConstant: 200)
        reviewsHeightAnchor?.isActive = true
    }
    
    func setupPoliciesView() {
        scrollView.addSubview(policiesView)
        policiesView.anchor(top: reviewsView.bottomAnchor, left: leftAnchor, bottom: scrollView.bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 50, paddingRight: 20, width: 0, height: 300)
    }
    
    func setupConnectView() {
        addSubview(connectView)
        connectView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 84)
        connectView.connectButton.addTarget(self, action: #selector(connect), for: .touchUpInside)
    }
    
    @objc func connect() {
        guard let tutor = tutor else { return }
        DataService.shared.getTutorWithId(tutor.uid) { tutor in
            let vc = ConversationVC()
            vc.receiverId = tutor?.uid
            vc.chatPartner = tutor
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func seeAllReviews(_ sender: UIButton) {

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        headerView.sizeToFit()
        infoView.sizeToFit()
        reviewsView.sizeToFit()
        reviewsView.delegate = self
    }
    
    func updateUI(_ tutor: AWTutor) {
        headerView.updateUI(tutor)
        infoView.updateUI(tutor)
        reviewsView.updateUI(tutor)
        policiesView.updateUI(tutor)
        connectView.updateUI(tutor)
        self.tutor = tutor
        infoView.dataSource = self
        infoView.delegate = self
        infoView.subjectsCV.reloadData()
        if tutor.reviews?.count == 0 {
            reviewsHeightAnchor?.constant = 0
            reviewsView.clipsToBounds = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TutorCardView: TutorCardInfoViewDelegate {
    func infoView(_ infoView: TutorCardInfoView, didUpdate height: CGFloat) {
        infoHeightAnchor?.constant = height
        layoutIfNeeded()
    }
}

extension TutorCardView: TutorCardReviewsViewDelegate {
    func reviewsView(_ reviewsView: TutorCardReviewsView, didUpdate height: CGFloat) {
        reviewsHeightAnchor?.constant = height
        layoutIfNeeded()
    }
}

class TutorCardHeaderView: UIView {
    
    var tutor: AWTutor?
    var subject: String?
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 4
        iv.backgroundColor = Colors.gray
        iv.clipsToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBlackSize(24)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let subjectLabel: UILabel = {
        let label = UILabel()
        label.text = "Politics"
        label.textColor = Colors.learnerPurple
        label.textAlignment = .left
        label.font = Fonts.createSize(14)
        return label
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"heartIcon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    let shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"shareIconProfile"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    func setupViews() {
        setupProfileImageView()
        setupNameLabel()
        setupSubjectLabel()
        setupShareButton()
        setupSaveButton()
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 135, height: 29)
    }
    
    func setupSubjectLabel() {
        addSubview(subjectLabel)
        subjectLabel.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 135, height: 17)
        let bottomConstraint = NSLayoutConstraint(item: subjectLabel, attribute: .bottom, relatedBy: .equal, toItem: profileImageView, attribute: .bottom, multiplier: 1, constant: 15)
        bottomConstraint.priority = UILayoutPriority(rawValue: 999)
        bottomConstraint.isActive = true
    }
    
    func setupShareButton() {
        addSubview(shareButton)
        shareButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        addConstraint(NSLayoutConstraint(item: shareButton, attribute: .centerY, relatedBy: .equal, toItem: nameLabel, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func setupSaveButton() {
        addSubview(saveButton)
        saveButton.anchor(top: nil, left: nil, bottom: nil, right: shareButton.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 20, height: 20)
        addConstraint(NSLayoutConstraint(item: saveButton, attribute: .centerY, relatedBy: .equal, toItem: nameLabel, attribute: .centerY, multiplier: 1, constant: 0))
        saveButton.addTarget(self, action: #selector(handleSaveButton), for: .touchUpInside)
    }
    
    func updateUI(_ tutor: AWTutor) {
        self.tutor = tutor
        nameLabel.text = tutor.name
        if let subject = subject {
            subjectLabel.text = subject
        }
        DataService.shared.getTutorWithId(tutor.uid) { (tutor2) in
            guard let tutor2 = tutor2 else { return }
            self.profileImageView.sd_setImage(with: tutor2.profilePicUrl)
        }
        
        if let savedTutorIds = CurrentUser.shared.learner.savedTutorIds {
            savedTutorIds.contains(tutor.uid) ? saveButton.setImage(UIImage(named:"heartIconFilled"), for: .normal) : saveButton.setImage(UIImage(named:"heartIcon"), for: .normal)
        }
    }
    
    @objc func handleSaveButton() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = tutor?.uid, uid != tutorId else { return }
        if let savedTutorIds = CurrentUser.shared.learner.savedTutorIds {
            savedTutorIds.contains(tutorId) ? unsaveTutor() : saveTutor()
        } else {
            saveTutor()
        }
    }
    
    func saveTutor() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = tutor?.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).setValue(1)
        saveButton.setImage(UIImage(named: "heartIconFilled"), for: .normal)
        CurrentUser.shared.learner.savedTutorIds?.append(tutorId)
    }
    
    func unsaveTutor() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = tutor?.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).removeValue()
        saveButton.setImage(UIImage(named: "heartIcon"), for: .normal)
        CurrentUser.shared.learner.savedTutorIds?.removeAll(where: { (id) -> Bool in
            return id == tutorId
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PillCollectionViewCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? Colors.learnerPurple : Colors.gray
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Swift"
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createSize(14)
        return label
    }()
    
    func setupViews() {
        setupMainView()
        setupTitleLabel()
    }
    
    func setupMainView() {
        backgroundColor = Colors.gray
        layer.cornerRadius = 4
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol TutorDataSource {
    var tutor: AWTutor? { get set }
}

protocol TutorCardInfoViewDelegate {
    func infoView(_ infoView: TutorCardInfoView, didUpdate height: CGFloat)
}



class TutorCardInfoViewFlowLayout: UICollectionViewFlowLayout {
    
    let spacing = 10
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let answer = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        let count = answer.count
        guard count > 1 else { return nil }
        for i in 1..<count {
            let currentLayoutAttributes = answer[i]
            let prevLayoutAttributes = answer[i-1]
            let origin = prevLayoutAttributes.frame.maxX
            if (origin + CGFloat(spacing) + currentLayoutAttributes.frame.size.width) < self.collectionViewContentSize.width && currentLayoutAttributes.frame.origin.x > prevLayoutAttributes.frame.origin.x {
                var frame = currentLayoutAttributes.frame
                frame.origin.x = origin + CGFloat(spacing)
                currentLayoutAttributes.frame = frame
            }
        }
        return answer
    }
}

class SubjectsCollectionView: UICollectionView {
    
    let layout: AlignedCollectionViewFlowLayout = {
        let layout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .center)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        return layout
    }()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        collectionViewLayout = self.layout
        allowsMultipleSelection = false
        isScrollEnabled = false
        isUserInteractionEnabled = false
        backgroundColor = Colors.darkBackground
        register(PillCollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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

protocol TutorCardReviewsViewDelegate {
    func reviewsView(_ reviewsView: TutorCardReviewsView, didUpdate height: CGFloat)
}

class TutorCardReviewsView: UIView {
    
    var delegate: TutorCardReviewsViewDelegate?
    
    let reviewView: ReviewView = {
        let view = ReviewView()
        return view
    }()
    
    let seeAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("Read all 12 reviews", for: .normal)
        button.titleLabel?.font = Fonts.createSize(16)
        button.setTitleColor(Colors.learnerPurple, for: .normal)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray
        view.layer.cornerRadius = 0.5
        return view
    }()
    
    var reviewsViewHeightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupReviewView()
        setupSeeAllButton()
        setupSeparator()
    }
    
    func setupReviewView() {
        addSubview(reviewView)
        reviewView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        reviewsViewHeightAnchor = reviewView.heightAnchor.constraint(equalToConstant: 120)
        reviewsViewHeightAnchor?.isActive = true
    }
    
    func setupSeeAllButton() {
        addSubview(seeAllButton)
        seeAllButton.anchor(top: reviewView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
    }
    
    func setupSeparator() {
        addSubview(separator)
        separator.anchor(top: seeAllButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func updateUI(_ tutor: AWTutor) {
        guard let lastReview = tutor.reviews?.last else { return }
        reviewView.nameLabel.text = lastReview.studentName
        reviewView.dateLabel.text = lastReview.formattedDate
        reviewView.reviewLabel.text = lastReview.message
        let rating = Int(lastReview.rating)
        reviewView.starView.setRating(rating)
        DataService.shared.getStudentWithId(lastReview.reviewerId) { (student) in
            guard let student = student else { return }
            self.reviewView.profileImageView.sd_setImage(with: student.profilePicUrl)
        }
        updateHeight()
    }
    
    func updateHeight() {
        guard let text = reviewView.reviewLabel.text else { return }
        let reviewHeight = text.estimateFrameForFontSize(14).height + 10
        reviewView.reviewTextHeightAnchor?.constant = reviewHeight
        reviewsViewHeightAnchor?.constant = reviewHeight + 40 + 18
        let height = reviewHeight + 40 + 18 + 20 + 45
        delegate?.reviewsView(self, didUpdate: height)
        layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ReviewView: UIView {
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = Colors.gray
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark S."
        label.textAlignment = .left
        label.textColor = .white
        label.font = Fonts.createBlackSize(14)
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Dec 2019"
        label.textAlignment = .left
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = Fonts.createBoldSize(10)
        return label
    }()
    
    let starView: StarView = {
        let view = StarView()
        view.tintStars(color: Colors.learnerPurple)
        return view
    }()
    
    let reviewLabel: UILabel = {
        let label = UILabel()
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = Fonts.createSize(16)
        return label
    }()
    
    var reviewTextHeightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupProfileImageView()
        setupNameLabel()
        setupDateLabel()
        setupStarView()
        setupReviewLabel()
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 0)
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 3, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 150, height: 17)
    }
    
    func setupDateLabel() {
        addSubview(dateLabel)
        dateLabel.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: profileImageView.bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 150, height: 12)
    }
    
    func setupStarView() {
        addSubview(starView)
        starView.anchor(top: nil, left: nil, bottom: profileImageView.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 55, height: 8)
    }
    
    func setupReviewLabel() {
        addSubview(reviewLabel)
        reviewLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 18, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        reviewTextHeightAnchor = reviewLabel.heightAnchor.constraint(equalToConstant: 63)
        reviewTextHeightAnchor?.isActive = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TutorCardPoliciesView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Policies"
        return label
    }()
    
    let sessionTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Tutor online or in-person"
        return label
    }()
    
    let travelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Travel up to 5 miles"
        return label
    }()
    
    let latePolicyLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Late Policy: 10 Minutes Notice"
        return label
    }()
    
    let lateFeeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Late Fee: $10.00"
        return label
    }()
    
    let cancellationPolicyLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Cancellation Policy: 24 Hours Notice"
        return label
    }()
    
    let cancellationFeeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Cancellation Fee: $5.00"
        return label
    }()
    
    func setupViews() {
        setupTitleLabel()
        setupSessionTypeLabel()
        setupTravelLabel()
        setupLatePolicyLabel()
        setupLateFeeLabel()
        setupCancellationPolicyLabel()
        setupCancellationFeeLabel()
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func setupSessionTypeLabel() {
        addSubview(sessionTypeLabel)
        sessionTypeLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func setupTravelLabel() {
        addSubview(travelLabel)
        travelLabel.anchor(top: sessionTypeLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func setupLatePolicyLabel() {
        addSubview(latePolicyLabel)
        latePolicyLabel.anchor(top: travelLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func setupLateFeeLabel() {
        addSubview(lateFeeLabel)
        lateFeeLabel.anchor(top: latePolicyLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func setupCancellationPolicyLabel() {
        addSubview(cancellationPolicyLabel)
        cancellationPolicyLabel.anchor(top: lateFeeLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func setupCancellationFeeLabel() {
        addSubview(cancellationFeeLabel)
        cancellationFeeLabel.anchor(top: cancellationPolicyLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func updateUI(_ tutor: AWTutor) {
        guard let policy = tutor.policy else { return }
        let policies = policy.split(separator: "_")
        sessionTypeLabel.text = tutor.preference.preferenceNormalization()
        travelLabel.text = tutor.distance.distancePreference(tutor.preference)
        latePolicyLabel.text = String(policies[0]).lateNotice()
        lateFeeLabel.text = String(policies[1]).lateFee().trimmingCharacters(in: .whitespacesAndNewlines)
        cancellationPolicyLabel.text = String(policies[2]).cancelNotice()
        cancellationFeeLabel.text = String(policies[3]).cancelFee().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TutorCardConnectView: CardFooterView {
    
    let accessoryView: TutorCardAccessoryView = {
        let view = TutorCardAccessoryView()
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        leftAccessoryView = accessoryView
    }
}

class BaseAccessoryView: UIView {
    
    func setupViews() {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TutorCardAccessoryView: BaseAccessoryView {
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "$60 per hour"
        label.textAlignment = .left
        label.textColor = .white
        label.font = Fonts.createBoldSize(14)
        return label
    }()
    
    let starView: StarView = {
        let view = StarView()
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        setupPriceLabel()
        setupStarView()
    }
    
    func setupPriceLabel() {
        addSubview(priceLabel)
        priceLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 130, height: 17)
    }
    
    func setupStarView() {
        addSubview(starView)
        starView.anchor(top: priceLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 8)
        starView.tintStars(color: Colors.learnerPurple)
    }
}

enum SessionRequestErrorCode: String {
    case noTutor = "Choose a tutor"
    case noSubject = "Choose a subject"
    case invalidDate = "Choose a valid date"
    case invalidDuration = "Choose a valid duration"
    case invalidPrice = "Enter a valid price"
    case noType = "Select a session type"
}

class SessionRequestErrorAccessoryView: BaseAccessoryView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = Fonts.createBoldSize(14)
        label.text = "Error message"
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        setupTitleLabel()
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
}

class SessionRequestAccessoryView: BaseAccessoryView {
    
}

class CardFooterView: UIView {

    var leftAccessoryView: UIView! {
        didSet {
            setupLeftAccessoryView()
        }
    }
    
    let connectButton: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.learnerPurple
        button.setTitle("CONNECT", for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.layer.cornerRadius = 4
        return button
    }()
    
    func setupViews() {
        setupMainView()
        setupConnectButton()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    private func setupLeftAccessoryView() {
        addSubview(leftAccessoryView)
        leftAccessoryView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 150, height: 0)
    }
    
    func setupConnectButton() {
        addSubview(connectButton)
        connectButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 20, paddingRight: 20, width: 168, height: 0)
    }
    
    func updateUI(_ tutor: AWTutor) {
        guard let price = tutor.price else { return }
        guard let priceView = leftAccessoryView as? TutorCardAccessoryView else { return }
        priceView.priceLabel.text = "$\(price) per hour"
        let rating = Int(tutor.tRating)
        priceView.starView.setRating(rating)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//extension SavedTutorsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
//        return datasource.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! TutorCollectionViewCell
//        cell.updateUI(datasource[indexPath.item])
//        return cell
//    }
//    
//    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
//        let screen = UIScreen.main.bounds
//        return CGSize(width: (screen.width - 60) / 2, height: 190)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! TutorCollectionViewCell
//        cell.shrink()
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! TutorCollectionViewCell
//        UIView.animate(withDuration: 0.2) {
//            cell.transform = CGAffineTransform.identity
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! TutorCollectionViewCell
//        cell.growSemiShrink {
//            let vc = TutorConnectVC()
//            vc.category = self.category
//            vc.startIndex = indexPath
//            vc.featuredTutors = self.datasource
//            vc.contentView.searchBar.placeholder = "\(self.category.mainPageData.displayName) • \(self.datasource[indexPath.item].subject)"
//            let nav = self.navigationController
//            DispatchQueue.main.async {
//                nav?.view.layer.add(CATransition().segueFromBottom(), forKey: nil)
//                nav?.pushViewController(vc, animated: false)
//            }
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell", for: indexPath) as! SectionHeader
//        cell.category.text = CategorySelected.title
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: collectionView.frame.width, height: 70)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 20
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 20
//    }
//}
//

class TutorCardVC: UIViewController {
    
    let contentView = TutorCardView()
    var tutor: AWTutor?
    var subject: String?
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupNavBar()
        contentView.tutor = tutor
        contentView.headerView.subjectLabel.text = subject
        contentView.parentViewController = self
    }
    
    func setupNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"newBackButton"), style: .plain, target: self, action: #selector(onBack))
        navigationController?.view.backgroundColor = Colors.darkBackground
    }
    
    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }
}


extension UILabel {
    
    func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
}

class LearnerMainPageAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let originFrame: CGRect
    
    init(originFrame: CGRect) {
        self.originFrame = originFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: .to)
            else {
                return
        }
        let toView = toViewController.view!
        let finalFrame = toView.frame
        transitionContext.containerView.addSubview(toView)
        toView.frame = originFrame
        toView.alpha = 0
        
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            toView.alpha = 1
            toView.frame = finalFrame
            toView.layoutIfNeeded()
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    
}
