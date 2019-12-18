//
//  QTPastSessionTableViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 3/20/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTPastSessionTableViewCell: UITableViewCell {

    // MARK: - Properites
    @IBOutlet weak var avatarImageView: QTCustomImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    static var reuseIdentifier: String {
        return String(describing:QTPastSessionTableViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    var sessionUserInfo: SessionUserInfo!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        usernameLabel.text = ""
        subjectLabel.text = ""
        durationLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Functions
    func setData(_ sessionUserInfo : SessionUserInfo) {
        self.sessionUserInfo = sessionUserInfo
        updateSubject()
        updateTimeAndCost()
        updateUserInfo()
    }
    
    func updateUserInfo() {
        if let sessionType = QTSessionType(rawValue: self.sessionUserInfo.type), sessionType == .quickCalls {
            let attributedText = NSMutableAttributedString(string: sessionUserInfo.userName + "(Call)")
            attributedText.addAttribute(.foregroundColor, value: Colors.purple, range: NSRange(location: attributedText.length - 6, length: 6))
            self.usernameLabel.attributedText = attributedText
        } else {
            self.usernameLabel.attributedText = NSMutableAttributedString(string: sessionUserInfo.userName)
        }
        self.avatarImageView.sd_setImage(with: sessionUserInfo.profilePicUrl, placeholderImage: UIImage(named: "ic_avatar_placeholder"))
    }
    
    func updateSubject() {
        subjectLabel.text = sessionUserInfo.subject
    }
    
    func updateTimeAndCost() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let startTime = Date(timeIntervalSince1970: sessionUserInfo.startTime)
        let startTimeString = dateFormatter.string(from: startTime)
        
        let endTime = Date(timeIntervalSince1970: sessionUserInfo.endTime)
        let endTimeString = dateFormatter.string(from: endTime)
        
        let timeString = "\(startTimeString) - \(endTimeString)"
        
        var cost = sessionUserInfo.cost
        if .learner == AccountService.shared.currentUserType {
            cost = (cost + 0.57) / 0.968
        } else {
            cost = cost * 0.85 - 2
        }
        let formattedPrice = String(format: "%.2f", cost)
        let priceString = "$\(formattedPrice)"
        
        durationLabel.text = "\(timeString) • \(priceString)"
    }
}
