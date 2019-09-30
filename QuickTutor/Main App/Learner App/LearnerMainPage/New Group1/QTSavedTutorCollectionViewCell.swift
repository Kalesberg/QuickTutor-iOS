//
//  QTSavedTutorCollectionViewCell.swift
//  QuickTutor
//
//  Created by JinJin Lee on 2019/9/10.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Cosmos
import Firebase

class QTSavedTutorCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var hourlyRateLabel: UILabel!
    @IBOutlet var ratingView: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
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
        
        // save button
        saveButton.isHidden = true
    }

    // MARK: - Event Handlers
    @IBAction func onClickSave(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = tutor?.uid, uid != tutorId else { return }
        if !CurrentUser.shared.learner.savedTutorIds.isEmpty {
            let savedTutorIds = CurrentUser.shared.learner.savedTutorIds
            savedTutorIds.contains(tutorId) ? unsaveTutor() : saveTutor()
        } else {
            saveTutor()
        }
    }
    
    func saveTutor() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = tutor?.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).setValue(1)
        saveButton.isSelected = true
        CurrentUser.shared.learner.savedTutorIds.append(tutorId)
        NotificationCenter.default.post(name: NotificationNames.SavedTutors.didUpdate, object: nil)
    }
    
    func unsaveTutor() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = tutor?.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).removeValue()
        saveButton.isSelected = false
        CurrentUser.shared.learner.savedTutorIds.removeAll(where: { (id) -> Bool in
            return id == tutorId
        })
        NotificationCenter.default.post(name: NotificationNames.SavedTutors.didUpdate, object: nil)
    }
    
    // MARK: - Set Data Handler
    func setTutor (_ tutor: AWTutor) {
        self.tutor = tutor
        
        saveButton.isHidden = false
        if !CurrentUser.shared.learner.savedTutorIds.isEmpty {
            let savedTutorIds = CurrentUser.shared.learner.savedTutorIds
            saveButton.isSelected = savedTutorIds.contains(tutor.uid)
        }
        
        // set avatar
        avatarImageView.sd_setImage(with: URL(string: tutor.profilePicUrl.absoluteString)!, completed: nil)
        
        // set user name
        usernameLabel.text = tutor.formattedName
        
        // set subject
        subjectLabel.text = tutor.featuredSubject
        
        // hourly rate
        hourlyRateLabel.text = "$\(tutor.price ?? 5) per hour"
        
        // rating or location
        if let rating = tutor.tRating, rating > 0, let reviews = tutor.reviews, reviews.count > 0 {
            ratingLabel.superview?.isHidden = false
            locationLabel.superview?.isHidden = true
            
            ratingView.rating = rating
            ratingLabel.text = "\(reviews.count)"

        } else {
            ratingLabel.superview?.isHidden = true
            locationLabel.superview?.isHidden = false
            guard let _ = tutor.location?.location else {
                locationLabel.superview?.isHidden = true
                return
            }
            locationLabel.text = tutor.region ?? "United States"
        }
    }
}
