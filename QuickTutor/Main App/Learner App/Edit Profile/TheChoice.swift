//
//  TheChoice.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import FirebaseAuth
import UIKit

class TheChoiceView: RegistrationGradientView {
    var titleLabel = RegistrationTitleLabel()

    var buttonView = UIView()
    var continueButton = RegistrationBigButton()
    var tutorButton = RegistrationBigButton()

    var partialFlame = UIImageView()

    override func configureView() {
        super.configureView()
        addSubview(titleLabel)
        addSubview(buttonView)
        addSubview(partialFlame)

        buttonView.addSubview(continueButton)
        buttonView.addSubview(tutorButton)

        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("You're all set!\n\nWhat would you like to do now?\n\n", 18, .white)
            .regular("You can always sign up as a tutor later!", 16, .white)

        titleLabel.label.attributedText = formattedString
        titleLabel.label.numberOfLines = 0
        titleLabel.label.textAlignment = .center

        continueButton.label.label.text = "Continue as Learner"

        tutorButton.label.label.text = "Become a Tutor"

        partialFlame.image = UIImage(named: "partial-flame")

        applyConstraints()
    }

    override func applyConstraints() {
        super.applyConstraints()

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.5)
            make.height.equalToSuperview().multipliedBy(0.15)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }

        titleLabel.label.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        buttonView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        continueButton.snp.makeConstraints { make in
            make.height.equalTo(55)
            make.width.equalTo(270)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }

        tutorButton.snp.makeConstraints { make in
            make.height.equalTo(55)
            make.width.equalTo(270)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.4)
        }

        partialFlame.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

class TheChoiceVC: BaseViewController {
    override var contentView: TheChoiceView {
        return view as! TheChoiceView
    }

    override func loadView() {
        view = TheChoiceView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func handleNavigation() {
        if touchStartView == contentView.continueButton {
            displayLoadingOverlay()
            FirebaseData.manager.fetchLearner(Registration.uid) { learner in
                if let learner = learner {
                    self.dismissOverlay()
                    CurrentUser.shared.learner = learner
                    AccountService.shared.currentUserType = .learner
                    self.navigationController?.pushViewController(LearnerPageVC(), animated: true)
                    let endIndex = self.navigationController?.viewControllers.endIndex
                    self.navigationController?.viewControllers.removeFirst(endIndex! - 1)
                } else {
                    self.dismissOverlay()
                    try! Auth.auth().signOut()
                    self.navigationController?.pushViewController(SignInVC(), animated: true)
                }
            }
        } else if touchStartView == contentView.tutorButton {
            displayLoadingOverlay()
            FirebaseData.manager.fetchLearner(Registration.uid) { learner in
                if let learner = learner {
                    self.dismissOverlay()
                    CurrentUser.shared.learner = learner
                    AccountService.shared.currentUserType = .tRegistration
                    self.navigationController?.pushViewController(BecomeTutor(), animated: true)
                } else {
                    self.dismissOverlay()
                    try! Auth.auth().signOut()
                    self.navigationController?.pushViewController(SignInVC(), animated: true)
                }
            }
        }
    }
}
