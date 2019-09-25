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
import FirebaseDatabase
import CoreLocation
import Cosmos
import AVKit

enum QTProfileViewType {
    case tutor, learner, myTutor, myLearner
}

class QTProfileViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusImageView: QTCustomImageView!
    @IBOutlet weak var ratingStarImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var lblHourlyRate: UILabel!
    @IBOutlet weak var btnQuickCall: UIButton!
    
    @IBOutlet weak var lblSubjectTitle: UILabel!
    @IBOutlet weak var topSubjectLabel: UILabel!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var languageView: UIView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var schoolView: UIView!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var schoolLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var distanceView: QTCustomView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var subjectsCollectionView: UICollectionView!
    @IBOutlet weak var subjectsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var videoCollectionView: UICollectionView!
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
    
    // recommendations
    @IBOutlet weak var viewRecommendations: UIView!
    @IBOutlet weak var imgRecommendedLearner: UIImageView!
    @IBOutlet weak var lblRecommendedLearners: UILabel!
    @IBOutlet weak var lblRecommendedText: UILabel!
    @IBOutlet weak var viewWriteRecommend: UIView!
    @IBOutlet weak var lblWriteRecommend: UILabel!
    
    // bottom bar
    @IBOutlet weak var connectView: UIView!
    @IBOutlet weak var imgBottomUser: UIImageView!
    @IBOutlet weak var lblBottomUserName: UILabel!
    @IBOutlet weak var lblBottomHourlyRate: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var numberOfReviewsLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var constraintConnectViewBottom: NSLayoutConstraint!
    
    static var controller: QTProfileViewController {
        return QTProfileViewController(nibName: String(describing: QTProfileViewController.self), bundle: nil)
    }
    
    // Parameters
    var user: AWTutor!
    var profileViewType: QTProfileViewType!
    var subject: String?
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var isPresentedFromSessionScreen = false
    
    private var btnSave: UIButton!
    
    enum QTConnectionStatus {
        case connected, pending, none
    }
    
    let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
    var connectionStatus = QTConnectionStatus.none
    var actionSheet: FileReportActionsheet?
    var conversationManager = ConversationManager()
    var reviewsHeight: CGFloat = 0.0
    var connectionRef: DatabaseReference?
    var connectionHandle: DatabaseHandle?
    lazy var sharedProfileView = QTSharedProfileView()
    
    // For quick call observer
    var tutorInfoRef: DatabaseReference?
    var tutorInfoHandle: DatabaseHandle?
    
    private var videos: [TutorVideo]!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
        setupDelegates()
        setupLocationManager()
        
        scrollView.backgroundColor = Colors.newScreenBackground
        
        if profileViewType == .myTutor || profileViewType == .tutor {
            setupSharedProfileView()
        }
        
        if .tutor == profileViewType {
            btnQuickCall.isHidden = -1 == user.quickCallPrice
        }
        if .myTutor == profileViewType || .tutor == profileViewType {
            viewRecommendations.superview?.isHidden = false
        } else {
            viewRecommendations.superview?.isHidden = true
        }
        
        if #available(iOS 11.0, *) {
            if !isPresentedFromSessionScreen {
                navigationItem.largeTitleDisplayMode = .never
            }
        }
        
        btnSave = UIButton(type: .custom)
        btnSave.setImage(UIImage(named: "heartIcon"), for: .normal)
        btnSave.setImage(UIImage(named: "heartIconFilled"), for: .selected)
        btnSave.addTarget(self, action: #selector(onClickBtnSaveTutor), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        hideTabBar(hidden: true)
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopUpdatingLocation()
        
        hideTabBar(hidden: false)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            removeDatabaseObservers()
            
            // Remove old notification observers
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    
    func setupObservers() {
        if profileViewType == .myTutor {
            // Add new notification observers
            NotificationCenter.default.addObserver(self, selector: #selector(reloadSubjects(_:)), name: Notifications.tutorDidAddSubject.name, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(reloadSubjects(_:)), name: Notifications.tutorDidRemoveSubject.name, object: nil)
        } else if profileViewType == .myLearner {
            // Add new notification observers
            NotificationCenter.default.addObserver(self, selector: #selector(reloadSubjects(_:)), name: Notifications.learnerDidAddInterest.name, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(reloadSubjects(_:)), name: Notifications.learnerDidRemoveInterest.name, object: nil)
        }
    }
    
    func removeDatabaseObservers() {
        if let connectionRef = connectionRef, let connectionHandle = connectionHandle {
            connectionRef.removeObserver(withHandle: connectionHandle)
            self.connectionRef = nil
            self.connectionHandle = nil
        }
        
        if let tutorInfoRef = tutorInfoRef, let tutorInfoHandle = tutorInfoHandle {
            tutorInfoRef.removeObserver(withHandle: tutorInfoHandle)
            self.tutorInfoRef = nil
            self.tutorInfoHandle = nil
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    @objc private func onClickBtnSaveTutor() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = user.uid, uid != tutorId else { return }
        let savedTutorIds = CurrentUser.shared.learner.savedTutorIds
        savedTutorIds.contains(tutorId) ? unsaveTutor() : saveTutor()
    }
    
    // MARK: - Actions
    @IBAction func onMessageButtonClicked(_ sender: Any) {
        let vc = ConversationVC()
        vc.receiverId = user.uid
        vc.chatPartner = user
        vc.subject = subject
        navigationController?.pushViewController(vc, animated: true)
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
                vc.navigationItem.title = "\(user.name.components(separatedBy: " ")[0])'s Reviews"
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
            UserFetchService.shared.getTutorWithId(user.uid) { tutor in
                let vc = ConversationVC()
                vc.receiverId = tutor?.uid
                vc.chatPartner = tutor
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func onQuickCallButtonClicked(_ sender: Any) {
        let controller = QTRequestQuickCallViewController.controller
        controller.tutor = user
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onTapViewRecommendations(_ sender: Any) {
        let viewRecommendationsVC = QTViewRecommendationsViewController(nibName: String(describing: QTViewRecommendationsViewController.self), bundle: nil)
        viewRecommendationsVC.objTutor = user
        navigationController?.pushViewController(viewRecommendationsVC, animated: true)
    }
    
    @IBAction func onTapWriteRecommedation(_ sender: Any) {
        let writeRecommendationVC = QTWriteRecommendationViewController(nibName: String(describing: QTWriteRecommendationViewController.self), bundle: nil)
        writeRecommendationVC.objTutor = user
        navigationController?.pushViewController(writeRecommendationVC, animated: true)
    }
    
    @IBAction func onClickBtnConnected(_ sender: Any) {
        handleMoreButtonClicked()
    }
    
    @objc
    func handleEditProfile() {
        
        guard let profileViewType = profileViewType else { return }
        
        switch profileViewType {
        case .myTutor:
            let next = TutorEditProfileVC()
            next.delegate = self
            next.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(next, animated: true)
        case .myLearner:
            let next = LearnerEditProfileVC()
            next.delegate = self
            next.hidesBottomBarWhenPushed = true
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
    
    @objc
    func handleMoreButtonClicked() {
        if #available(iOS 11.0, *) {
            actionSheet = FileReportActionsheet(bottomLayoutMargin: view.safeAreaInsets.bottom, name: String(user?.formattedName ?? "User"))
        } else {
            actionSheet = FileReportActionsheet(bottomLayoutMargin: 0, name: String(user?.formattedName ?? "User"))
        }
        actionSheet?.partnerId = user?.uid
        actionSheet?.isConnected = connectionStatus == .connected
        actionSheet?.isTutorSheet = AccountService.shared.currentUserType == .tutor
        actionSheet?.parentViewController = self
        actionSheet?.subject = subject
        actionSheet?.show()
    }
    
    @objc
    func handleShareProfileButtonClicked() {
        guard let id = user.uid else { return }
        guard let username = user.username, let subject = self.subject else { return }
        let image = self.sharedProfileView.asImage()
        
        guard let data = image.jpegData(compressionQuality: 1.0) else { return }
        
        displayLoadingOverlay()
        FirebaseData.manager.uploadProfilePreviewImage(tutorId: id, data: data) { (error, url) in
            if let message = error?.localizedDescription {
                DispatchQueue.main.async {
                    self.dismissOverlay()
                    AlertController.genericErrorAlert(self, message: message)
                }
                return
            }
            
            
            DynamicLinkFactory.shared.createLink(userId: id, username: username, subject: subject, profilePreviewUrl: url) { shareUrl in
                guard let shareUrlString = shareUrl?.absoluteString else {
                    DispatchQueue.main.async {
                        self.dismissOverlay()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.dismissOverlay()
                    let ac = UIActivityViewController(activityItems: [shareUrlString], applicationActivities: nil)
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }
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
        initRecommendations()
        initPolicies()
        initConnectView()
    }
    
    func initUserInfo() {
        distanceLabel.layer.cornerRadius = 3
        distanceLabel.clipsToBounds = true
        
        guard let user = user, let profileViewType = profileViewType else { return }
        
        // Set the avatar of user profile.
        if profileViewType == .tutor || profileViewType == .myTutor {
            lblSubjectTitle.text = "Topics"
            UserFetchService.shared.getTutorWithId(uid: user.uid) { (tutor) in
                self.avatarImageView.sd_setImage(with: tutor?.profilePicUrl)
                self.imgBottomUser.sd_setImage(with: tutor?.profilePicUrl)
                self.user?.profilePicUrl = tutor?.profilePicUrl
                if let images = tutor?.images {
                    self.user.images = images
                }
            }
        } else {
            lblSubjectTitle.text = "Interests"
            lblSubjectTitle.superview?.isHidden = user.interests?.isEmpty ?? true
            UserFetchService.shared.getStudentWithId(uid: user.uid) { (learner) in
                self.avatarImageView.sd_setImage(with: learner?.profilePicUrl)
                self.imgBottomUser.sd_setImage(with: learner?.profilePicUrl)
                if let url = learner?.profilePicUrl {
                    self.user?.profilePicUrl = url
                }
                if let images = learner?.images {
                    self.user.images = images
                }
                if let interests = learner?.interests {
                    self.user.interests = interests
                    DispatchQueue.main.async {
                        self.subjectsCollectionView.reloadData()
                    }
                }
            }
        }
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDidAvatarImageViewTap)))
        
        // Set the active status of user.
        self.statusImageView.backgroundColor = Colors.gray
        UserStatusService.shared.getUserStatus(user.uid) { status in
            self.statusImageView.backgroundColor = status?.status == .online ? Colors.statusActiveColor : Colors.gray
        }
        
        // User name
        usernameLabel.text = user.formattedName
        lblBottomUserName.text = user.formattedName
        lblWriteRecommend.text = "Recommend \(user.formattedName)"
        
        showSchool(user: user)
        showLanguage(user: user)
        
        switch profileViewType {
        case .tutor:
//            saveButton.isHidden = false
            let subjectsCount = user.subjects?.count ?? 0
            if subject?.isEmpty ?? true {
                if let featuredSubject = user.featuredSubject, !featuredSubject.isEmpty {
                    // Set the featured subject.
                    subject = featuredSubject
                    if 1 < subjectsCount {
                        topSubjectLabel.text = "Teaches \(featuredSubject.capitalizingFirstLetter()) & \(subjectsCount - 1) other topic\(3 < subjectsCount ? "s" : "")."
                    } else {
                        topSubjectLabel.text = "Teaches \(featuredSubject.capitalizingFirstLetter())."
                    }
                } else {
                    // Set the first subject
                    subject = user.subjects?.first
                    if let subject = subject {
                        if 1 < subjectsCount {
                            topSubjectLabel.text = "Teaches \(subject.capitalizingFirstLetter()) & \(subjectsCount - 1) other topic\(3 < subjectsCount ? "s" : "")."
                        } else {
                            topSubjectLabel.text = "Teaches \(subject.capitalizingFirstLetter())."
                        }
                    }
                    topSubjectLabel.superview?.isHidden = subject?.isEmpty ?? true
                }
            } else {
                topSubjectLabel.superview?.isHidden = subject?.isEmpty ?? true
                if let subject = subject {
                    if 1 < subjectsCount {
                        topSubjectLabel.text = "Teaches \(subject.capitalizingFirstLetter()) & \(subjectsCount - 1) other topic\(3 < subjectsCount ? "s" : "")."
                    } else {
                        topSubjectLabel.text = "Teaches \(subject.capitalizingFirstLetter())."
                    }
                }
            }
            ratingLabel.text = "\(String(describing: user.tRating ?? 5.0))"
            addressView.isHidden = false
            distanceView.isHidden = true
            // Set address
            addressLabel.text = user.region
            
            updateDistanceLabel()
            
            updateBioLabel(bio: user.tBio)
            
            // set experience
            updateExperience (user)
            
            // set video
            updateVideo(user)
            
            navigationItem.title = user.username
            
            // If a tutor visits an another tutor's profile, hide message and more icons.
            if AccountService.shared.currentUserType == UserType.tutor {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_share"),
                                                                    style: .plain,
                                                                    target: self,
                                                                    action: #selector(handleShareProfileButtonClicked))
            } else {
                navigationItem.rightBarButtonItems = [
                    UIBarButtonItem(image: UIImage(named: "ic_dots_horizontal"), style: .plain, target: self, action: #selector(handleMoreButtonClicked)),
                    UIBarButtonItem(customView: btnSave)
                ]
            }
            
            //Update saved button
            let savedTutorIds = CurrentUser.shared.learner.savedTutorIds
            btnSave.isSelected = savedTutorIds.contains(user.uid)
            
            // Update Recommendations
            updateRecommendataionView()
            
        case .learner:
            topSubjectLabel.superview?.isHidden = true
            ratingLabel.text = "\(String(describing: user.lRating ?? 5.0))"
            addressView.isHidden = false
            addressLabel.text = "United States"
            distanceView.isHidden = true
            experienceLabel.superview?.isHidden = true
            
            updateBioLabel(bio: user.bio)
            btnQuickCall.isHidden = true
            navigationItem.title = user.formattedName
            
            // If a learner visits an another learner's profile, hide message and more icons.
            if AccountService.shared.currentUserType != UserType.learner {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_dots_horizontal"), style: .plain, target: self, action: #selector(handleMoreButtonClicked))
            }
        case .myTutor:
            if subject?.isEmpty ?? true {
                if let featuredSubject = user.featuredSubject, !featuredSubject.isEmpty {
                    topSubjectLabel.text = featuredSubject.capitalizingFirstLetter()
                    subject = featuredSubject
                } else {
                    // Set the first subject
                    subject = user.subjects?.first
                    topSubjectLabel.text = subject?.capitalizingFirstLetter()
                    topSubjectLabel.superview?.isHidden = subject?.isEmpty ?? true
                }
            } else {
                topSubjectLabel.superview?.isHidden = subject?.isEmpty ?? true
                topSubjectLabel.text = subject?.capitalizingFirstLetter()
            }
            ratingLabel.text = "\(String(describing: user.tRating ?? 5.0))"
            lblHourlyRate.text = "$\(user.price ?? 5)/hr"
            addressView.isHidden = false
            addressLabel.text = user.region
            distanceView.isHidden = false
            distanceLabel.text = "1 mile or 0 miles away"
            
            updateMyBioLabel(bio: user.tBio)
            
            // set experience
            updateExperience (user)
            
            // set video
            updateVideo(user)
            
            navigationItem.title = user.username
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(image: UIImage(named: "ic_pencil"),
                                style: .plain,
                                target: self,
                                action: #selector(handleEditProfile)),
                UIBarButtonItem(image: UIImage(named: "ic_share"),
                                style: .plain,
                                target: self,
                                action: #selector(handleShareProfileButtonClicked))
            ]
            
            // Update Recommendations
            updateRecommendataionView()
            
        case .myLearner:
            topSubjectLabel.superview?.isHidden = true
            ratingLabel.text = "\(String(describing: user.lRating ?? 5.0))"
            addressView.isHidden = false
            addressLabel.text = "United States"
            distanceView.isHidden = false
            distanceLabel.text = "1 mile or 0 miles away"
            experienceLabel.superview?.isHidden = true
            
            updateMyBioLabel(bio: user.bio)
            
            navigationItem.title = user.formattedName
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_pencil"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(handleEditProfile))
        }
        lblHourlyRate.superview?.isHidden = .myTutor != profileViewType
        bioLabel.superview?.layoutIfNeeded()
    }
    
    private func initRecommendations() {
        guard .myTutor == profileViewType else { return }
            
        FirebaseData.manager.fetchTutorRecommendations(uid: user.uid) { recommendations in
            self.user.recommendations = recommendations
            self.updateRecommendataionView()
        }
    }
    
    private func updateRecommendataionView() {
        if let recommendations = user.recommendations,
            let firstRecommendation = recommendations.first,
            let firstName = firstRecommendation.learnerName?.split(separator: " ").first {
            viewRecommendations.isHidden = false
            
            if 1 == recommendations.count {
                if user.uid == Auth.auth().currentUser?.uid {
                    lblRecommendedLearners.text = "\(firstName) recommends."
                } else {
                    if firstRecommendation.learnerId == Auth.auth().currentUser?.uid {
                        lblRecommendedLearners.text = "You recommend \(user.firstName ?? "")."
                    } else {
                        lblRecommendedLearners.text = "\(firstName) recommends \(user.firstName ?? "")."
                    }
                }
            } else if 2 == recommendations.count {
                if user.uid == Auth.auth().currentUser?.uid {
                    lblRecommendedLearners.text = "\(firstName) and 1 other recommend."
                } else {
                    if recommendations.contains(where: { $0.learnerId == Auth.auth().currentUser?.uid }),
                        let otherRecommendation = recommendations.first(where: { $0.learnerId != Auth.auth().currentUser?.uid }),
                        let otherFirstName = otherRecommendation.learnerName?.split(separator: " ").first {
                        lblRecommendedLearners.text = "You and \(otherFirstName) recommend \(user.firstName ?? "")."
                    } else {
                        lblRecommendedLearners.text = "\(firstName) and 1 other recommend \(user.firstName ?? "")."
                    }
                }
            } else {
                if user.uid == Auth.auth().currentUser?.uid {
                    lblRecommendedLearners.text = "\(firstName) and \(recommendations.count - 1) others recommend."
                } else {
                    if recommendations.contains(where: { $0.learnerId == Auth.auth().currentUser?.uid }),
                        let otherRecommendation = recommendations.first(where: { $0.learnerId != Auth.auth().currentUser?.uid }),
                        let otherFirstName = otherRecommendation.learnerName?.split(separator: " ").first {
                        lblRecommendedLearners.text = "You, \(otherFirstName) and \(recommendations.count - 2) other\(3 < recommendations.count ? "s" : "") recommend \(user.firstName ?? "")."
                    } else {
                        lblRecommendedLearners.text = "\(firstName) and \(recommendations.count - 1) others recommend \(user.firstName ?? "")."
                    }
                }
            }
            if let avatarUrl = firstRecommendation.learnerAvatarUrl {
                imgRecommendedLearner.sd_setImage(with: URL(string: avatarUrl), placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
            } else {
                imgRecommendedLearner.image = AVATAR_PLACEHOLDER_IMAGE
            }
            lblRecommendedText.text = firstRecommendation.recommendationText
        } else {
            viewRecommendations.isHidden = true
        }
        
        viewWriteRecommend.isHidden = .tutor != profileViewType || .connected != connectionStatus || true == user.recommendations?.contains(where: { $0.learnerId == Auth.auth().currentUser?.uid })
        
        if viewRecommendations.isHidden && viewWriteRecommend.isHidden {
            viewRecommendations.superview?.isHidden = true
        } else {
            viewRecommendations.superview?.isHidden = false
        }
    }
    
    func saveTutor() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = user.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).setValue(1)
        btnSave.isSelected = true
        CurrentUser.shared.learner.savedTutorIds.append(tutorId)
        NotificationCenter.default.post(name: NotificationNames.SavedTutors.didUpdate, object: nil)
    }
    
    func unsaveTutor() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = user.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).removeValue()
        btnSave.isSelected = false
        CurrentUser.shared.learner.savedTutorIds.removeAll(where: { (id) -> Bool in
            return id == tutorId
        })
        NotificationCenter.default.post(name: NotificationNames.SavedTutors.didUpdate, object: nil)
    }
    
    func showSchool(user: AWTutor) {
        if let school = user.school, !school.isEmpty {
            schoolView?.isHidden = false
            schoolLabel?.text = school
            
            if let lines = schoolLabel?.calculateMaxLines() {
                schoolLabelHeightConstraint?.constant = CGFloat(22 * lines)
            }
        } else {
            schoolView?.isHidden = true
        }
    }
    
    func showLanguage(user: AWTutor) {
        if let languages = user.languages, !languages.isEmpty {
            languageView?.isHidden = false
            languageLabel?.text = languages.joined(separator: ", ")
        } else {
            languageView?.isHidden = true
        }
    }
    
    func initSubjects() {
        guard let user = user else { return }
        if profileViewType == .tutor || profileViewType == .myTutor {
            subjectsCollectionView.superview?.isHidden = (user.subjects?.isEmpty ?? true) && (user.featuredSubject?.isEmpty ?? true)
        } else {
            subjectsCollectionView.superview?.isHidden = (user.interests?.isEmpty ?? true)
        }
        subjectsCollectionView.reloadData()
    }
    
    func initReviews() {
        // add shadow
        let shadowView = readReviewsButton.superview?.superview
        shadowView?.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: .zero, radius: 4)
        
        guard let user = user else { return }
        
        readReviewsButton.layer.cornerRadius = 3
        readReviewsButton.clipsToBounds = true
        readReviewsButton.setupTargets()

        if profileViewType == .tutor || profileViewType == .myTutor {
            reviewsTableView.superview?.isHidden = user.reviews?.isEmpty ?? true
            reviewsHeight = getHeightOfReviews(reviews: user.reviews ?? [Review]())
            let numberOfReviews = user.reviews?.count ?? 0
            if numberOfReviews == 0 {
                reviewsStackView.isHidden = true
                ratingView.superview?.isHidden = true
                ratingLabel.superview?.isHidden = true
            } else {
                reviewsStackView.isHidden = false
                ratingView.superview?.isHidden = false
                ratingLabel.superview?.isHidden = false
                readAllReviewLabel.text = "Read all \(numberOfReviews) \(numberOfReviews > 1 ? " reviews" : " review")"
            }
        } else {
            reviewsTableView.superview?.isHidden = user.lReviews?.isEmpty ?? true
            let numberOfReviews = user.lReviews?.count ?? 0
            reviewsHeight = getHeightOfReviews(reviews: user.lReviews ?? [Review]())
            if numberOfReviews == 0 {
                reviewsStackView.isHidden = true
                ratingView.superview?.isHidden = true
            } else {
                reviewsStackView.isHidden = false
                ratingView.superview?.isHidden = false
                ratingLabel.superview?.isHidden = false
                readAllReviewLabel.text = "Read all \(numberOfReviews) \(numberOfReviews > 1 ? " reviews" : " review")"
            }
        }
        
        reviewsTableView.reloadData()
    }
    
    func initPolicies() {
        guard let profileViewType = profileViewType else { return }
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
        guard let user = user, let policy = user.policy else { return }
        let policies = policy.split(separator: "_")
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
        connectButton.layer.cornerRadius = 3
        connectButton.clipsToBounds = true
        connectButton.setupTargets()
        
        connectView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        connectView.layer.shadowOpacity = 1
        connectView.layer.shadowRadius = 2
        connectView.layer.shadowOffset = CGSize(width: 0, height: -2)

        
        guard let profileViewType = profileViewType else { return }
        
        // Update the title of connect button based on the connection status.
        guard let opponentId = user?.uid else { return }
        setupConnectionObserver(opponentId)
        
        switch profileViewType {
        case .tutor:
            // Add an observer to listen quick call status of a tutor
            setupTutorInfoObserver(tutorId: opponentId)
            
            connectView.isHidden = false
            ratingView.rating = user.tRating
            lblBottomHourlyRate.text = "$\(user.price ?? 5)/hr"
            numberOfReviewsLabel.text = "\(user.reviews?.count ?? 0)"
            
            // If a tutor visits an another tutor's profile, hide connect button
            if AccountService.shared.currentUserType == UserType.tutor {
                connectView.isHidden = true
            }
            
            // Disable the connect button until app gets the connection status.
            connectButton.isEnabled = false
            connectButton.setTitle("Connect", for: .normal)
        case .learner,
             .myTutor,
             .myLearner:
            connectView.isHidden = true
            constraintConnectViewBottom.constant = -84
        }
    }
    
    @objc func reloadSubjects(_ notification: Notification) {
        guard profileViewType == .myTutor || profileViewType == .myLearner else { return }
        
        if profileViewType == .myTutor {
            user.subjects = TutorRegistrationService.shared.subjects
        } else if profileViewType == .myLearner {
            user.interests = LearnerRegistrationService.shared.interests
        }
        subjectsCollectionView.reloadData()
    }
    
    func updateSubjectsHeight() {
        subjectsCollectionViewHeight.constant = subjectsCollectionView.contentSize.height
        subjectsCollectionView.layoutIfNeeded()
        scrollView.layoutIfNeeded()
    }
    
    func updateReviewsHeight() {
        reviewsTabeViewHeight.constant = reviewsHeight
        reviewsTableView.layoutIfNeeded()
        scrollView.layoutIfNeeded()
    }
    
    func createLightBoxImages() -> [LightboxImage] {
        var images = [LightboxImage]()
        let imageKeys = user?.images.keys.sorted(by: { $0 < $1 })
        imageKeys?.forEach {
            guard let imageUrl = user?.images[$0], let url = URL(string: imageUrl) else { return }
            images.append(LightboxImage(imageURL: url))
        }
        return images
    }
    
    func presentLightBox(_ images: [LightboxImage]) {
        let controller = LightboxController(images: images, startIndex: 0)
        controller.dynamicBackground = true
        present(controller, animated: true, completion: nil)
    }
    
    func getHeightOfReviews(reviews: [Review]) -> CGFloat {
        let height: CGFloat = 78
        guard let review = reviews.first else { return height }
        
        if review.message.isEmpty {
            return 60
        } else {
            var reviewHeight = review.message.height(withConstrainedWidth: UIScreen.main.bounds.size.width - 40, font: Fonts.createSize(16))
            let onelineHeight = "A".height(withConstrainedWidth: UIScreen.main.bounds.size.width - 40, font: Fonts.createSize(16))
            
            reviewHeight = reviewHeight > onelineHeight * 3 ? onelineHeight * 3 : reviewHeight
            
            return reviewHeight + height
        }
    }
    
    func findDistance(location: TutorLocation?) -> Double {
        guard let tutorLocation = location?.location else {
            return 0
        }
        
        let currentDistance = currentLocation?.distance(from: tutorLocation) ?? 0
        return currentDistance * 0.00062137
    }
    
    func formatDistance(_ distance: Double) -> String {
        if distance > 0 && distance < 2 {
            return "1 mile from you"
        }
        
        var thousand = ""
        var dist = distance
        if distance > 1000 {
            dist /= 1000
            thousand = "k"
        }
        return String(format: "%.1f\(thousand) miles away", locale: Locale.current, dist).replacingOccurrences(of: ".0", with: "")
    }
    
    func updateDistanceLabel() {
        guard let profileViewType = profileViewType else { return }
        if profileViewType == .tutor {
            switch CLLocationManager.authorizationStatus() {
            case .denied, .notDetermined, .restricted:
                distanceView.isHidden = true
            case .authorizedAlways, .authorizedWhenInUse:
                let distance = findDistance(location: user.location)
                distanceLabel.text = formatDistance(distance)
                if distance > 0 {
                    distanceView.isHidden = false
                }
            default: break
            }
        }
    }
    
    func updateBioLabel(bio: String?) {
        if let bio = bio, !bio.isEmpty {
            bioLabel.text = "\(bio)"
        } else {
            bioLabel.text = "\(user.formattedName) has not yet entered a biography."
        }
    }
    
    func updateMyBioLabel(bio: String?) {
        if let bio = bio, !bio.isEmpty {
            bioLabel.text = "\(bio.trimmingCharacters(in: .whitespacesAndNewlines))"
        } else {
            bioLabel.text = "No biography yet! You can add a bio by tapping \"edit\" in the top right of the screen."
        }
    }
    
    func updateExperience (_ tutor: AWTutor) {
        experienceLabel.superview?.isHidden = false
        guard let subject = tutor.experienceSubject, !subject.isEmpty else {
            experienceLabel.superview?.isHidden = true
            return
        }
        
        if let period = tutor.experiencePeriod, period >= 1 {
            experienceLabel.text = "\(Int(period)) Years Experience in \(subject)"
        } else {
            experienceLabel.text = "6 mo Experience in \(subject)"
        }
    }
    
    func updateVideo (_ tutor: AWTutor) {
        videoCollectionView.superview?.isHidden = false
        guard let videos = tutor.videos, !videos.isEmpty else {
            videoCollectionView.superview?.isHidden = true
            return
        }
        self.videos = videos
        videoCollectionView.delegate = self
        videoCollectionView.dataSource = self
        videoCollectionView.register(QTProfileVideoCollectionViewCell.nib, forCellWithReuseIdentifier: QTProfileVideoCollectionViewCell.reuseIdentifier)
        videoCollectionView.reloadData()
    }
    
    func setupConnectionObserver(_ opponentId: String?) {
        guard let id = opponentId else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let currentUserType = AccountService.shared.currentUserType.rawValue
        connectionRef = Database.database().reference()
            .child("connections")
            .child(uid)
            .child(currentUserType)
            .child(id)
        guard let connectionRef = connectionRef else { return }
        connectionHandle = connectionRef.observe(.value) { snapshot in
            guard let connected = snapshot.value as? Bool else {
                self.checkConnectionRequestStatus(userId: uid,
                                                  userType: currentUserType,
                                                  partnerId: id,
                                                  completion: { connectionStatus in
                                                    // Enable the connect button
                                                    self.connectButton.isEnabled = true
                                                    if connectionStatus == "pending" {
                                                        self.connectionStatus = .pending
                                                        self.connectButton.setTitle("Request Pending", for: .normal)
                                                    } else {
                                                        self.connectionStatus = .none
                                                        self.connectButton.setTitle("Connect", for: .normal)
                                                    }
                })
                return
            }
            // Enable the connect button
            self.connectButton.isEnabled = true
            if connected {
                self.connectionStatus = .connected
                if .tutor == self.profileViewType {
                    self.btnQuickCall.superview?.superview?.isHidden = false
                }
                self.connectButton.setTitle("Schedule Now", for: .normal)
            } else {
                self.btnQuickCall.superview?.superview?.isHidden = true
                self.checkConnectionRequestStatus(userId: uid,
                                                  userType: currentUserType,
                                                  partnerId: id,
                                                  completion: { connectionStatus in
                                                    // Enable the connect button
                                                    self.connectButton.isEnabled = true
                                                    if connectionStatus == "pending" {
                                                        self.connectionStatus = .pending
                                                        self.connectButton.setTitle("Request Pending", for: .normal)
                                                    } else {
                                                        self.connectionStatus = .none
                                                        self.connectButton.setTitle("Connect", for: .normal)
                                                    }
                })
            }
            
            if .tutor == self.profileViewType || .myTutor == self.profileViewType {
                self.updateRecommendataionView()
            }
        }
    }
    
    func checkConnectionRequestStatus(userId: String, userType: String, partnerId: String, completion: ((String) -> ())?) {
        
        Database.database().reference()
            .child("conversations")
            .child(userId)
            .child(userType)
            .child(partnerId)
            .queryLimited(toLast: 1)
            .observeSingleEvent(of: .value, with: { snapshot1 in
                guard let children = snapshot1.children.allObjects as? [DataSnapshot], let child = children.first else {
                    if let completion = completion {
                        completion("")
                    }
                    return
                }
                
                MessageService.shared.getMessageById(child.key
                    , completion: { message in
                        guard let requestId = message.connectionRequestId, message.type == .connectionRequest else {
                            if let completion = completion {
                                completion("")
                            }
                            return
                        }
                        
                        // Check connection request.
                        Database.database().reference().child("connectionRequests").child(requestId).observeSingleEvent(of: .value) { snapshot in
                            guard let value = snapshot.value as? [String: Any] else {
                                if let completion = completion {
                                    completion("")
                                }
                                return
                            }
                            guard let status = value["status"] as? String else {
                                if let completion = completion {
                                    completion("")
                                }
                                return
                            }
                            
                            if let completion = completion {
                                completion(status)
                            }
                        }
                })
                
            })
    }
    
    func setupTutorInfoObserver(tutorId: String) {
        tutorInfoRef = Database.database().reference().child("tutor-info").child(tutorId)
        tutorInfoHandle = tutorInfoRef?.observe(.childChanged, with: { (snapshot) in
            if snapshot.exists() == false {
                return
            }
            
            guard snapshot.key.compare("quick_calls") == ComparisonResult.orderedSame, let value = snapshot.value else {
                return
            }
            
            if let quickCallPrice = value as? Int,
                -1 != quickCallPrice {
                self.user.quickCallPrice = quickCallPrice
                self.btnQuickCall.isHidden = false
            } else {
                self.user.quickCallPrice = -1
                self.btnQuickCall.isHidden = true
            }
        })
    }
    
    private func setupSharedProfileView() {
        
        // Get tutor info
        FirebaseData.manager.fetchTutor(user.uid, isQuery: false) { (tutor) in
            guard let tutor = tutor else { return }
            self.view.insertSubview(self.sharedProfileView, at: 0)
            self.sharedProfileView.translatesAutoresizingMaskIntoConstraints = false
            self.sharedProfileView.anchor(top: self.view.topAnchor,
                                          left: self.view.leftAnchor,
                                          bottom: nil,
                                          right: self.view.rightAnchor,
                                          paddingTop: 0,
                                          paddingLeft: 0,
                                          paddingBottom: 0,
                                          paddingRight: 0,
                                          width: 0,
                                          height: 0)
            self.sharedProfileView.setProfile(withTutor: tutor)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension QTProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == videoCollectionView,
            (profileViewType == .tutor || profileViewType == .myTutor) {
            if let videoUrl = videos[indexPath.item].videoUrl {
                let player = AVPlayer(url: URL(string: videoUrl)!)
                let vc = QTChatVideoPlayerViewController()//AVPlayerViewController()
                vc.videoUrl = URL(string: videoUrl)!
                vc.player = player
                present(vc, animated: true) {
                    vc.player?.play()
                }
            }
        }
    }
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
        
        if profileViewType == .tutor || profileViewType == .myTutor {
            if collectionView == videoCollectionView {
                let width = collectionView.frame.width
                let height = collectionView.frame.height
                if videos.count == 1 {
                    return CGSize(width: width - 40, height: height)
                } else {
                    return CGSize(width: width / 2, height: height)
                }
            } else {
                if let subjects = user.subjects {
                    width = subjects[indexPath.item].estimateFrameForFontSize(14, extendedWidth: true).width + 20
                } else if let featuredSubject = user.featuredSubject {
                    width = featuredSubject.estimateFrameForFontSize(14, extendedWidth: true).width + 20
                }
            }
        } else if profileViewType == .myLearner || profileViewType == .learner {
            if let interests = user.interests {
                width = interests[indexPath.item].estimateFrameForFontSize(14, extendedWidth: true).width + 20
            }
        }
        return CGSize(width: width, height: 30)
    }
}

// MARK: - UICollectionViewDataSource
extension QTProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if profileViewType == .tutor || profileViewType == .myTutor {
            if collectionView == videoCollectionView {
                return videos.count
            } else {
                if let subjects = user.subjects, subjects.count > 0 {
                    return subjects.count
                } else if let featuredSubject = user.featuredSubject, !featuredSubject.isEmpty {
                    return 1
                }
            }
        } else if profileViewType == .myLearner || profileViewType == .learner {
            if let interests = user.interests, interests.count > 0 {
                return interests.count
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == videoCollectionView, (profileViewType == .tutor || profileViewType == .myTutor) {
            let cell = videoCollectionView.dequeueReusableCell(withReuseIdentifier: QTProfileVideoCollectionViewCell.reuseIdentifier, for: indexPath) as! QTProfileVideoCollectionViewCell
            cell.setData(video: videos[indexPath.item], isEditMode: false)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PillCollectionViewCell.reuseIdentifier, for: indexPath) as! PillCollectionViewCell
            if profileViewType == .tutor || profileViewType == .myTutor {
                if let subjects = user.subjects {
                    cell.titleLabel.text = subjects[indexPath.item]
                } else if let featuredSubject = user.featuredSubject, !featuredSubject.isEmpty {
                    cell.titleLabel.text = featuredSubject
                }
            } else if profileViewType == .myLearner || profileViewType == .learner {
                if let interests = user.interests {
                    cell.titleLabel.text = interests[indexPath.item]
                }
            }
            
            updateSubjectsHeight()
            return cell
        }
    }
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
        cell.reviewLabel.numberOfLines = 3
        if let reviews = profileViewType == .tutor || profileViewType == .myTutor ? user.reviews : user.lReviews {
            cell.setData(review: reviews[indexPath.row])
        }
        self.updateReviewsHeight()
        
        return cell
    }
}

// MARK: - LearnerWasUpdatedCallBack
extension QTProfileViewController: LearnerWasUpdatedCallBack {
    func learnerWasUpdated(learner: AWLearner!) {
        
    }
    
}
        
// MARK: - QTProfileDelegate
extension QTProfileViewController: QTProfileDelegate {
    func didUpdateLearnerProfile(learner: AWLearner) {
        user = AWTutor(dictionary: [:]).copy(learner: learner)
        if profileViewType == .myTutor {
            user.subjects = TutorRegistrationService.shared.subjects
            user.featuredSubject = TutorRegistrationService.shared.featuredSubject
        } else if profileViewType == .myLearner {
            user.interests = LearnerRegistrationService.shared.interests
        }
        initUserInfo()
    }
    
    func didUpdateTutorProfile(tutor: AWTutor) {
        self.user = tutor
        self.subject = nil
        if profileViewType == .myTutor {
            user.subjects = TutorRegistrationService.shared.subjects
            user.featuredSubject = TutorRegistrationService.shared.featuredSubject
        } else if profileViewType == .myLearner {
            user.interests = LearnerRegistrationService.shared.interests
        }
        initUserInfo()
    }
}

extension QTProfileViewController: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
            updateDistanceLabel()
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
