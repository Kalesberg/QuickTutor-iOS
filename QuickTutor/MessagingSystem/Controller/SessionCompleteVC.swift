//
//  SessionCompleteVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/23/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class SessionCompleteVC: UIViewController {
    
    var ratingDescriptions = ["Not good", "Disappointing", "Okay", "Good", "Excellent"]
    var partnerId: String?
    
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
    
    let partnerBox: EndSessionProfileBox = {
        let box = EndSessionProfileBox()
        return box
    }()
    
    let submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.learnerPurple
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = Fonts.createLightSize(22)
        button.setTitleColor(.white, for: .normal)
        button.adjustsImageWhenDisabled = true
        return button
    }()
    
    let submitButtonCover: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return view
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.yellow
        label.textAlignment = .center
        label.font = Fonts.createSize(22)
        return label
    }()
    
    let ratingView: RatingStartView = {
        let view = RatingStartView(frame: CGRect(x: 0, y: 0, width: 257, height: 45))
        return view
    }()
    
    func setupViews() {
        setupMainView()
        setupNavBar()
        setupPartnerBox()
        setupStarView()
        setupDescriptionLabel()
        setupSubmitButton()
        setupSubmitButtonCover()
    }
    
    func setupMainView() {
        view.backgroundColor = Colors.darkBackground
    }
    
    func setupNavBar() {
        view.addSubview(fakeNavBar)
        fakeNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
    }
    
    func setupPartnerBox() {
        view.addSubview(partnerBox)
        partnerBox.anchor(top: fakeNavBar.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 9, paddingBottom: 9, paddingRight: 9, width: 160, height: 190)
        view.addConstraint(NSLayoutConstraint(item: partnerBox, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupStarView() {
        view.addSubview(ratingView)
        ratingView.anchor(top: partnerBox.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 80, paddingLeft: 59, paddingBottom: 0, paddingRight: 59, width: 0, height: 45)
        ratingView.delegate = self
    }
    
    func setupDescriptionLabel() {
        view.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: ratingView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    func setupSubmitButton() {
        view.addSubview(submitButton)
        submitButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 70)
        submitButton.addTarget(self, action: #selector(SessionCompleteVC.submitRating), for: .touchUpInside)
    }
    
    func setupSubmitButtonCover() {
        view.addSubview(submitButtonCover)
        submitButtonCover.anchor(top: submitButton.topAnchor, left: submitButton.leftAnchor, bottom: submitButton.bottomAnchor, right: submitButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func updateUI() {
        guard let id = partnerId else { return }
        partnerBox.updateUI(uid: id)
    }
    
    @objc func submitRating() {
        guard let id = partnerId else { return }
        let infoNode = AccountService.shared.currentUserType == .learner ? "tutor-info" : "learner-info"
        Database.database().reference().child(infoNode).child(id).child("r").setValue(ratingView.rating)
        let vc = SessionReviewVC()
        vc.partnerId = partnerId
        vc.rating = ratingView.rating
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateUI()
    }
    
}

extension SessionCompleteVC: RatingStarViewDelegate {
    func didUpdateRating(rating: Int) {
        self.descriptionLabel.text = ratingDescriptions[rating - 1]
        submitButtonCover.removeFromSuperview()
    }
}
