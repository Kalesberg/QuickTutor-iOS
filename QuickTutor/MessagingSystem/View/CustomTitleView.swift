//
//  File.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/2/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class CustomTitleView: UIView {
    
    var user: User!
    var tutor: AWTutor!
    var learner: AWLearner!
    
    let imageView: UserImageView = {
        let iv = UserImageView()
        iv.imageView.layer.cornerRadius = 19
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(16)
        label.backgroundColor = Colors.currentUserColor()
        return label
    }()
    
    let activeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createSize(10)
        label.textAlignment = .center
        return label
    }()
    
    let arrow: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "titleViewArrow")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    var nameLabelHeightAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func updateUI(user: User) {
        self.user = user
        titleLabel.text = user.formattedName
        OnlineStatusService.shared.getLastActiveStringFor(uid: user.uid) { result in
            guard let result = result else { return }
            self.activeLabel.text = result
            self.updateOnlineStatusIndicator()
            if result == "" {
                self.updateNameLabelAsInactive()
            }
        }
    }
    
    func setupViews() {
        setupImageView()
        setupTitleView()
        setupActiveLabel()
        setupArrow()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showProfile))
        addGestureRecognizer(tap)
    }
    
    @objc func showProfile() {
        
        let type = AccountService.shared.currentUserType
        
        if type == .learner {
            let vc = TutorMyProfile()
            vc.tutor = tutor
            vc.isViewing = true
            vc.contentView.rightButton.isHidden = true
            vc.contentView.title.label.text = tutor.username
            navigationController.pushViewController(vc, animated: true)
        } else {
            let vc = LearnerMyProfile()
            vc.learner = learner
            vc.contentView.rightButton.isHidden = true
            vc.isViewing = true
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    private func setupImageView() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 38, height: 38)
    }
    
    private func setupTitleView() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: imageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        nameLabelHeightAnchor = titleLabel.heightAnchor.constraint(equalToConstant: 20)
        nameLabelHeightAnchor?.isActive = true
    }
    
    private func setupActiveLabel() {
        addSubview(activeLabel)
        activeLabel.anchor(top: titleLabel.bottomAnchor, left: imageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 2, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 12)
    }
    
    private func setupArrow() {
        addSubview(arrow)
        arrow.anchor(top: nil, left: titleLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 6, paddingBottom: 0, paddingRight: 0, width: 7, height: 10)
        addConstraint(NSLayoutConstraint(item: arrow, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    private func updateOnlineStatusIndicator() {
        imageView.onlineStatusIndicator.backgroundColor = OnlineStatusService.shared.isActive ? Colors.green : Colors.qtRed
    }
    
    func updateNameLabelAsInactive() {
        nameLabelHeightAnchor?.constant = 38
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
