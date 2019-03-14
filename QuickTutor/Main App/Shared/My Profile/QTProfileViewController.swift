//
//  QTProfileViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 3/13/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTProfileViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var moreButtonsView: UIView!
    @IBOutlet weak var statusImageView: QTCustomImageView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var ratingStarImageView: UIImageView!
    @IBOutlet weak var topSubjectLabel: UILabel!
    @IBOutlet weak var tutoringInfoStackView: UIStackView!
    @IBOutlet weak var numberOfLearnersLabel: UILabel!
    @IBOutlet weak var numberOfSessionsLabel: UILabel!
    @IBOutlet weak var numberOfSubjectsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
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
    
    static func loadView() -> QTProfileViewController {
        return QTProfileViewController(nibName: String(describing: QTProfileViewController.self), bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ratingView.setupViews()
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
    
}
