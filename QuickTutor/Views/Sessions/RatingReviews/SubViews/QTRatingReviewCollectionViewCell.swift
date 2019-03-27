//
//  QTRatingReviewCollectionViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 2/26/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import PlaceholderTextView
import FirebaseStorage

class QTRatingReviewCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hourlyRateLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    
    @IBOutlet weak var profileStar1ImageView: UIImageView!
    @IBOutlet weak var profileStar2ImageView: UIImageView!
    @IBOutlet weak var profileStar3ImageView: UIImageView!
    @IBOutlet weak var profileStar4ImageView: UIImageView!
    @IBOutlet weak var profileStar5ImageView: UIImageView!
    @IBOutlet weak var reviewNumberLabel: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var subjectView: UIView!
    @IBOutlet weak var profileRatingView: UIView!
    
    @IBOutlet weak var ratingCommentLabel: UILabel!
    
    @IBOutlet weak var ratingStarStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ratingStarStackView: UIStackView!
    @IBOutlet weak var ratingStar1ImageView: UIImageView!
    @IBOutlet weak var ratingStar2ImageView: UIImageView!
    @IBOutlet weak var ratingStar3ImageView: UIImageView!
    @IBOutlet weak var ratingStar4ImageView: UIImageView!
    @IBOutlet weak var ratingStar5ImageView: UIImageView!
    @IBOutlet weak var ratingDescriptionLabel: UILabel!
    @IBOutlet weak var feedbackTextView: PlaceholderTextView!
    var isTutorProfile = false
    
    enum Dimension: Float {
        case superViewTop = 94
        case stackViewTopConstraint = 57
        case feedbackTextViewHeight = 66
        case feedbackTextViewBottomDelta = 5
        case avatarWidth = 180
        case avatarHeight = 160
        case avatarMinHeight = 100
        case profileInfoHeight = 65
    }
    
    var ratingStars: [UIImageView]?
    let ratingDescriptions = ["Not good",
                              "Disappointing",
                              "Okay",
                              "Good",
                              "Excellent"]
    let storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
    
    
    static var reuseIdentifier: String {
        return String(describing: QTRatingReviewCollectionViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTRatingReviewCollectionViewCell.self), bundle: nil)
    }
    
    var didUpdateRating: ((Int) -> ())?
    var didWriteReview: ((String?) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileView.layer.cornerRadius = 3
        profileView.layer.borderColor = Colors.gray.cgColor
        profileView.layer.borderWidth = 1
        profileView.clipsToBounds = true
        
        feedbackTextView.layer.cornerRadius = 3
        feedbackTextView.layer.borderColor = Colors.gray.cgColor
        feedbackTextView.layer.borderWidth = 1
        feedbackTextView.font = Fonts.createSize(14)
        feedbackTextView.keyboardAppearance = .dark
        feedbackTextView.delegate = self
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        ratingStars = [ratingStar1ImageView,
                       ratingStar2ImageView,
                       ratingStar3ImageView,
                       ratingStar4ImageView,
                       ratingStar5ImageView]
        ratingStars?.forEach { (imageView) in
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleReviewStarTap(_:))))
        }
    }

    @objc
    func handleKeyboardShow(_ notification: Notification) {
        
        var delta: CGFloat = 0
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // Check whether or not the keyboard overlays text view or not
            let window = UIView(frame: CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size))
            let newFrame = feedbackTextView.convert(feedbackTextView.bounds, to: window)
            let bottom = newFrame.origin.y + CGFloat(Dimension.feedbackTextViewHeight.rawValue)
            let keyboardTop = UIScreen.main.bounds.height - keyboardSize.size.height
            if keyboardTop < bottom {
                // overlay
                delta = bottom - keyboardTop + CGFloat(Dimension.feedbackTextViewBottomDelta.rawValue)
            }
        }
        ratingCommentLabel.isHidden = true
        UIView.animate(withDuration: TimeInterval(1.5)) {
            if delta > 0 {
                // Decrease the height of "please rate..." (57px)
                self.ratingStarStackViewTopConstraint.constant = 0
                if delta - CGFloat(Dimension.stackViewTopConstraint.rawValue) > CGFloat(Dimension.avatarHeight.rawValue) - CGFloat(Dimension.avatarMinHeight.rawValue) {
                    // Decrease the height of profile info (65px)
                    self.nameView.isHidden = true
                    self.subjectView.isHidden = true
                    self.profileRatingView.isHidden = true
                    // Decrease the avatar size
                    if delta > CGFloat(Dimension.stackViewTopConstraint.rawValue) + CGFloat(Dimension.profileInfoHeight.rawValue) {
                        self.avatarHeightConstraint.constant = CGFloat(Dimension.avatarHeight.rawValue) -
                            (delta - CGFloat(Dimension.stackViewTopConstraint.rawValue) - CGFloat(Dimension.profileInfoHeight.rawValue))
                    }
                } else if delta > CGFloat(Dimension.stackViewTopConstraint.rawValue) {
                    // Update the avatar height with min height.
                    self.avatarHeightConstraint.constant = CGFloat(Dimension.avatarMinHeight.rawValue)
                }
                self.avatarWidthConstraint.constant = self.avatarHeightConstraint.constant * CGFloat(Dimension.avatarWidth.rawValue / Dimension.avatarHeight.rawValue)
            }
            self.layoutIfNeeded()
        }
    }
    
    @objc
    func handleKeyboardHide(_ notification: Notification) {
        UIView.animate(withDuration: TimeInterval(1.5)) {
            if self.avatarWidthConstraint.constant < CGFloat(Dimension.avatarWidth.rawValue) {
                self.avatarWidthConstraint.constant = CGFloat(Dimension.avatarWidth.rawValue)
                self.avatarHeightConstraint.constant = CGFloat(Dimension.avatarHeight.rawValue)
            }
            self.ratingStarStackViewTopConstraint.constant = 57
            self.ratingCommentLabel.isHidden = false
            self.nameView.isHidden = false
            if self.isTutorProfile {
                self.subjectView.isHidden = false
            }
            self.profileRatingView.isHidden = false
            self.layoutIfNeeded()
        }
    }
    
    @objc
    func handleReviewStarTap(_ gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView, let ratingStars = ratingStars else { return }
        let rating = imageView.tag - 10
        for i in 0 ..< 5 {
            ratingStars[i].isHighlighted = rating > i ? true : false
        }
        
        ratingDescriptionLabel.text = ratingDescriptions[rating - 1]
        
        if let didUpdateRating = didUpdateRating {
            didUpdateRating(rating)
        }
    }
    
    public func setProfileInfo(user: Any, subject: String?) {
        
        feedbackTextView.font = Fonts.createSize(14)
        
        if let tutor = user as? AWTutor {
            let nameSplit = tutor.name.split(separator: " ")
            nameLabel.text = String(nameSplit[0]) + " " + String(nameSplit[1].prefix(1) + ".")
            avatarImageView.sd_setImage(with: storageRef.child("student-info").child(tutor.uid).child("student-profile-pic1"))
            if let rating = tutor.tRating {
                setProfileRating(Int(rating))
            }
            
            if let reviews = tutor.reviews {
                reviewNumberLabel.text = "\(reviews.count)"
                reviewNumberLabel.isHidden = false
            } else {
                reviewNumberLabel.isHidden = true
            }
            
            if let subject = subject {
                subjectView.isHidden = false
                subjectLabel.text = subject
            } else {
                subjectView.isHidden = true
            }
            
            if let hourlyRate = tutor.price {
                hourlyRateLabel.text = "$\(hourlyRate)"
                hourlyRateLabel.isHidden = false
            } else {
                hourlyRateLabel.isHidden = true
            }
            
            isTutorProfile = true
        } else if let learner = user as? AWLearner {
            let nameSplit = learner.name.split(separator: " ")
            nameLabel.text = String(nameSplit[0]) + " " + String(nameSplit[1].prefix(1) + ".")
            avatarImageView.sd_setImage(with: storageRef.child("student-info").child(learner.uid).child("student-profile-pic1"))
            if let rating = learner.lRating {
                setProfileRating(Int(rating))
            }
            
            if let reviews = learner.lReviews {
                reviewNumberLabel.text = "\(reviews.count)"
                reviewNumberLabel.isHidden = false
            } else {
                reviewNumberLabel.isHidden = true
            }
            
            subjectView.isHidden = true
            hourlyRateLabel.isHidden = true
            isTutorProfile = false
        }
        
        scrollView.contentSize.width = UIScreen.main.bounds.width
        
    }
    
    private func setProfileRating(_ rating: Int) {
        let stars = [profileStar1ImageView, profileStar2ImageView, profileStar3ImageView, profileStar4ImageView, profileStar5ImageView]
        for i in 0 ..< 5 {
            stars[i]?.isHighlighted = rating > i ? true : false
        }
    }
}

extension QTRatingReviewCollectionViewCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if let didWriteReview = didWriteReview {
            didWriteReview(textView.text)
        }
    }
}
