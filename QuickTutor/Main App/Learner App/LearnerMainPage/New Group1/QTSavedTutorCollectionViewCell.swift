//
//  QTSavedTutorCollectionViewCell.swift
//  QuickTutor
//
//  Created by JinJin Lee on 2019/9/10.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Cosmos

class QTSavedTutorCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var hourlyRateLabel: UILabel!
    @IBOutlet var ratingView: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    private var tutor: AWTutor?
    
    static var reuseIdentifier: String {
        return String(describing: QTSavedTutorCollectionViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle:nil)
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // shadow view
        shadowView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: .zero, radius: 4)
    }

    func setTutor (_ tutor: AWTutor) {
        self.tutor = tutor
        
        // set avatar
        avatarImageView.sd_setImage(with: URL(string: tutor.profilePicUrl.absoluteString)!, completed: nil)
        
        // set user name
        usernameLabel.text = tutor.formattedName
        
        // set subject
        subjectLabel.text = tutor.featuredSubject
        
        // hourly rate
        hourlyRateLabel.text = "$\(tutor.price ?? 5) per hour"
        
        // rating or location
        if let rating = tutor.tRating, rating > 0 {
            ratingLabel.superview?.isHidden = false
            locationLabel.superview?.isHidden = true
            
            ratingView.rating = rating
            ratingLabel.text = "\(tutor.reviews?.count ?? 0)"

        } else {
            ratingLabel.superview?.isHidden = true
            locationLabel.superview?.isHidden = false
            guard let location = tutor.location?.location else {
                locationLabel.superview?.isHidden = true
                return
            }
            locationLabel.text = tutor.region ?? "United States"
        }
    }
}
