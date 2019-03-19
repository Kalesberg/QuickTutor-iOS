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
    @IBOutlet weak var hourlyRateLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var sessionLengthLabel: UILabel!
    @IBOutlet weak var billLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
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
        receiptView.clipsToBounds = true
    }
    
    public func setProfileInfo(user: Any,
                               subject: String,
                               bill: Double,
                               tip: Int,
                               sessionDuration: Int,
                               partnerSessionNumber: Int) {
        
        scrollView.contentSize.width = UIScreen.main.bounds.width
        
        if let tutor = user as? AWTutor {
            let nameSplit = tutor.name.split(separator: " ")
            nameLabel.text = String(nameSplit[0]) + " " + String(nameSplit[1].prefix(1) + ".")
            avatarImageView.sd_setImage(with: storageRef.child("student-info").child(tutor.uid).child("student-profile-pic1"))
            
            if let hourlyRate = tutor.price {
                hourlyRateLabel.text = "$\(hourlyRate)/hr"
                hourlyRateLabel.isHidden = false
            }
            partnerSessionLabel.text = "Sessions completed with \(String(nameSplit[0]) + " " + String(nameSplit[1].prefix(1))):"
        } else if let learner = user as? AWLearner {
            let nameSplit = learner.name.split(separator: " ")
            nameLabel.text = String(nameSplit[0]) + " " + String(nameSplit[1].prefix(1) + ".")
            avatarImageView.sd_setImage(with: storageRef.child("student-info").child(learner.uid).child("student-profile-pic1"))
            
            if let hourlyRate = CurrentUser.shared.tutor.price {
                hourlyRateLabel.text = "$\(hourlyRate)/h"
                hourlyRateLabel.isHidden = false
            }
            partnerSessionLabel.text = "Sessions completed with \(String(nameSplit[0]) + " " + String(nameSplit[1].prefix(1))):"
        }
        
        subjectLabel.text = subject
        sessionLengthLabel.text = getFormattedTimeString(seconds: sessionDuration)
        billLabel.text = bill.currencyFormat(precision: 2, divider: 1)
        tipLabel.text = "$\(tip)"
        totalLabel.text = (bill + Double(tip)).currencyFormat(precision: 2, divider: 1)
        
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
}
