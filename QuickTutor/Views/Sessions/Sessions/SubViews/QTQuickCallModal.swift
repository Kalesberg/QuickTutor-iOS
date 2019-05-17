//
//  QTQuickCallModal.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 5/15/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTQuickCallModal: BaseModalXibView {

    // MARK: - Properties
    @IBOutlet weak var avatarImageView: QTCustomImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var hangUpButton: QTCustomButton!
    @IBOutlet weak var pickUpButton: QTCustomButton!
    
    // Parameters
    
    static var view: QTQuickCallModal {
        return Bundle.main.loadNibNamed(String(describing: QTQuickCallModal.self),
                                        owner: nil,
                                        options: [:])?.first
        as! QTQuickCallModal
    }
    
    var didHangUpButtonClicked: (() -> ())?
    var didPickUpButtonClicked: (() -> ())?
    var initiatorId: String? {
        didSet {
            if let initiatorId = initiatorId {
                pickUpButton.isHidden = AccountService.shared.currentUser.uid == initiatorId
            }
        }
    }
    // MARK: - Lifecycle
    
    // MARK: - Actions
    @IBAction func onHangUpButtonClicked(_ sender: Any) {
        if let didHangUpButtonClicked = didHangUpButtonClicked {
            didHangUpButtonClicked()
        }
    }
    
    @IBAction func onPickUpButtonClicked(_ sender: Any) {
        if let didPickUpButtonClicked = didPickUpButtonClicked {
            didPickUpButtonClicked()
        }
    }
    
    // MARK: - Functions
    func setData(initiatorId: String,
                 partnerName: String,
                 partnerProfilePicture: URL,
                 subject: String,
                 price: Double) {
        usernameLabel.text = partnerName
        if initiatorId == AccountService.shared.currentUser.uid {
            reasonLabel.text = "\(price.currencyFormat(precision: 2, divider: 1)) for \(subject.capitalized)..."
        } else {
            reasonLabel.text = "is calling you for \(subject.capitalized)..."
        }
        
        avatarImageView.sd_setImage(with: partnerProfilePicture)
    }
}


