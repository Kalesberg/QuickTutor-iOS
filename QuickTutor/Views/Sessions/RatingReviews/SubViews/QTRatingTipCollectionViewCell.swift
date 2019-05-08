//
//  QTRatingTipCollectionViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 2/26/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import FirebaseStorage

class QTRatingTipCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hourlyRateLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var reviewNumberLabel: UILabel!
    @IBOutlet weak var profileStar1ImageView: UIImageView!
    @IBOutlet weak var profileStar2ImageView: UIImageView!
    @IBOutlet weak var profileStar3ImageView: UIImageView!
    @IBOutlet weak var profileStar4ImageView: UIImageView!
    @IBOutlet weak var profileStar5ImageView: UIImageView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var subjectView: UIView!
    @IBOutlet weak var profileRatingView: UIView!
    @IBOutlet weak var avatarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var tipTextField: UITextField!
    @IBOutlet weak var tipCheckImageView: UIImageView!
    @IBOutlet weak var tipCheckStackView: UIStackView!
    
    var isPayWithoutTip = false
    var tip: Double = 0
    var costOfSession: Double = 0.0
    var didSelectTip: ((Double) ->())?
    
    struct Dimension {
        let avatarWidth = 180
        let avatarHeight = 160
        let avatarMinHeight = 100
        let tipTextFieldHeight = 50
        let profileInfoHeight = 65
        let tipCheckStackViewTop = 30
        let tipCheckStackViewHeight = 40
    }
    
    var dimension: Dimension = Dimension()
    
    let storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)
    
    static var reuseIdentifier: String {
        return String(describing: QTRatingTipCollectionViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTRatingTipCollectionViewCell.self), bundle: nil)
    }
    
    let maxTip: Double = 250
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileView.layer.cornerRadius = 3
        profileView.layer.borderColor = Colors.gray.cgColor
        profileView.layer.borderWidth = 1
        profileView.clipsToBounds = true
        
        tipTextField.layer.cornerRadius = 3
        tipTextField.layer.borderColor = Colors.gray.cgColor
        tipTextField.layer.borderWidth = 1
        tipTextField.clipsToBounds = true
        tipTextField.delegate = self
        
        tipCheckStackView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTipCheckTap))
        tipCheckStackView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        tipTextField.addTarget(self, action: #selector(handleTipTextFieldChanged(_:)), for: .editingChanged)
    }

    @IBAction func onMinusButtonClicked(_ sender: Any) {
        if tip - 5 < 0 {
            tip = 0
        } else {
            tip -= 5
        }
        
        tipTextField.text = "$\(tip)"
        updateTipAmount(text: tipTextField.text)
        
        UIView.animate(withDuration: 0.05, animations: {
            self.minusButton.alpha = 0.3
        }) { (completed) in
            UIView.animate(withDuration: 0.05, animations: {
                self.minusButton.alpha = 1
            })
        }
    }
    
    @IBAction func onPlusButtonClicked(_ sender: Any) {
        if tip == maxTip { return }
        tip += 5
        tipTextField.text = "$\(tip)"
        updateTipAmount(text: tipTextField.text)
        
        UIView.animate(withDuration: 0.05, animations: {
            self.plusButton.alpha = 0.3
        }) { (completed) in
            UIView.animate(withDuration: 0.05, animations: {
                self.plusButton.alpha = 1
            })
        }
    }
    
    @objc
    private func handleTipCheckTap() {
        isPayWithoutTip = !isPayWithoutTip
        minusButton.isEnabled = !isPayWithoutTip
        minusButton.alpha = isPayWithoutTip ? 0.02 : 1
        plusButton.isEnabled = !isPayWithoutTip
        plusButton.alpha = isPayWithoutTip ? 0.02 : 1
        tipCheckImageView.isHighlighted = isPayWithoutTip
        tip = 0
        tipTextField.text = "$0"
        updateTipAmount(text: tipTextField.text)
        if let didSelectTip = didSelectTip {
            didSelectTip(tip)
        }
    }
    
    @objc
    func handleKeyboardShow(_ notification: Notification) {
        
        var delta: CGFloat = 0
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // Check whether or not the keyboard overlays text view or not
            let window = UIView(frame: CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size))
            let newFrame = tipTextField.convert(tipTextField.bounds, to: window)
            let bottom = newFrame.origin.y +
                CGFloat(dimension.tipTextFieldHeight +
                    dimension.tipCheckStackViewTop +
                    dimension.tipCheckStackViewHeight)
            let keyboardTop = UIScreen.main.bounds.height - keyboardSize.size.height
            if keyboardTop < bottom {
                // overlay
                delta = bottom - keyboardTop
            }
        }
        
        UIView.animate(withDuration: TimeInterval(1.5)) {
            if delta > 0 {
                if delta < CGFloat(self.dimension.avatarHeight - self.dimension.avatarMinHeight) {
                    // Update the avatar height with min height.
                    self.avatarHeightConstraint.constant = CGFloat(self.dimension.avatarMinHeight)
                } else {
                    // Decrease the height of profile info (65px)
                    if delta > CGFloat(self.dimension.profileInfoHeight) {
                        self.nameView.isHidden = true
                        self.subjectView.isHidden = true
                        self.profileRatingView.isHidden = true
                        if delta - CGFloat(self.dimension.profileInfoHeight) < CGFloat(self.dimension.avatarHeight - self.dimension.avatarMinHeight) {
                            // Update the avatar height with min height.
                            self.avatarHeightConstraint.constant = CGFloat(self.dimension.avatarMinHeight)
                        } else {
                            // Hide the avatar
                            self.avatarHeightConstraint.constant = 0
                        }
                    }
                }
                self.avatarWidthConstraint.constant = self.avatarHeightConstraint.constant * CGFloat(self.dimension.avatarWidth / self.dimension.avatarHeight)
            }
            self.layoutIfNeeded()
        }
    }
    
    @objc
    func handleKeyboardHide(_ notification: Notification) {
        UIView.animate(withDuration: TimeInterval(1.5)) {
            if self.avatarWidthConstraint.constant < CGFloat(self.dimension.avatarWidth) {
                self.avatarWidthConstraint.constant = CGFloat(self.dimension.avatarWidth)
                self.avatarHeightConstraint.constant = CGFloat(self.dimension.avatarHeight)
            }
            self.nameView.isHidden = false
            self.subjectView.isHidden = false
            self.profileRatingView.isHidden = false
            self.layoutIfNeeded()
        }
    }
    
    @objc
    func handleTipTextFieldChanged(_ textField: UITextField) {
        updateTipAmount(text: textField.text)
    }
    
    public func setProfileInfo(user: Any, subject: String?, costOfSession: Double) {
        
        scrollView.contentSize.width = UIScreen.main.bounds.width
        scrollView.backgroundColor = UIColor.red
        
        
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
                subjectLabel.text = subject
            }
            if let hourlyRate = tutor.price {
                hourlyRateLabel.text = "$\(hourlyRate)/hr"
                hourlyRateLabel.isHidden = false
            } else {
                hourlyRateLabel.isHidden = true
            }
            
            self.costOfSession = costOfSession
            priceLabel.text = costOfSession.currencyFormat(precision: 2, divider: 1)
        }
    }
    
    private func setProfileRating(_ rating: Int) {
        let stars = [profileStar1ImageView, profileStar2ImageView, profileStar3ImageView, profileStar4ImageView, profileStar5ImageView]
        for i in 0 ..< 5 {
            stars[i]?.isHighlighted = rating > i ? true : false
        }
    }
    
    private func updateTipAmount(text: String?) {
        if var text = text, text.hasPrefix("$") {
            text = text.replacingOccurrences(of: "$", with: "")
            tip = Double(text) ?? 0.0
            if tip > maxTip {
                tipTextField.text = "$250"
                tip = maxTip
            }
            let cost = costOfSession + tip
            priceLabel.text = cost.currencyFormat(precision: 2, divider: 1)
            
            if let didSelectTip = didSelectTip {
                didSelectTip(tip)
            }
        }
    }
}

extension QTRatingTipCollectionViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isPayWithoutTip = false
        minusButton.isEnabled = !isPayWithoutTip
        minusButton.alpha = isPayWithoutTip ? 0.02 : 1
        plusButton.isEnabled = !isPayWithoutTip
        plusButton.alpha = isPayWithoutTip ? 0.02 : 1
        tipCheckImageView.isHighlighted = isPayWithoutTip
        
        if textField.text?.isEmpty == true {
            textField.text = "$"
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let newString = textField.text as NSString? {
            return newString.replacingCharacters(in: range, with: string).hasPrefix("$")
        }
        
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateTipAmount(text: textField.text)
    }
}
