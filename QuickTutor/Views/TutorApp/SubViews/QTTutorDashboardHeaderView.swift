//
//  QTTutorDashboardHeaderView.swift
//  QuickTutor
//
//  Created by Michael Burkard on 1/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTTutorDashboardHeaderView: UIView {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var hourlyRateLabel: UILabel!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var learnersView: UIView!
    @IBOutlet weak var sessionsView: UIView!
    @IBOutlet weak var subjectsView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var learnersLabel: UILabel!
    @IBOutlet weak var sessionsLabel: UILabel!
    @IBOutlet weak var subjectsLabel: UILabel!
    
    static func load() -> QTTutorDashboardHeaderView {
        return Bundle.main.loadNibNamed(String(describing: QTTutorDashboardHeaderView.self),
                                        owner: nil,
                                        options: [:])?.first as! QTTutorDashboardHeaderView
    }
    
}
