//
//  QTReviewTableViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 3/14/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTReviewTableViewCell: UITableViewCell {

    // MARK: - Properties
    @IBOutlet weak var avatarImageView: QTCustomImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var ratingView: QTRatingView!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var reviewLabelHeight: NSLayoutConstraint!
    
    
    static var reuseIdentifier: String {
        return String(describing: QTReviewTableViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTReviewTableViewCell.self), bundle:nil)
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ratingView.setupViews()
        ratingView.isUserInteractionEnabled = false
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
            .bold(review.subject, 12, Colors.purple)
            .regular(" • ", 12, UIColor.white)
            .regular(review.formattedDate, 12, Colors.grayText80)
        reviewDateLabel.attributedText = formattedString
        reviewLabel.text = review.message
        let rating = Int(review.rating)
        ratingView.setRatingTo(rating)
        
        DataService.shared.getStudentWithId(review.reviewerId) { (student) in
            guard let student = student else { return }
            self.avatarImageView.sd_setImage(with: student.profilePicUrl,
                                             placeholderImage: UIImage(named: "ic_avatar_placeholder"),
                                             options: [],
                                             completed: nil)
            
        }
    }
}
