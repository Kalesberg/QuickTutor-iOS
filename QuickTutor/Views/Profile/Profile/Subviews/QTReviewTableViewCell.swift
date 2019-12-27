//
//  QTReviewTableViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 3/14/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Cosmos

class QTReviewTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var avatarInitialsLabel: UILabel!
    @IBOutlet weak var avatarImageView: QTCustomImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var reviewSubject: UILabel!
    @IBOutlet weak var reviewBottomConstraint: NSLayoutConstraint!
    
    
    static var reuseIdentifier: String {
        return String(describing: QTReviewTableViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTReviewTableViewCell.self), bundle:nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Functions
    func setData(review: Review) {
        usernameLabel.text = review.studentName.formatName()
        let formattedString = NSMutableAttributedString()
        formattedString
            .regular(review.formattedDate, 14, Colors.grayText80)
        reviewDateLabel.attributedText = formattedString
        reviewSubject.attributedText = NSMutableAttributedString().bold(review.subject, 14, Colors.purple);
        if review.message.isEmpty {
            reviewBottomConstraint.constant = 0
            reviewLabel.text = nil
        } else {
            reviewBottomConstraint.constant = 18
            reviewLabel.text = review.message.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        ratingView.rating = review.rating
        
        avatarImageView.image = UIImage(named: "ic_avatar_placeholder")
        
        avatarInitialsLabel.text = "\(review.studentName[0].uppercased())"
        UserFetchService.shared.getStudentWithId(review.reviewerId) { (student) in
            guard let student = student else {
                self.avatarInitialsLabel.text = ""
                self.avatarImageView.image = UIImage(named: "ic_avatar_placeholder")
                return
            }
            self.avatarImageView.sd_setImage(with: student.profilePicUrl,
                                             placeholderImage: UIImage(named: "ic_avatar_placeholder"),
                                             options: [],
                                             completed: nil)
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatarImageView.image = nil
    }
}
