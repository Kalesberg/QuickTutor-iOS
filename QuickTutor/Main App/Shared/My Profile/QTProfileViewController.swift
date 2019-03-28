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
    @IBOutlet weak var ratingLabel: UILabel!
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
    @IBOutlet weak var reviewsStackView: UIStackView!
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var reviewsTabeViewHeight: NSLayoutConstraint!
    @IBOutlet weak var readAllReviewLabel: UILabel!
    @IBOutlet weak var readReviewsButton: UIButton!
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
    
    enum QTConnectionStatus {
        case connected, pending, none
    }
    
    let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
    var connectionStatus = QTConnectionStatus.none
    var actionSheet: FileReportActionsheet?
    var conversationManager = ConversationManager()
    var reviewsHeight: CGFloat = 0.0
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Actions
    @IBAction func onMessageButtonClicked(_ sender: Any) {
        let vc = ConversationVC()
        vc.receiverId = user.uid
        vc.chatPartner = user
        vc.subject = subject
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onMoreButtonClicked(_ sender: Any) {
        if #available(iOS 11.0, *) {
            actionSheet = FileReportActionsheet(bottomLayoutMargin: view.safeAreaInsets.bottom, name: String("Zach"))
        } else {
            actionSheet = FileReportActionsheet(bottomLayoutMargin: 0, name: String("Zach"))
        }
        actionSheet?.partnerId = user?.uid
        actionSheet?.isConnected = connectionStatus == .connected
        actionSheet?.show()
    }
    
    @IBAction func onReadReviewsButtonClicked(_ sender: Any) {
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
        if connectionStatus == .connected {
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
        if profileViewType == .tutor || profileViewType == .myTutor {
            avatarImageView.sd_setImage(with: user.profilePicUrl)
        } else {
            let reference = storageRef.child("student-info").child(user.uid).child("student-profile-pic1")
            avatarImageView.sd_setImage(with: reference)
        }
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDidAvatarImageViewTap)))
        
        // Set the active status of user.
        self.statusImageView.backgroundColor = Colors.gray
        OnlineStatusService.shared.getLastActiveStringFor(uid: user.uid) { result in
            guard let result = result else { return }
            self.statusImageView.backgroundColor = !result.isEmpty ? Colors.purple : Colors.gray
        }
        // User name
        usernameLabel.text = user.formattedName
        switch profileViewType {
        case .tutor:
            moreButtonsView.isHidden = false
            statisticStackView.isHidden = false
            if subject?.isEmpty ?? true {
                // Find the top subject
                func bayesianEstimate(C: Double, r: Double, v: Double, m: Double) -> Double {
                    return (v / (v + m)) * ((r + Double((m / (v + m)))) * C)
                }
                
                FirebaseData.manager.fetchSubjectsTaught(uid: user.uid) { subcategoryList in
                    let avg = subcategoryList.map({ $0.rating / 5 }).average
                    let topSubcategory = subcategoryList.sorted {
                        return bayesianEstimate(C: avg, r: $0.rating / 5, v: Double($0.numSessions), m: 0) > bayesianEstimate(C: avg, r: $1.rating / 5, v: Double($1.numSessions), m: 10)
                        }.first
                    guard let subcategory = topSubcategory?.subcategory else {
                        self.subject = nil
                        return
                    }
                    self.subject = subcategory
                    self.topSubjectLabel.isHidden = self.subject?.isEmpty ?? true
                    self.topSubjectLabel.text = self.subject
                }
            } else {
                topSubjectLabel.isHidden = subject?.isEmpty ?? true
                topSubjectLabel.text = subject
            }
            ratingLabel.text = "\(String(describing: user.tRating ?? 5.0))"
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
            topSubjectLabel.isHidden = true
            ratingLabel.text = "\(String(describing: user.tRating ?? 5.0))"
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
            topSubjectLabel.isHidden = subject?.isEmpty ?? true
            topSubjectLabel.text = subject
            ratingLabel.text = "\(String(describing: user.tRating ?? 5.0))"
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
            topSubjectLabel.isHidden = true
            ratingLabel.text = "\(String(describing: user.tRating ?? 5.0))"
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
        
        readReviewsButton.layer.cornerRadius = 3
        readReviewsButton.clipsToBounds = true
        readReviewsButton.setupTargets()
        
        if profileViewType == .tutor || profileViewType == .myTutor {
            reviewsTableView.isHidden = user.reviews?.isEmpty ?? true
            self.reviewsHeight = self.getHeightOfReviews(reviews: user.reviews ?? [Review]())
            let numberOfReviews = user.reviews?.count ?? 0
            readAllReviewLabel.text = "Read all \(numberOfReviews) \(numberOfReviews > 1 ? " reviews" : " review")"
        } else {
            reviewsTableView.isHidden = user.lReviews?.isEmpty ?? true
            let numberOfReviews = user.lReviews?.count ?? 0
            self.reviewsHeight = self.getHeightOfReviews(reviews: user.lReviews ?? [Review]())
            readAllReviewLabel.text = "Read all \(numberOfReviews) \(numberOfReviews > 1 ? " reviews" : " review")"
        }
        
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
        connectButton.setupTargets()
        
        connectView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        connectView.layer.shadowOpacity = 1
        connectView.layer.shadowOffset = CGSize(width: 0, height: -2)
        
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
            connectButton.setTitle("CONNECT", for: .normal)
            // Update the title of connect button based on the connection status.
            guard let opponentId = user?.uid else { return }
            DataService.shared.getConversationMetaDataForUid(opponentId) { metaDataIn in
                self.conversationManager.chatPartnerId = self.user.uid
                self.conversationManager.delegate = self
                self.conversationManager.metaData = metaDataIn
                self.conversationManager.setup()
            }
            numberOfReviewsLabel.text = "\(user.reviews?.count ?? 0)"
        case .learner,
             .myTutor,
             .myLearner:
            connectView.isHidden = true
        }
    }
    
    func updateSubjectsHeight() {
        subjectsCollectionViewHeight.constant = subjectsCollectionView.contentSize.height
        subjectsCollectionView.layoutIfNeeded()
    }
    
    func updateReviewsHeight() {
        reviewsTabeViewHeight.constant = reviewsHeight
        reviewsTableView.layoutIfNeeded()
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
    
    func getHeightOfReviews(reviews: [Review]) -> CGFloat {
        var height: CGFloat = 0.0
        var index = 0
        
        let threeLinesHeight = "A".height(withConstrainedWidth: UIScreen.main.bounds.size.width - 40, font: Fonts.createSize(16)) * 3
        
        reviews.forEach { review in
            if index == 1 { return }
            let reviewHeight = review.message.height(withConstrainedWidth: UIScreen.main.bounds.size.width - 40, font: Fonts.createSize(16))
            if reviewHeight > threeLinesHeight {
                height += threeLinesHeight + 78
            } else {
                height += reviewHeight + 78
            }
            index += 1
        }
        
        return height
    }
}

// MARK: - UICollectionViewDelegate
extension QTProfileViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDelegateFlowLayout
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
            width = subjects[indexPath.item].estimateFrameForFontSize(14).width + 20
        }
        return CGSize(width: width, height: 30)
    }
}

// MARK: - UICollectionViewDataSource
extension QTProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user?.subjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PillCollectionViewCell.reuseIdentifier, for: indexPath) as! PillCollectionViewCell
        if let subjects = user?.subjects {
            cell.titleLabel.font = Fonts.createMediumSize(14)
            cell.titleLabel.text = subjects[indexPath.item]
        }
        updateSubjectsHeight()
        return cell
    }
}

// MARK: - UITableViewDelegate
extension QTProfileViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension QTProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let reviews = profileViewType == .tutor || profileViewType == .myTutor ? user.reviews : user.lReviews
        if let reviews = reviews, reviews.count > 0 {
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QTReviewTableViewCell.reuseIdentifier, for: indexPath) as! QTReviewTableViewCell
        cell.selectionStyle = .none
        if let reviews = profileViewType == .tutor || profileViewType == .myTutor ? user.reviews : user.lReviews {
            cell.setData(review: reviews[indexPath.row])
            self.updateReviewsHeight()
        }
        return cell
    }
}

// MARK: - LearnerWasUpdatedCallBack
extension QTProfileViewController: LearnerWasUpdatedCallBack {
    func learnerWasUpdated(learner: AWLearner!) {
        
    }
}

extension QTProfileViewController: ConversationManagerDelegate {
    func conversationManager(_ conversationManager: ConversationManager, didReceive message: UserMessage) {
        // Enable the connect button
        if message.connectionRequestId != nil && conversationManager.isConnected == false {
            self.connectButton.isEnabled = true
            self.connectionStatus = .pending
            self.connectButton.setTitle("REQUEST PENDING", for: .normal)
        }
    }
    
    func conversationManager(_ conversationManager: ConversationManager, didLoad messages: [BaseMessage]) {
        
    }
    
    func conversationManager(_ conversationManager: ConversationManager, didUpdate readByIds: [String]) {
        
    }
    
    func conversationManager(_ convesationManager: ConversationManager, didUpdateConnection connected: Bool) {
        // Enable the connect button
        self.connectButton.isEnabled = true
        if connected {
            self.connectionStatus = .connected
            self.connectButton.setTitle("REQUEST SESSION", for: .normal)
        } else {
            guard conversationManager.messages.count > 0 else {
                self.connectionStatus = .none
                self.connectButton.setTitle("CONNECT", for: .normal)
                return
            }
            self.connectionStatus = .pending
            self.connectButton.setTitle("REQUEST PENDING", for: .normal)
        }
    }
    
    func conversationManager(_ conversationManager: ConversationManager, didLoadAll messages: [BaseMessage]) {
        
    }
}
