//
//  CloseAccountChoice.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/18/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

struct DeleteAccount {
    static var type: Bool = true
}

class CloseAccountChoiceView: MainLayoutTitleBackButton {
    let label: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.font = Fonts.createBoldSize(16)
        label.text = "Please choose the account(s) you wish to close."
        label.numberOfLines = 0
        label.textAlignment = .center

        return label
    }()

    let orLabel: UILabel = {
        let label = UILabel()

        label.text = "OR"
        label.font = Fonts.createBoldSize(20)
        label.textColor = .white

        return label
    }()

    let tutorOnlyButton = TutorOnlyChoiceButton()
    let tutorAndLearnerButton = TutorAndLearnerChoiceButton()

    let container = UIView()

    override func configureView() {
        addSubview(label)
        addSubview(container)
        container.addSubview(orLabel)
        container.addSubview(tutorOnlyButton)
        container.addSubview(tutorAndLearnerButton)
        super.configureView()

        navbar.backgroundColor = Colors.qtRed
        statusbarView.backgroundColor = Colors.qtRed
        title.label.text = "Close Account"

        applyConstraints()
    }

    override func applyConstraints() {
        super.applyConstraints()

        label.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.91)
            make.top.equalTo(navbar.snp.bottom).inset(-20)
            make.centerX.equalToSuperview()
        }

        container.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.width.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }

        orLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }

        tutorAndLearnerButton.snp.makeConstraints { make in
            make.bottom.equalTo(orLabel.snp.top).inset(-20)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(120)
            make.centerX.equalToSuperview()
        }

        tutorOnlyButton.snp.makeConstraints { make in
            make.top.equalTo(orLabel.snp.bottom).inset(-20)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(120)
            make.centerX.equalToSuperview()
        }
    }
}

class CloseAccountChoiceButton: InteractableBackgroundView {
    let label: UILabel = {
        let label = UILabel()

        label.font = Fonts.createBoldSize(20)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }()

    override func configureView() {
        addSubview(label)
        super.configureView()

        layer.cornerRadius = 20
        clipsToBounds = true

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
}

class TutorOnlyChoiceButton: CloseAccountChoiceButton {
    override func configureView() {
        super.configureView()
        backgroundColor = Colors.learnerPurple
        label.text = "Tutor & Learner Accounts"
    }
}

class TutorAndLearnerChoiceButton: CloseAccountChoiceButton {
    override func configureView() {
        super.configureView()
        backgroundColor = Colors.tutorBlue
        label.text = "Just Tutor Account"
    }
}

class CloseAccountChoiceVC: BaseViewController {
    override var contentView: CloseAccountChoiceView {
        return view as! CloseAccountChoiceView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func loadView() {
        view = CloseAccountChoiceView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func handleNavigation() {
        if touchStartView is TutorOnlyChoiceButton {
            DeleteAccount.type = false
            navigationController?.pushViewController(CloseAccountReasonVC(), animated: true)
        } else if touchStartView is TutorAndLearnerChoiceButton {
            DeleteAccount.type = true
            navigationController?.pushViewController(CloseAccountReasonVC(), animated: true)
        }
    }
}
