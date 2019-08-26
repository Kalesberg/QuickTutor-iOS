//
//  QTRatingReceiptCollectionViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 2/26/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseStorage

class QTRatingReceiptCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var receiptView: UIView!
    @IBOutlet weak var avatarImageView: QTCustomImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var sessionLengthCaptionLabel: UILabel!
    @IBOutlet weak var sessionLengthLabel: UILabel!
    @IBOutlet weak var tutoringCostView: UIView!
    @IBOutlet weak var tutoringCostLabel: UILabel!
    @IBOutlet weak var processingFeeTitleLabel: UILabel!
    @IBOutlet weak var processingFeeLabel: UILabel!
    @IBOutlet weak var billLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalSessionNumberLabel: UILabel!
    @IBOutlet weak var partnerSessionLabel: UILabel!
    @IBOutlet weak var partnerSessionNumberLabel: UILabel!
    
    let storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
    
    static var reuseIdentifier: String {
        return String(describing: QTRatingReceiptCollectionViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTRatingReceiptCollectionViewCell.self), bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        receiptView.layer.cornerRadius = 5
        addDropShadow()
    }
    
    public func setProfileInfo(user: Any,
                               subject: String,
                               bill: Double,
                               fee: Int,
                               tip: Double,
                               sessionDuration: Int,
                               partnerSessionNumber: Int,
                               sessionType: QTSessionType) {
        
        scrollView.contentSize.width = UIScreen.main.bounds.width
        
        if let tutor = user as? AWTutor {
            let nameSplit = tutor.name.split(separator: " ")
            avatarImageView.sd_setImage(with: tutor.profilePicUrl, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
            
            updateLabelsWith(sessionType: sessionType, nameSplit: nameSplit)
            
            tutoringCostLabel.text = bill.currencyFormat(precision: 2, divider: 1)
            
            let cost = (bill + tip + 0.3) / 0.971
            processingFeeLabel.text = Double(cost * 0.029 + 0.3).currencyFormat(precision: 2, divider: 1)
            billLabel.text = (cost - tip).currencyFormat(precision: 2, divider: 1)
            totalLabel.text = cost.currencyFormat(precision: 2, divider: 1)
        } else if let learner = user as? AWLearner {
            let nameSplit = learner.name.split(separator: " ")
            avatarImageView.sd_setImage(with: learner.profilePicUrl, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
            
            processingFeeTitleLabel.text = "QuickTutor's service fee:"
            
            updateLabelsWith(sessionType: sessionType, nameSplit: nameSplit)
            
            let processingFee = Double(fee)
            processingFeeLabel.text = processingFee.currencyFormat(precision: 2)
            
            billLabel.text = bill.currencyFormat(precision: 2, divider: 1)
            
            totalTitleLabel.text = "Earned"
            let earnings = (bill - (processingFee / 100))
            totalLabel.text = earnings.currencyFormat(precision: 2, divider: 1)
            
            // hidden tutoring cost
            tutoringCostView?.isHidden = true
            // hidden tip
            tipLabel.superview?.superview?.superview?.isHidden = true
        }
        subjectLabel.text = subject
        sessionLengthLabel.text = getFormattedTimeString(seconds: sessionDuration)
        
        tipLabel.text = tip.currencyFormat(precision: 2, divider: 1)
        totalSessionNumberLabel.text = AccountService.shared.currentUserType == .learner ?
            "\(CurrentUser.shared.learner.lNumSessions + 1)" : "\(CurrentUser.shared.tutor.tNumSessions + 1)"
        partnerSessionNumberLabel.text = "\(partnerSessionNumber + 1)"
    }

    func getFormattedTimeString (seconds : Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        
        if hours > 0 {
            return "\(hours) hours and \(minutes) minutes"
        } else if minutes > 0 {
            return "\(minutes) minutes and \(seconds) seconds"
        } else {
            return "\(seconds) seconds"
        }
    }
    
    func updateLabelsWith(sessionType: QTSessionType, nameSplit: [String.SubSequence]) {
        nameLabel.text = String(nameSplit[0]) + " " + String(nameSplit[1].prefix(1) + ".")
        
        if sessionType == .quickCalls {
            partnerSessionLabel.text = "Call completed with \(String(nameSplit[0]) + " " + String(nameSplit[1].prefix(1))):"
            sessionLengthCaptionLabel.text = "Call duration:"
        } else {
            partnerSessionLabel.text = "Sessions completed with \(String(nameSplit[0]) + " " + String(nameSplit[1].prefix(1))):"
            sessionLengthCaptionLabel.text = "Session duration:"
        }
    }
    
    func addDropShadow() {
        receiptView?.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.6, offset: CGSize(width: 0, height: 0), radius: 6)
    }
}
