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
    @IBOutlet weak var dateLabel: UILabel!
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
    
    var session: Session!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        usernameLabel.text = ""
        subjectLabel.text = ""
        durationLabel.text = ""
        dateLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Functions
    func setData(session: Session) {
        self.session = session
        
        updateSubject()
        updateSessionDate()
        updateTimeAndCost()
        AccountService.shared.currentUserType == .learner ? getTutor() : getLearner()
    }
    
    func getTutor() {
        DataService.shared.getTutorWithId(session.partnerId()) { tutor in
            guard let username = tutor?.formattedName.capitalized, let profilePicUrl = tutor?.profilePicUrl else { return }
            if let sessionType = QTSessionType(rawValue: self.session.type), sessionType == .quickCalls {
                let attributedText = NSMutableAttributedString(string: username + "(Call)")
                attributedText.addAttribute(.foregroundColor, value: Colors.purple, range: NSRange(location: attributedText.length - 6, length: 6))
                self.usernameLabel.attributedText = attributedText
            } else {
                self.usernameLabel.attributedText = NSMutableAttributedString(string: username)
            }
            self.avatarImageView.sd_setImage(with: profilePicUrl, placeholderImage: UIImage(named: "ic_avatar_placeholder"))
        }
    }
    
    func getLearner() {
        DataService.shared.getStudentWithId(session.partnerId()) { tutor in
            guard let username = tutor?.formattedName.capitalized, let profilePicUrl = tutor?.profilePicUrl else { return }
            if let sessionType = QTSessionType(rawValue: self.session.type), sessionType == .quickCalls {
                let attributedText = NSMutableAttributedString(string: username + "(Call)")
                attributedText.addAttribute(.foregroundColor, value: Colors.purple, range: NSRange(location: attributedText.length - 6, length: 6))
                self.usernameLabel.attributedText = attributedText
            } else {
                self.usernameLabel.attributedText = NSMutableAttributedString(string: username)
            }
            
            self.avatarImageView.sd_setImage(with: profilePicUrl, placeholderImage: UIImage(named: "ic_avatar_placeholder"))
        }
    }
    
    func updateSubject() {
        subjectLabel.text = session.subject
    }
    
    func updateSessionDate() {
        let date = Date(timeIntervalSince1970: session.date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        dateLabel.text = dateFormatter.string(from: date)
    }
    
    func updateTimeAndCost() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let startTime = Date(timeIntervalSince1970: session.startTime)
        let startTimeString = dateFormatter.string(from: startTime)
        
        let endTime = Date(timeIntervalSince1970: session.endTime)
        let endTimeString = dateFormatter.string(from: endTime)
        
        let timeString = "\(startTimeString) - \(endTimeString)"
        
        let formattedPrice = String(format: "%.2f", session.price)
        let priceString = "$\(formattedPrice)"
        
        durationLabel.text = "\(timeString) • \(priceString)"
    }
}
