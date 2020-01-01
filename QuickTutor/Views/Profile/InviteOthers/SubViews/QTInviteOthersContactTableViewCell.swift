//
//  QTInviteOthersContactTableViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 4/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Contacts

class QTInviteOthersContactTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var avatarInitialsLabel: UILabel!
    @IBOutlet weak var avatarImageView: QTCustomImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var checkView: QTCustomView!
    @IBOutlet weak var checkImageView: QTCustomImageView!
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTInviteOthersContactTableViewCell.self), bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTInviteOthersContactTableViewCell.self)
    }
    
    var didClickCheckButton: ((Bool) -> ())?
    var checked = false
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        checkView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(handleCheckViewTap)))
        checkView.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        avatarImageView.image = UIImage(named: "profileTabBarIcon")
        checkImageView.isHighlighted = false
    }
    
    // MARK: - Actions
    @objc
    func handleCheckViewTap() {
        if let didClickCheckButton = didClickCheckButton {
            checked = !checked
            didClickCheckButton(checked)
        }
    }
    
    // MARK: - Functions
    public func setData(_ contact: CNContact, checked: Bool) {
        userNameLabel.text = contact.givenName + " " + contact.familyName
        if let imageData = contact.imageData {
            avatarInitialsLabel.text = ""
            avatarImageView.isHighlighted = true
            avatarImageView.image = UIImage(data: imageData)
        } else {
            avatarInitialsLabel.text = "\(contact.givenName[0])\(contact.familyName[0])"
            avatarImageView.isHighlighted = false
            avatarImageView.image = AVATAR_PLACEHOLDER_IMAGE
        }
        checkImageView.isHighlighted = checked
        self.checked = checked
    }
}
