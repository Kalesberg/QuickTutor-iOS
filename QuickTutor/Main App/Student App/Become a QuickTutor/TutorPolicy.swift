//
//  TutorPolicy.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import FirebaseAuth
import UIKit

class TutorPolicyView: RegistrationGradientView {
    var titleLabel = RegistrationTitleLabel()
    var textLabel = LeftTextLabel()
    var buttonView = UIView()
    var learnMoreButton = LearnMoreButton()
    var acceptButton = RegistrationBigButton()
    var declineButton = RegistrationBigButton()

    override func configureView() {
        super.configureView()

        addSubview(titleLabel)
        addSubview(textLabel)
        addSubview(buttonView)
        addSubview(learnMoreButton)

        buttonView.addSubview(acceptButton)
        buttonView.addSubview(declineButton)

        titleLabel.label.text = "Before you join"

        textLabel.label.font = Fonts.createLightSize(17)
        textLabel.label.numberOfLines = 0
        textLabel.label.textColor = .white
        textLabel.label.text = "Whether it's your first time on QuickTutor or you've been with us from the very beginning, please commit to respecting and loving everyone in the QuickTutor community.\n\nI agree to treat everyone on QuickTutor regardless of their race, physical features, national origin, ethnicity, religion, sex, disability, gender identity, sexual orientation or age with respect and love, without judgement or bias."

        acceptButton.label.label.text = "Accept"

        declineButton.label.label.text = "Decline"

        textLabel.sizeToFit()

        applyConstraints()
    }

    override func applyConstraints() {
        super.applyConstraints()

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(textLabel.snp.top)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }

        titleLabel.label.snp.remakeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        textLabel.snp.makeConstraints { make in
            make.bottom.equalTo(learnMoreButton.snp.top)
            make.height.equalTo(320)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
        }

        learnMoreButton.snp.makeConstraints { make in
            make.bottom.equalTo(buttonView.snp.top)
            make.top.equalTo(textLabel.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }

        buttonView.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.3)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        acceptButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(270)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }

        declineButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(270)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.4)
        }
    }
}

class TutorPolicy: BaseViewController {
    override var contentView: TutorPolicyView {
        return view as! TutorPolicyView
    }

    override func loadView() {
        view = TutorPolicyView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        contentView.acceptButton.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func accepted() {
        Stripe.stripeManager.initConnectAccount(completion: { error in
            if let error = error {
                print(error)
            } else {
                Tutor.shared.initTutor(completion: { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("Tutor in DB")
                    }
                })
            }
        })
    }

    private func declined() {}

    override func handleNavigation() {
        if touchStartView == contentView.acceptButton {
            accepted()
            contentView.acceptButton.isUserInteractionEnabled = false
        } else if touchStartView == contentView.declineButton {
            declined()
            print("decline")
        } else if touchStartView == contentView.learnMoreButton {
            print("learn more")
        }
    }
}
