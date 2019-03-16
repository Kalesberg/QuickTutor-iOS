//
//  QTProfileViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 3/13/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth

enum QTProfileViewType {
    case tutor, learner, myTutor, myLearner
}

class QTProfileViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var moreButtonsView: UIView!
    @IBOutlet weak var statusImageView: QTCustomImageView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var ratingStarImageView: UIImageView!
    @IBOutlet weak var topSubjectLabel: UILabel!
    @IBOutlet weak var statisticStackView: UIStackView!
    @IBOutlet weak var numberOfLearnersLabel: UILabel!
    @IBOutlet weak var numberOfSessionsLabel: UILabel!
    @IBOutlet weak var numberOfSubjectsLabel: UILabel!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceView: QTCustomView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var subjectsCollectionView: UICollectionView!
    @IBOutlet weak var subjectsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var reviewsView: UIView!
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var reviewsTabeViewHeight: NSLayoutConstraint!
    @IBOutlet weak var readFeedbacksButton: UIButton!
    @IBOutlet weak var sessionTypesLabel: UILabel!
    @IBOutlet weak var travelDistanceLabel: UILabel!
    @IBOutlet weak var policiesView: UIView!
    @IBOutlet weak var latePolicyLabel: UILabel!
    @IBOutlet weak var lateFeeLabel: UILabel!
    @IBOutlet weak var cancellationPolicyLabel: UILabel!
    @IBOutlet weak var cancellationFeeLabel: UILabel!
    @IBOutlet weak var connectView: UIView!
    @IBOutlet weak var ratingView: QTRatingView!
    @IBOutlet weak var numberOfReviewsLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var rateLabel: UILabel!
    
    static var controller: QTProfileViewController {
        return QTProfileViewController(nibName: String(describing: QTProfileViewController.self), bundle: nil)
    }
    
    // Parameters
    var user: AWTutor!
    var profileViewType: QTProfileViewType!
    var subject: String?
    
    let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
    
    var isConnected: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegates()
        initData()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }

    // MARK: - Actions
    @IBAction func onMessageButtonClicked(_ sender: Any) {
        let vc = ConversationVC()
        vc.receiverId = user.uid
        vc.chatPartner = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onMoreButtonClicked(_ sender: Any) {
        
    }
    
    @IBAction func onReadFeedbacksButtonClicked(_ sender: Any) {
        guard let user = user, let profileViewType = profileViewType else { return }
        
        switch profileViewType {
        case .tutor, .myTutor:
            FirebaseData.manager.fetchTutor(user.uid, isQuery: false) { (fetchedTutorIn) in
                guard let fetchedTutor = fetchedTutorIn else { return }
                let vc = TutorReviewsVC()
                vc.datasource = fetchedTutor.reviews ?? [Review]()
                vc.isViewing = profileViewType == .tutor
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case .learner, .myLearner:
            FirebaseData.manager.fetchLearner(user.uid) { (learner) in
                guard let learner = learner else { return }
                let vc = LearnerReviewsVC()
                vc.datasource = learner.lReviews ?? [Review]()
                vc.isViewing = profileViewType == .learner
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func onConnectButtonClicked(_ sender: Any) {
        guard let user = user else { return }
        if isConnected {
            let vc = SessionRequestVC()
            vc.tutor = user
            navigationController?.pushViewController(vc, animated: true)
        } else {
            DataService.shared.getTutorWithId(user.uid) { tutor in
                let vc = ConversationVC()
                vc.receiverId = tutor?.uid
                vc.chatPartner = tutor
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc
    func handleEditProfile() {
        
        guard let profileViewType = profileViewType else { return }
        
        switch profileViewType {
        case .myTutor:
            let next = TutorEditProfileVC()
            next.delegate = self
            navigationController?.pushViewController(next, animated: true)
        case .myLearner:
            let next = LearnerEditProfileVC()
            next.delegate = self
            navigationController?.pushViewController(next, animated: true)
        default:
            break
        }
    }
    
    @objc
    func handleDidAvatarImageViewTap() {
        let images = createLightBoxImages()
        presentLightBox(images)
    }
    
    // MARK: - Functions
    func setupDelegates() {
        
        subjectsCollectionView.dataSource = self
        subjectsCollectionView.delegate = self
        
        subjectsCollectionView.register(PillCollectionViewCell.self, forCellWithReuseIdentifier: PillCollectionViewCell.reuseIdentifier)
        let layout = AlignedCollectionViewFlowLayout(
            horizontalAlignment: .left,
            verticalAlignment: .center
        )
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        subjectsCollectionView.collectionViewLayout = layout
        subjectsCollectionView.allowsMultipleSelection = false
        subjectsCollectionView.isScrollEnabled = false
        subjectsCollectionView.isUserInteractionEnabled = false
        
        reviewsTableView.dataSource = self
        reviewsTableView.delegate = self
        
        reviewsTableView.register(QTReviewTableViewCell.nib, forCellReuseIdentifier: QTReviewTableViewCell.reuseIdentifier)
        reviewsTableView.estimatedRowHeight = 100
        reviewsTableView.rowHeight = UITableView.automaticDimension
        reviewsTableView.separatorStyle = .none
        reviewsTableView.isScrollEnabled = false
    }
    
    func initData() {
        initUserInfo()
        initSubjects()
        initReviews()
        initPolicies()
        initConnectView()
    }
    
    func initUserInfo() {
        distanceLabel.layer.cornerRadius = 3
        distanceLabel.clipsToBounds = true
        
        guard let user = user, let profileViewType = profileViewType else { return }
        
        // Set the avatar of user profile.
        let reference = storageRef.child("student-info").child(user.uid).child("student-profile-pic1")
        avatarImageView.sd_setImage(with: reference)
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDidAvatarImageViewTap)))
        
        // Set the active status of user.
        self.statusImageView.backgroundColor = Colors.gray
        OnlineStatusService.shared.getLastActiveStringFor(uid: user.uid) { result in
            guard let result = result else { return }
            self.statusImageView.backgroundColor = result.isEmpty ? Colors.purple : Colors.gray
        }
        // User name
        usernameLabel.text = user.formattedName
        switch profileViewType {
        case .tutor:
            moreButtonsView.isHidden = false
            statisticStackView.isHidden = false
            ratingStarImageView.isHidden = true
            topSubjectLabel.text = subject
            numberOfLearnersLabel.text = "\(user.learners.count)"
            numberOfSessionsLabel.text = "\(user.tNumSessions ?? 0)"
            numberOfSubjectsLabel.text = "\(user.subjects?.count ?? 0)"
            addressView.isHidden = false
            distanceView.isHidden = false
            if let bio = user.tBio, !bio.isEmpty {
                bioLabel.text = "\(bio)"
            } else {
                bioLabel.text = "\(user.formattedName) has not yet entered a biography."
            }
            navigationItem.title = user.formattedName
        case .learner:
            moreButtonsView.isHidden = false
            statisticStackView.isHidden = true
            ratingStarImageView.isHidden = false
            topSubjectLabel.text = "\(String(describing: user.tRating ?? 5.0))"
            addressView.isHidden = true
            if let bio = user.bio, !bio.isEmpty {
                bioLabel.text = "\(bio)"
            } else {
                bioLabel.text = "\(user.formattedName) has not yet entered a biography."
            }
            navigationItem.title = user.formattedName
        case .myTutor:
            moreButtonsView.isHidden = true
            statisticStackView.isHidden = true
            ratingStarImageView.isHidden = false
            topSubjectLabel.text = "\(String(describing: user.tRating ?? 5.0))"
            addressView.isHidden = false
            distanceView.isHidden = true
            if let bio = user.tBio, !bio.isEmpty {
                bioLabel.text = "\(bio)"
            } else {
                bioLabel.text = "No biography yet! You can add a bio by tapping \"edit\" in the top right of the screen."
            }
            navigationItem.title = "My Profile"
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_pencil"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(handleEditProfile))
        case .myLearner:
            moreButtonsView.isHidden = true
            statisticStackView.isHidden = true
            ratingStarImageView.isHidden = false
            topSubjectLabel.text = "\(String(describing: user.tRating ?? 5.0))"
            addressView.isHidden = true
            if let bio = user.bio, !bio.isEmpty {
                bioLabel.text = "\(bio)"
            } else {
                bioLabel.text = "No biography yet! You can add a bio by tapping \"edit\" in the top right of the screen."
            }
            navigationItem.title = "My Profile"
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_pencil"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(handleEditProfile))
        }
        
        // Set address
        addressLabel.text = user.region
        if let distance = user.distance {
            distanceLabel.text = distance == 1 ? "\(distance) mile from you" : "\(distance) miles from you"
        } else {
            distanceLabel.text = "\(0) miles from you"
        }
        bioLabel.superview?.layoutIfNeeded()
    }
    
    func initSubjects() {
        guard let user = user else { return }
        
        subjectsCollectionView.isHidden = user.subjects?.isEmpty ?? true
        subjectsCollectionView.reloadData()
    }
    
    func initReviews() {
        guard let user = user else { return }
        
        reviewsView.isHidden = user.reviews?.isEmpty ?? true
        readFeedbacksButton.setTitle("Read \(user.reviews?.count ?? 0) feedbacks", for: .normal)
        
        reviewsTableView.reloadData()
    }
    
    func initPolicies() {
        guard let policy = user.policy, let profileViewType = profileViewType else { return }
        let policies = policy.split(separator: "_")
        switch profileViewType {
        case .tutor:
            policiesView.isHidden = false
        case .learner:
            policiesView.isHidden = true
        case .myTutor:
            policiesView.isHidden = false
        case .myLearner:
            policiesView.isHidden = true
        }
        sessionTypesLabel.text = user.formattedName + " " + user.preference.preferenceNormalization().lowercased()
        travelDistanceLabel.text = user.formattedName + " " + user.distance.distancePreference(user.preference).lowercased()
        if policies.count > 0 {
            latePolicyLabel.attributedText = String(policies[0]).lateNoticeNew()
        }
        if policies.count > 1 {
            lateFeeLabel.text = String(policies[1]).lateFee().trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if policies.count > 2 {
            cancellationPolicyLabel.attributedText = String(policies[2]).cancelNoticeNew()
        }
        if policies.count > 3 {
            cancellationFeeLabel.text = String(policies[3]).cancelFee().trimmingCharacters(in: .whitespacesAndNewlines)
        }
        policiesView.layoutIfNeeded()
    }
    
    func initConnectView() {
        ratingView.setupViews()
        ratingView.isUserInteractionEnabled = false
        
        connectButton.layer.cornerRadius = 3
        connectButton.clipsToBounds = true
        
        guard let profileViewType = profileViewType else { return }
        switch profileViewType {
        case .tutor:
            connectView.isHidden = false
            guard let price = user.price else { return }
            rateLabel.text = "$\(price) per hour"
            let rating = Int(user.tRating)
            ratingView.setRatingTo(rating)
            
            // Disable the connect button until app gets the connection status.
            connectButton.isEnabled = false
            // Update the title of connect button based on the connection status.
            guard let uid = Auth.auth().currentUser?.uid, let opponentId = user?.uid else { return }
            FirebaseData.manager.fetchConnectionStatus(uid: uid,
                                                       userType: AccountService.shared.currentUserType,
                                                       opponentId: opponentId) { (connected) in
                                                        
                                                        // Enable the connect button
                                                        self.connectButton.isEnabled = true
                                                        self.isConnected = connected
                                                        self.connectButton.setTitle(connected ? "REQUEST SESSION" : "CONNECT", for: .normal)
            }
            numberOfReviewsLabel.text = "\(user.reviews?.count ?? 0)"
        case .learner,
             .myTutor,
             .myLearner:
            connectView.isHidden = true
        }
    }
    
    func updateUI() {
        subjectsCollectionViewHeight.constant = subjectsCollectionView.contentSize.height
        reviewsTabeViewHeight.constant = reviewsTableView.contentSize.height
        reviewsView.layoutIfNeeded()
        scrollView.layoutIfNeeded()
    }
    
    func createLightBoxImages() -> [LightboxImage] {
        var images = [LightboxImage]()
        user?.images.forEach({ (arg) in
            let (_, imageUrl) = arg
            guard let url = URL(string: imageUrl) else { return }
            images.append(LightboxImage(imageURL: url))
        })
        return images
    }
    
    func presentLightBox(_ images: [LightboxImage]) {
        let controller = LightboxController(images: images, startIndex: 0)
        controller.dynamicBackground = true
        present(controller, animated: true, completion: nil)
    }
}

extension QTProfileViewController: UICollectionViewDelegate {
    
}

extension QTProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 60
        if let subjects = user?.subjects {
            width = subjects[indexPath.item].estimateFrameForFontSize(10).width + 20
        }
        return CGSize(width: width, height: 30)
    }
}

extension QTProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user?.subjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PillCollectionViewCell.reuseIdentifier, for: indexPath) as! PillCollectionViewCell
        if let subjects = user?.subjects {
            cell.titleLabel.font = Fonts.createMediumSize(10)
            cell.titleLabel.text = subjects[indexPath.item]
        }
        updateUI()
        return cell
    }
}

extension QTProfileViewController: UITableViewDelegate {
    
}

extension QTProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let reviews = user.reviews else { return 0 }
        return reviews.count >= 2 ? 2 : reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QTReviewTableViewCell.reuseIdentifier, for: indexPath) as! QTReviewTableViewCell
        cell.selectionStyle = .none
        if let reviews = user.reviews {
            cell.setData(review: reviews[indexPath.row])
        }
        updateUI()
        return cell
    }
}

extension QTProfileViewController: LearnerWasUpdatedCallBack {
    func learnerWasUpdated(learner: AWLearner!) {
        
    }
}
