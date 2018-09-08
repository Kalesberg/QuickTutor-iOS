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
    
    var partnerId: String?
    var rating: Int? = 2
    
    lazy var fakeNavBar: UIView = {
        let bar = UIView()
        bar.backgroundColor = AccountService.shared.currentUserType == .learner ? Colors.learnerPurple : Colors.tutorBlue
        
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
    
    let stars: RatingStarView = {
        let view = RatingStarView(frame: CGRect(x: 0, y: 0, width: 140, height: 25))
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(10)
        label.text = "• How was your time with {name}?\n\n• What did you enjoy most?\n\n• Was {name} easy to work with?"
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
        view.bringSubview(toFront: fakeNavBar)
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
            guard let username = user?.formattedName else { return }
            self.infoLabel.text = self.infoLabel.text?.replacingOccurrences(of: "{name}", with: username)
        }
    }
    
    @objc func subtmitReview() {
        guard let text = reviewInputView.text else {
            let vc = AccountService.shared.currentUserType == .tutor ? TutorPageViewController() : LearnerPageViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        guard let id = partnerId else { return }
        
        let session = SessionService.shared.session
            
        var reviewDict = [String: Any]()
        guard let date = session?.startTime,
        let subject = session?.subject,
        let price = session?.price else {
                print("ERROR: Could not prepare session for review")
                return
        }
        let rating = Double(SessionService.shared.rating)
        let duration = SessionService.shared.session.lengthInMinutes()
		
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DataService.shared.getUserOfCurrentTypeWithId(uid) { (user) in
            guard let name = user?.formattedName,
                let profilePicUrl = user?.profilePicUrl else {
                    print("ERROR: could not fetch name and pic for current user")
                    return
            }
            reviewDict["dte"] = date
            reviewDict["p"] = price
            reviewDict["m"] = text
            reviewDict["sbj"] = subject
            reviewDict["dur"] = duration
            reviewDict["img"] = profilePicUrl
            reviewDict["nm"] = name
            reviewDict["r"] = rating
            reviewDict["uid"] = uid
			
            Database.database().reference().child("review").child(id).childByAutoId().setValue(reviewDict)
            PostSessionManager.shared.setUnfinishedFlag(sessionId: (session?.id)!, status: SessionStatus.reviewAdded)
            
            let vc = AccountService.shared.currentUserType == .tutor ? TutorPageViewController() : LearnerPageViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateUI()
        setupKeyboardObserversIfNeeded()
    }
    
    func setupKeyboardObserversIfNeeded() {
        guard UIScreen.main.bounds.height <= 667 else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        self.view.transform = CGAffineTransform(translationX: 0, y: -75)
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        self.view.transform = CGAffineTransform(translationX: 0, y: 0)
    }
}

extension SessionReviewVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        characterCountLabel.text = "\(500 - textView.text.count)"
        if text == "" { return true }
        return textView.text.count < 500
    }
}
