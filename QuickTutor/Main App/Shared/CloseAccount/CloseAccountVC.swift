//
//  LearnerCloseAccount.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class CloseAccountView: MainLayoutTitleBackButton {
    let warningLabel = WarningLabel()

    let closeAccountLabel: UILabel = {
        let label = UILabel()

        let formattedString = NSMutableAttributedString()

        if AccountService.shared.currentUserType == .learner {
            formattedString
                .bold("Closing Your Account", 20, .white)
                .regular("\n\n", 9, .white)
                .regular("If you wish to close your account, you will not be able to recover any data related to your account (such as your connections with other users, and profile information).", 15, .white)
        } else {
            formattedString
                .bold("Closing Your Account", 20, .white)
                .regular("\n\n", 9, .white)
                .regular("If you wish to keep your account but want to remove yourself from search results, you can toggle this in your settings.\n\nIf you wish to close your account, you will not be able to recover any data related to your account (such as your connections with other users, and profile information).", 15, .white)
        }

        label.attributedText = formattedString
        label.numberOfLines = 0
        label.textAlignment = .left

        return label
    }()

    let cancelButton = CancelButton()
    let hideMeButton = HideMeButton()
    let proceedButton = ProceedButton()

    override func configureView() {
        addSubview(warningLabel)
        addSubview(closeAccountLabel)
        addSubview(proceedButton)
        addSubview(cancelButton)
        addSubview(hideMeButton)
        super.configureView()

        navbar.backgroundColor = Colors.qtRed
        statusbarView.backgroundColor = Colors.qtRed
        title.label.text = "Close Account"
    }

    override func applyConstraints() {
        super.applyConstraints()

        if AccountService.shared.currentUserType == .learner {
            warningLabel.snp.makeConstraints { make in
                make.top.equalTo(navbar.snp.bottom).inset(-15)
                make.width.equalToSuperview().multipliedBy(0.9)
                make.height.equalTo(60)
                make.centerX.equalToSuperview()
            }

            closeAccountLabel.snp.makeConstraints { make in
                make.top.equalTo(warningLabel.snp.bottom).inset(-25)
                make.width.equalToSuperview().multipliedBy(0.9)
                make.centerX.equalToSuperview()
            }

            proceedButton.snp.makeConstraints { make in
                if #available(iOS 11.0, *) {
                    make.bottom.equalTo(safeAreaLayoutGuide)
                } else {
                    make.bottom.equalToSuperview()
                }
                make.width.equalToSuperview()
                make.height.equalTo(50)
            }

            cancelButton.snp.makeConstraints { make in
                make.bottom.equalTo(proceedButton.snp.top).inset(-40)
                make.width.equalTo(250)
                make.height.equalTo(50)
                make.centerX.equalToSuperview()
            }
        } else {
            warningLabel.snp.makeConstraints { make in
                if UIScreen.main.bounds.height == 480 {
                    make.top.equalTo(navbar.snp.bottom).inset(-10)
                } else {
                    make.top.equalTo(navbar.snp.bottom).inset(-15)
                }
                make.width.equalToSuperview().multipliedBy(0.9)
                make.height.equalTo(60)
                make.centerX.equalToSuperview()
            }

            closeAccountLabel.snp.makeConstraints { make in
                if UIScreen.main.bounds.height == 480 {
                    make.top.equalTo(warningLabel.snp.bottom).inset(-10)
                } else {
                    make.top.equalTo(warningLabel.snp.bottom).inset(-25)
                }
                make.width.equalToSuperview().multipliedBy(0.9)
                make.centerX.equalToSuperview()
            }

            proceedButton.snp.makeConstraints { make in
                if #available(iOS 11.0, *) {
                    make.bottom.equalTo(safeAreaLayoutGuide)
                } else {
                    make.bottom.equalToSuperview()
                }
                make.width.equalToSuperview()
                make.height.equalTo(50)
            }

            cancelButton.snp.makeConstraints { make in
                if UIScreen.main.bounds.height == 480 || UIScreen.main.bounds.height == 568 {
                    make.bottom.equalTo(proceedButton.snp.top).inset(-10)
                } else {
                    make.bottom.equalTo(proceedButton.snp.top).inset(-40)
                }

                make.width.equalTo(250)
                make.height.equalTo(50)
                make.centerX.equalToSuperview()
            }

            hideMeButton.snp.makeConstraints { make in
                if UIScreen.main.bounds.height == 480 {
                    make.bottom.equalTo(cancelButton.snp.top).inset(-10)
                } else {
                    make.bottom.equalTo(cancelButton.snp.top).inset(-20)
                }

                make.width.equalTo(250)
                make.height.equalTo(50)
                make.centerX.equalToSuperview()
            }
        }
    }
}

class WarningLabel: BaseView {
    let warningLabel: UILabel = {
        let label = UILabel()

        label.text = "If you close your account, we will not be able to restore your data if you change your mind."
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(16)
        label.numberOfLines = 3

        return label
    }()

    override func configureView() {
        addSubview(warningLabel)
        super.configureView()

        backgroundColor = Colors.qtRed
        layer.cornerRadius = 5

        applyConstraints()
    }

    override func applyConstraints() {
        warningLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.95)
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
}

class ProceedButton: ArrowItem {
    override func configureView() {
        super.configureView()

        backgroundColor = Colors.qtRed
        label.text = "Proceed to closing account"
        label.font = Fonts.createBoldSize(18)
    }
}

class CancelButton: InteractableView, Interactable {
    let label: UILabel = {
        let label = UILabel()

        label.font = Fonts.createBoldSize(20)
        label.textAlignment = .center
        label.text = "Cancel"
        label.textColor = .white

        return label
    }()

    override func configureView() {
        addSubview(label)
        super.configureView()

        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 7

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func touchStart() {
        label.textColor = .gray
        backgroundColor = .white
    }

    func didDragOff() {
        label.textColor = .white
        backgroundColor = .clear
    }
}

class HideMeButton: InteractableView, Interactable {
    let label: UILabel = {
        let label = UILabel()

        label.font = Fonts.createBoldSize(20)
        label.textAlignment = .center
        label.text = "Hide me on QuickTutor"
        label.textColor = .white

        return label
    }()

    override func configureView() {
        addSubview(label)
        super.configureView()

        backgroundColor = Colors.purple
        layer.cornerRadius = 7

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func touchStart() {
        alpha = 0.7
    }

    func didDragOff() {
        alpha = 1.0
    }
}

class CloseAccountVC: BaseViewController {
    override var contentView: CloseAccountView {
        return view as! CloseAccountView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func loadView() {
        view = CloseAccountView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func hideAccountAlert() {
        let alert = UIAlertController(title: "Hide Account?", message: "Your account will be hidden from search results. You will still be able to message and have sessions with your existing clients.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            CurrentUser.shared.tutor.isVisible = false
            FirebaseData.manager.updateTutorVisibility(uid: CurrentUser.shared.tutor.uid, status: 1)
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        })
        present(alert, animated: true)
    }

    override func handleNavigation() {
        if touchStartView is ProceedButton {
            if AccountService.shared.currentUserType == .learner {
                if CurrentUser.shared.learner.hasTutor {
                    navigationController?.pushViewController(CloseAccountChoiceVC(), animated: true)
                } else {
                    navigationController?.pushViewController(CloseAccountReasonVC(), animated: true)
                }
            } else {
                navigationController?.pushViewController(CloseAccountChoiceVC(), animated: true)
            }
        } else if touchStartView is CancelButton {
            navigationController?.popViewController(animated: true)
        } else if touchStartView is HideMeButton {
            hideAccountAlert()
        }
    }
}
