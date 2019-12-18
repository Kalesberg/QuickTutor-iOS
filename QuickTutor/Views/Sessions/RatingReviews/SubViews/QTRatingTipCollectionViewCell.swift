//
//  QTRatingTipCollectionViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 2/26/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseStorage
import BetterSegmentedControl
import Stripe

class QTRatingTipCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hourlyRateLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var ratingNumberLabel: UILabel!
    @IBOutlet weak var tutorCostTitleLabel: UILabel!
    @IBOutlet weak var tutorCostLabel: UILabel!
    @IBOutlet weak var processingFeeLabel: UILabel!
    @IBOutlet weak var tutorTipLabel: UILabel!
    @IBOutlet weak var tipSegmentControl: BetterSegmentedControl!
    
    @IBOutlet weak var brandImageView: UIImageView!
    @IBOutlet weak var cardInfoLabel: UILabel!
    
    
    var isPayWithoutTip = false
    var tip: Double = 0//5
    var costOfSession: Double = 0.0
    var didSelectTip: ((Double, Double) ->())?
    var didSelectPayment: (() ->())?
    var didSelectCustomTip: (() ->())?
    
    struct Dimension {
        let avatarWidth = 180
        let avatarHeight = 160
        let avatarMinHeight = 100
        let tipTextFieldHeight = 50
        let profileInfoHeight = 65
        let tipCheckStackViewTop = 30
        let tipCheckStackViewHeight = 40
    }
    
    var dimension: Dimension = Dimension()
    
    let storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
    
    static var reuseIdentifier: String {
        return String(describing: QTRatingTipCollectionViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTRatingTipCollectionViewCell.self), bundle: nil)
    }
    
    let maxTip: Double = 250
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Event Handlers
    @IBAction func onSelectTip(_ sender: Any) {
        
        if tipSegmentControl.index == 4 {
            didSelectCustomTip?()
            return
        }
        
        switch tipSegmentControl.index {
        case 0:
            self.tip = 0.0
        case 1:
            self.tip = self.costOfSession * 0.1
        case 2:
            self.tip = self.costOfSession * 0.15
        default:
            self.tip = self.costOfSession * 0.2
        }
        
        self.updateTipAmount()
    }
    
    @IBAction func onClickSelectPayment(_ sender: Any) {
        didSelectPayment?()
    }
    
    
    public func setProfileInfo(user: Any, subject: String?, costOfSession: Double, sessionType: QTSessionType) {
        scrollView.contentSize.width = UIScreen.main.bounds.width
        
        // tip segment control
        tipSegmentControl.segments = LabelSegment.segments(withTitles: ["No tip", "10%", "15%", "20%", "Custom"],
                                                           normalFont: Fonts.createSemiBoldSize(17.0),
                                                           normalTextColor: .white,
                                                           selectedFont: Fonts.createSemiBoldSize(17.0),
                                                           selectedTextColor: .white)
        tipSegmentControl.setIndex(3, animated: false)
        
        
        guard let tutor = user as? AWTutor else { return }
        
        let nameSplit = tutor.name.split(separator: " ")
        nameLabel.text = String(nameSplit[0]) + " " + String(nameSplit[1].prefix(1) + ".")
        avatarImageView.sd_setImage(with: tutor.profilePicUrl, placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
        if let rating = tutor.tRating {
            setProfileRating(Int(rating))
        }
        
        if let subject = subject {
            subjectLabel.text = subject
        }
        if let hourlyRate = tutor.price {
            hourlyRateLabel.text = "$\(hourlyRate)/hr"
            hourlyRateLabel.isHidden = false
        } else {
            hourlyRateLabel.isHidden = true
        }
        
        // real cost
        self.costOfSession = costOfSession
        
        // tip
        tip = costOfSession * 0.15
        tutorTipLabel.text = tip.currencyFormat(precision: 2, divider: 1)
        
        // processing fee
        let cost = costOfSession + tip
        let costWithFee = (cost + 0.57) / 0.968
        processingFeeLabel.text = (costWithFee - cost).currencyFormat(precision: 2, divider: 1)
        
        // tutor cost
        tutorCostTitleLabel.text = sessionType == .quickCalls ? "Call cost:" : "Session cost:"
        tutorCostLabel.text = costOfSession.currencyFormat(precision: 2, divider: 1)//costWithFee.currencyFormat(precision: 2, divider: 1)
        
        // did select tip
        didSelectTip?(tip, costWithFee)
    }
    
    private func setProfileRating(_ rating: Int) {
        ratingNumberLabel.text = String(format: "%.1f", Float(rating))
    }
    
    private func updateTipAmount () {
        // tip
        tutorTipLabel.text = tip.currencyFormat(precision: 2, divider: 1)
        
        //processing fee
        let cost = costOfSession + tip
        let costWithFee = (cost + 0.57) / 0.968
        processingFeeLabel.text = (costWithFee - cost).currencyFormat(precision: 2, divider: 1)
        
        // did select tip
        didSelectTip?(tip, costWithFee)
    }
    
    // MARK: - Payment Handlers
    func setPayment (defaultCard: STPCard?) {
        guard let card = defaultCard else {
            if Stripe.deviceSupportsApplePay() {
                brandImageView.image = STPApplePayPaymentOption().image
                cardInfoLabel.text = "Apple Pay"
            }
            return
        }
        
        brandImageView.image = STPImageLibrary.brandImage(for: card.brand)
        cardInfoLabel.text = "•••• \(card.last4)"
    }
}

extension QTRatingTipCollectionViewCell: QTRatingReviewCustomTipViewControllerDelegate {
    func viewController(_ viewController: QTRatingReviewCustomTipViewController, didSelectCustomTip tip: Double) {
        self.tip = tip
        updateTipAmount()
    }
    
    func viewController (didDismiss: QTRatingReviewCustomTipViewController) {
        tipSegmentControl.setIndex(3, animated: false)
    }
}
