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
    
    static var resuableIdentifier: String {
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
