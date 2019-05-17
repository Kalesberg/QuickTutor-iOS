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
        iv.onlineStatusIndicator.isHidden = true
        return iv
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBlackSize(16)
        return label
    }()

    let activeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(10)
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
    var timer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupTimer()
    }
    
    deinit {
        timer?.invalidate()
    }

    func updateUI(user: User) {
        self.user = user
        titleLabel.text = user.formattedName
        
        self.getLastActiveStringFor(uid: user.uid)
    }
    
    func getLastActiveStringFor(uid: String) {
        OnlineStatusService.shared.getLastActiveStringFor(uid: user.uid) { result, status in
            self.imageView.onlineStatusIndicator.backgroundColor = status == .online ? Colors.purple : Colors.gray
            guard let result = result else { return }
            self.updateActiveLabelAppearence(forStatus: result)
        }
    }
    
    func updateActiveLabelAppearence(forStatus status: String) {
        self.activeLabel.text = status
        if status == "" {
            self.updateNameLabelAsInactive()
        }
        
        if status == "Active now" {
            self.activeLabel.textColor = Colors.purple
        } else {
            self.activeLabel.textColor = .white
        }
    }

    func setupViews() {
        setupImageView()
        setupTitleView()
        setupActiveLabel()
        setupArrow()
    }
    
    func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (timer) in
            guard let user = self.user else {
                return
            }
            self.updateUI(user: user)
        })
        timer?.fire()
    }

    @objc func showProfile() {
        let type = AccountService.shared.currentUserType

        if type == .learner {
            let controller = QTProfileViewController.controller
            controller.user = tutor
            controller.profileViewType = .tutor
            navigationController.pushViewController(controller, animated: true)
        } else {
            let controller = QTProfileViewController.controller
            let tutor = AWTutor(dictionary: [:])
            controller.user = tutor.copy(learner: learner)
            controller.profileViewType = .learner
            navigationController.pushViewController(controller, animated: true)
        }
    }
    
    private func setupImageView() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 38, height: 38)
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 38))
    }
    
    private func setupTitleView() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: imageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        nameLabelHeightAnchor = titleLabel.heightAnchor.constraint(equalToConstant: 20)
        nameLabelHeightAnchor?.isActive = true
    }
    
    private func setupActiveLabel() {
        addSubview(activeLabel)
        activeLabel.anchor(top: titleLabel.bottomAnchor, left: imageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 2, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 12)
    }
    
    private func setupArrow() {
        addSubview(arrow)
        arrow.anchor(top: nil, left: titleLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 6, paddingBottom: 0, paddingRight: 0, width: 6, height: 8)
        addConstraint(NSLayoutConstraint(item: arrow, attribute: .centerY, relatedBy: .equal, toItem: titleLabel, attribute: .centerY, multiplier: 1, constant: 0))
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
