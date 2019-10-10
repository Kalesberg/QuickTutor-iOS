//
//  QTLearnerDiscoverTutorCollectionViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import Cosmos
import Firebase

class QTLearnerDiscoverTutorCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgTutor: UIImageView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var lblTutorName: UILabel!
    @IBOutlet weak var lblFeaturedTopic: UILabel!
    @IBOutlet weak var lblHourlyRate: UILabel!
    @IBOutlet weak var viewRisingTalent: UIView!
    @IBOutlet weak var viewRating: CosmosView!
    @IBOutlet weak var lblReviewsCount: UILabel!    
    
    private let viewMask = UIView(frame: .zero)
    
    private var objTutor: AWTutor?
    
    static var nib: UINib {
        return UINib(nibName: QTLearnerDiscoverTutorCollectionViewCell.reuseIdentifier, bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTLearnerDiscoverTutorCollectionViewCell.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgTutor.superview?.addSubview(viewMask)
        viewMask.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        viewMask.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let oldGradientLayer = viewMask.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            oldGradientLayer.removeFromSuperlayer()
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: viewMask.frame.size)
        gradientLayer.colors = [UIColor.clear,
                                UIColor.black.withAlphaComponent(0.8)].map({$0.cgColor})
        gradientLayer.locations = [0, 1]
        viewMask.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBAction func onClickBtnSave(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid,
            let tutorId = objTutor?.uid, uid != tutorId else { return }
        
        if !CurrentUser.shared.learner.savedTutorIds.isEmpty {
            let savedTutorIds = CurrentUser.shared.learner.savedTutorIds
            savedTutorIds.contains(tutorId) ? unsaveTutor() : saveTutor()
        } else {
            saveTutor()
        }
    }
    
    func saveTutor() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = objTutor?.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).setValue(1)
        btnSave.isSelected = true
        CurrentUser.shared.learner.savedTutorIds.append(tutorId)
    }
    
    func unsaveTutor() {
        guard let uid = Auth.auth().currentUser?.uid, let tutorId = objTutor?.uid else { return }
        Database.database().reference().child("saved-tutors").child(uid).child(tutorId).removeValue()
        btnSave.isSelected = false
        CurrentUser.shared.learner.savedTutorIds.removeAll(where: { $0 == tutorId })
    }
    
    func setView(_ tutor: AWTutor, isRisingTalent: Bool = false) {
        objTutor = tutor
        
        imgTutor.sd_setImage(with: tutor.profilePicUrl, placeholderImage: UIImage(named: "ic_avatar_placeholder"))
        viewMask.isHidden = false
        
        btnSave.isHidden = false
        btnSave.isSelected = CurrentUser.shared.learner.savedTutorIds.contains(tutor.uid)
        
        lblTutorName.isHidden = false
        lblTutorName.text = tutor.formattedName
        lblFeaturedTopic.text = tutor.featuredSubject
        
        lblHourlyRate.text = "$\(tutor.price ?? 5) per hour"
        
        viewRisingTalent.isHidden = !isRisingTalent
        viewRating.superview?.superview?.isHidden = isRisingTalent
        
        if let rating = tutor.tRating, 0 < rating,
            let reviews = tutor.reviews, !reviews.isEmpty {
            viewRating.superview?.isHidden = false
            viewRating.rating = rating
            lblReviewsCount.text = "\(reviews.count)"
        } else {
            viewRating.superview?.isHidden = true
            if let experienceSubject = tutor.experienceSubject,
                let experiencePeriod = tutor.experiencePeriod, !experienceSubject.isEmpty {
                if experiencePeriod == 0.5 {
                    lblReviewsCount.text = "6 Months Experience in \(experienceSubject)"
                } else {
                    lblReviewsCount.text = "\(Int(experiencePeriod)) Years Experience in \(experienceSubject)"
                }
            } else if let address = tutor.region {
                lblReviewsCount.text = address
            }
        }
    }

}
