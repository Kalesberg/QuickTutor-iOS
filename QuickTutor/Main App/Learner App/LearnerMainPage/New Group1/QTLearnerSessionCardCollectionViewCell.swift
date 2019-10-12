//
//  QTLearnerSessionCardCollectionViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/25/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Cosmos
import FirebaseAuth
import FirebaseDatabase

class QTLearnerSessionCardCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarImageView: QTCustomImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var ratingSeparatorView: QTCustomView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sessionTypeImageView: UIImageView!
    @IBOutlet weak var sessionTypeLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var actionButton: QTCustomButton!
    @IBOutlet weak var sessionTypeLabelBottom: NSLayoutConstraint!
    @IBOutlet weak var ratingStackViewBottom: NSLayoutConstraint!
    
    static var reuseIdentifier: String {
        return String(describing: QTLearnerSessionCardCollectionViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    var sessionStatusType: QTSessionStatusType!
    var session: Session!
    var timer: Timer?
    var tutor: AWTutor?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        configureViews()
    }
    
    // MARK: - Actions
    @IBAction func OnRepeatSessionButtonClicked(_ sender: Any) {
        
        guard let partnerId = session.partnerId() else {
            return
        }
        
        if self.sessionStatusType == QTSessionStatusType.completed {
            // If users click repeat session button, will go to request session screen.
            NotificationCenter.default.post(name: NotificationNames.LearnerMainFeed.requestSession,
                                            object: nil,
                                            userInfo: ["uid": partnerId])
        } else {
            // If users click start early button, will start to session
            NotificationManager.shared.disableAllNotifications()
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let value = ["startedBy": uid, "startType": "manual", "sessionType": session.type]
            Database.database().reference().child("sessionStarts").child(uid).child(session.id).setValue(value)
            Database.database().reference().child("sessionStarts").child(partnerId).child(session.id).setValue(value)
        }
    }
    
    @objc
    func handleUpdateSessionStatus() {
        if self.sessionStatusType == .accepted {
            if self.session.isNeededToStartNow() {
                actionButton.setTitle("Start now", for: .normal)
            } else {
                actionButton.setTitle("Start early", for: .normal)
            }
        }
    }
    
    // MARK: - Functions
    func configureViews() {
        containerView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: .zero, radius: 5)
        containerView.layer.cornerRadius = 5
        
        self.isSkeletonable = true
        containerView.isSkeletonable = true
        avatarImageView.isSkeletonable = true
        nameLabel.isSkeletonable = true
        nameLabel.linesCornerRadius = 5
        subjectLabel.isSkeletonable = true
        subjectLabel.linesCornerRadius = 5
        durationLabel.isSkeletonable = true
        durationLabel.linesCornerRadius = 5
        experienceLabel.isSkeletonable = true
        experienceLabel.linesCornerRadius = 5
        experienceLabel.superview?.isSkeletonable = true
        actionButton.isSkeletonable = true
        
        ratingSeparatorView.isHidden = true
        priceLabel.isHidden = true
        sessionTypeImageView.isHidden = true
        sessionTypeLabel.isHidden = true
        ratingView.isHidden = true
    }
    
    func setData(session: Session) {
        self.session = session
        self.sessionStatusType = QTSessionStatusType(rawValue: session.status)
        
        if tutor == nil {
            getTutor()
        } else {
            updateUI()
        }
    }
    
    func getTutor() {
        guard let partnerId = session.partnerId() else {
            self.updateUI()
            return
        }
        showSkeleton(usingColor: Colors.gray)
        UserFetchService.shared.getTutorWithId(uid: partnerId) { tutor in
            self.tutor = tutor
            self.updateUI()
        }
    }
    
    func updateUI() {
        
        if isSkeletonActive {
            hideSkeleton(transition: .crossDissolve(0.1))
        }
        
        if let username = tutor?.formattedName.capitalized, let profilePicUrl = tutor?.profilePicUrl {
            self.nameLabel.text = username
            self.avatarImageView.sd_setImage(with: profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
        }
        
        updateRatingLabel()
        
        subjectLabel.text = session.subject
        if session.type == "online" {
            sessionTypeLabel.text = "Video Session"
        } else {
            sessionTypeLabel.text = "InPerson Session"
        }
        
        sessionTypeImageView.image = session.type == "online" ? #imageLiteral(resourceName: "videoCameraIcon") : #imageLiteral(resourceName: "inPersonIcon")
        updateDurationAndPriceLabel()
        
        if self.sessionStatusType == QTSessionStatusType.completed {
            if session.type == QTSessionType.quickCalls.rawValue {
                actionButton.setTitle("Call Again", for: .normal)
            } else {
                actionButton.setTitle("Reschedule Session", for: .normal)
            }
        } else { // it will be upcomming session.
            actionButton.setTitle("Start early", for: .normal)
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleUpdateSessionStatus), userInfo: nil, repeats: false)
        
        ratingSeparatorView.isHidden = false
        priceLabel.isHidden = false
        sessionTypeImageView.isHidden = false
        sessionTypeLabel.isHidden = false
        actionButton.isHidden = false
    }
    
    func updateRatingLabel() {
        
        if let rating = tutor?.tRating, rating > 0 {
            ratingView.isHidden = false
            ratingView.rating = rating
            experienceLabel.isHidden = true
            sessionTypeLabelBottom.constant = 148
        } else {
            ratingView.isHidden = true
            experienceLabel.isHidden = false
            sessionTypeLabelBottom.constant = 22
            if let experienceSubject = tutor?.experienceSubject, let experiencePeriod = tutor?.experiencePeriod, !experienceSubject.isEmpty {
                if experiencePeriod == 0.5 {
                    experienceLabel.text = "6 Months Exp in \(experienceSubject)"
                } else {
                    experienceLabel.text = "\(Int(experiencePeriod)) Years Exp in \(experienceSubject)"
                }
            } else if let address = tutor?.region {
                experienceLabel.text = address
            }
        }
    }
    
    func updateDurationAndPriceLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, h:mm a"
        
        let startTime = Date(timeIntervalSince1970: session.startTime)
        let startTimeString = dateFormatter.string(from: startTime)
        
        dateFormatter.dateFormat = "h:mm a"
        let endTime = Date(timeIntervalSince1970: session.endTime)
        let endTimeString = dateFormatter.string(from: endTime)
        
        let timeString = "\(startTimeString) - \(endTimeString)"
        self.durationLabel.text = timeString
        
        var formattedPrice = ""
        if sessionStatusType == .completed {
            formattedPrice = String(format: "%.2f", session.sessionCost)
        } else {
            formattedPrice = String(format: "%.2f", session.sessionPrice)
        }
        
        self.priceLabel.text = "$\(formattedPrice)"
    }
}
