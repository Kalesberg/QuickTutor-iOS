//
//  SessionReviewVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class SessionReviewVC: UIViewController {
    
    var partnerId: String? = "l7HJ6tG12SXkUTGpz2x9S5T7ctC3"
    var rating: Int? = 2
    
    lazy var fakeNavBar: UIView = {
        let bar = UIView()
        bar.backgroundColor = Colors.learnerPurple
        
        let titleLabel: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.textAlignment = .center
            label.text = "Session Complete!"
            label.font = Fonts.createSize(18)
            return label
        }()
        
        bar.addSubview(titleLabel)
        titleLabel.anchor(top: bar.topAnchor, left: bar.leftAnchor, bottom: bar.bottomAnchor, right: bar.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        return bar
    }()
    
    let profileBox: ReviewProfileBox = {
        let box = ReviewProfileBox()
        return box
    }()
    
    let stars: RatingStartView = {
        let view = RatingStartView(frame: CGRect(x: 0, y: 0, width: 140, height: 25))
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(10)
        label.text = "• How was your time with {name}?\n\n• What did you enjoy most?\n\n• Was Collin easy to work with?"
        label.numberOfLines = 0
        return label
    }()
    
    let reviewInputView: MessageTextView = {
        let field = MessageTextView()
        field.placeholderLabel.text = "Write a review..."
        field.backgroundColor = Colors.navBarColor
        field.layer.cornerRadius = 8
        field.layer.borderColor = UIColor.black.cgColor
        field.textColor = .white
        field.layer.borderWidth = 0.5
        field.font = Fonts.createSize(14)
        field.keyboardAppearance = .dark
        return field
    }()
    
    let characterCountLabel: UILabel = {
        let label = UILabel()
        label.text = "500"
        label.textAlignment = .center
        label.textColor = Colors.grayText
        label.font = Fonts.createSize(14)
        return label
    }()
    
    let submitButton: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFill
        button.setImage(#imageLiteral(resourceName: "submitReviewButton"), for: .normal)
        return button
    }()
    
    func setupViews() {
        setupMainView()
        setupNavBar()
        setupProfileBox()
        setupStars()
        setupInfoLabel()
        setupInputView()
        setupCharacterCountLabel()
        setupSubmitButton()
    }
    
    func setupMainView() {
        view.backgroundColor = Colors.darkBackground
    }
    
    func setupNavBar() {
        view.addSubview(fakeNavBar)
        fakeNavBar.anchor(top: view.getTopAnchor(), left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
    }
    
    func setupProfileBox() {
        view.addSubview(profileBox)
        profileBox.anchor(top: fakeNavBar.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 160, height: 200)
    }
    
    func setupStars() {
        view.addSubview(stars)
        stars.anchor(top: nil, left: profileBox.leftAnchor, bottom: profileBox.bottomAnchor, right: profileBox.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 12, paddingRight: 20, width: 0, height: 20)
    }
    
    func setupInfoLabel() {
        view.addSubview(infoLabel)
        infoLabel.anchor(top: profileBox.topAnchor, left: profileBox.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
    }
    
    func setupInputView() {
        view.addSubview(reviewInputView)
        reviewInputView.anchor(top: profileBox.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 150)
        reviewInputView.delegate = self
    }
    
    func setupCharacterCountLabel() {
        view.addSubview(characterCountLabel)
        characterCountLabel.anchor(top: nil, left: reviewInputView.leftAnchor, bottom: reviewInputView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 50, height: 40)
    }
    
    func setupSubmitButton() {
        view.addSubview(submitButton)
        submitButton.anchor(top: nil, left: nil, bottom: reviewInputView.bottomAnchor, right: reviewInputView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 8, width: 35, height: 35)
        submitButton.addTarget(self, action: #selector(SessionReviewVC.subtmitReview), for: .touchUpInside)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reviewInputView.resignFirstResponder()
    }
    
    func updateUI() {
        guard let id = partnerId, let rating = rating else { return }
        profileBox.updateUI(uid: id)
        stars.setRatingTo(rating)
        DataService.shared.getUserOfOppositeTypeWithId(id) { (user) in
            guard let username = user?.username else { return }
            self.infoLabel.text = self.infoLabel.text?.replacingOccurrences(of: "{name}", with: username)
        }
    }
    
    @objc func subtmitReview() {
        guard let text = reviewInputView.text else { return }
        guard let id = partnerId else { return }
        Database.database().reference().child("review").child(id).childByAutoId().setValue(text)
        navigationController?.pushViewController(LearnerPageViewController(), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateUI()
    }
    
}

extension SessionReviewVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        characterCountLabel.text = "\(500 - textView.text.count)"
        if text == "" { return true }
        return textView.text.count < 500
    }
}
