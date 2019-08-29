//
//  QTRecommendationTableViewCell.swift
//  QuickTutor
//
//  Created by JH Lee on 8/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SwipeCellKit

class QTRecommendationTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblLearnerName: UILabel!
    @IBOutlet weak var lblRecommendationText: UILabel!
    @IBOutlet weak var lblCreatedAt: UILabel!
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTRecommendationTableViewCell.self), bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTRecommendationTableViewCell.self)
    }
    
    func setView(_ objRecommendation: QTTutorRecommendationModel) {
        if let avatarUrl = objRecommendation.learnerAvatarUrl {
            imgAvatar.sd_setImage(with: URL(string: avatarUrl), placeholderImage: AVATAR_PLACEHOLDER_IMAGE)
        } else {
            imgAvatar.image = AVATAR_PLACEHOLDER_IMAGE
        }
        lblLearnerName.text = objRecommendation.learnerName?.trimmingCharacters(in: .whitespacesAndNewlines)
        lblRecommendationText.text = objRecommendation.recommendationText
        if let createdAt = objRecommendation.createdAt {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            lblCreatedAt.text = formatter.string(from: createdAt)
        } else {
            lblCreatedAt.text = nil
        }
    }
    
}
