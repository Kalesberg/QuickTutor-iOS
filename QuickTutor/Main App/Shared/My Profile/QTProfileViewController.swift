//
//  QTProfileViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 3/13/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseStorage

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
    @IBOutlet weak var latePolicyLabel: UILabel!
    @IBOutlet weak var lateFeeLabel: UILabel!
    @IBOutlet weak var cancellationPolicyLabel: UILabel!
    @IBOutlet weak var cancellationFeeLabel: UILabel!
    @IBOutlet weak var connectView: UIView!
    @IBOutlet weak var ratingView: QTRatingView!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var rateLabel: UILabel!
    
    static var controller: QTProfileViewController {
        return QTProfileViewController(nibName: String(describing: QTProfileViewController.self), bundle: nil)
    }
    
    var user: AWTutor!
    var profileViewType: QTProfileViewType!
    
    let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegates()
        initData()
    }

    // MARK: - Actions
    @IBAction func onMessageButtonClicked(_ sender: Any) {
        
    }
    
    @IBAction func onMoreButtonClicked(_ sender: Any) {
        
    }
    
    @IBAction func onReadFeedbacksButtonClicked(_ sender: Any) {
    }
    
    @IBAction func onConnectButtonClicked(_ sender: Any) {
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
        subjectsCollectionView.contentSize = CGSize.zero
    }
    
    func initData() {
        
        ratingView.setupViews()
        
        distanceLabel.layer.cornerRadius = 3
        distanceLabel.clipsToBounds = true
        
        connectButton.layer.cornerRadius = 3
        connectButton.clipsToBounds = true
        
        guard let user = user, let profileViewType = profileViewType else { return }
        
        subjectsCollectionView.isHidden = user.subjects?.isEmpty ?? true
        
        let reference = storageRef.child("student-info").child(user.uid).child("student-profile-pic1")
        avatarImageView.sd_setImage(with: reference)
        usernameLabel.text = user.formattedName
        
        switch profileViewType {
        case .tutor:
            moreButtonsView.isHidden = false
            statisticStackView.isHidden = false
            ratingStarImageView.isHidden = true
            topSubjectLabel.text = user.featuredSubject
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
            bioLabel.text = user.tBio
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
        case .myTutor:
            moreButtonsView.isHidden = true
            statisticStackView.isHidden = true
            ratingStarImageView.isHidden = true
            topSubjectLabel.text = user.topSubject
            addressView.isHidden = false
            distanceView.isHidden = true
            if let bio = user.tBio, !bio.isEmpty {
                bioLabel.text = "\(bio)"
            } else {
                bioLabel.text = "No biography yet! You can add a bio by tapping \"edit\" in the top right of the screen."
            }
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
        }
        
        addressLabel.text = user.region
        if let distance = user.distance {
            distanceLabel.text = distance == 1 ? "\(distance) mile from you" : "\(distance) miles from you"
        } else {
            distanceLabel.text = "\(0) miles from you"
        }
        
        updateUI()
    }
    
    func updateUI() {
        subjectsCollectionViewHeight.constant = subjectsCollectionView.contentSize.height
        scrollView.layoutIfNeeded()
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
            cell.titleLabel.text = subjects[indexPath.item]
        }
        updateUI()
        return cell
    }
}
