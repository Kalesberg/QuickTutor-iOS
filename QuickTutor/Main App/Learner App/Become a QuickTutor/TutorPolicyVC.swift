//
//  TutorPolicy.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import FirebaseAuth
import Stripe
import UIKit

class TutorPolicyView: BaseLayoutView {
    let qtTitle: UILabel = {
        var label = UILabel()

        label.font = Fonts.createBoldItalicSize(26)
        label.text = "QuickTutor Agreement"
        label.textColor = .white

        return label
    }()

    let scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false

        return scrollView
    }()

    let scrollViewLabel: UILabel = {
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("Your relationship with QuickTutor\n\n", 15, .white)
            .regular("On QuickTutor, you're an independent tutor in full control of your business. You have the freedom to choose which opportunities to pursue, when you want to tutor, and how much you charge.\n\n", 13, Colors.grayText)
            .bold("Communicate through the app\n\n", 15, .white)
            .regular("The QuickTutor messaging system allows you to communicate and set up tutoring sessions, without having to give away any personal or private information like your phone number or email. Keep your conversations in the messaging system to protect yourself.\n\n", 13, Colors.grayText)
            .bold("The ultimate biz management tool\n\n", 15, .white)
            .regular("With QuickTutor, you'll be able to schedule and facilitate your in-person and online sessions through the app, and recieve instant payments for tutoring. Make sure to keep your sessions through the app to avoid not being paid on time, not being paid at all, or not revieving a rating.", 13, Colors.grayText)

        var label = UILabel()
        label.sizeToFit()
        label.numberOfLines = 0
        label.attributedText = formattedString

        return label
    }()

    let bottomView: UIView = {
        var view = UIView()

        view.backgroundColor = Colors.registrationDark

        return view
    }()

    let agreementView: UIView = {
        var view = UIView()
        view.backgroundColor = Colors.registrationDark

        var label = UILabel()
        view.addSubview(label)
        label.font = Fonts.createSize(14)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = Colors.grayText
        label.text = "By checking the box, you confirm that you have reviewed the document above and you agree to its terms."
        label.numberOfLines = 0
        label.snp.makeConstraints({ make in
            make.left.equalToSuperview().inset(15)
            make.right.equalToSuperview().inset(80)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        })

        return view
    }()

    let checkBox: RegistrationCheckbox = {
        var check = RegistrationCheckbox()

        check.isSelected = false

        return check
    }()

    let tutorAgreementButton: ArrowItem = {
        var item = ArrowItem()

        item.label.text = "Independent Tutor Agreement"
        item.divider.isHidden = true
        item.backgroundColor = Colors.registrationDark

        return item
    }()

    let pleaseReviewLabel: UILabel = {
        var label = UILabel()

        label.textColor = .white
        label.text = "Please review and agree to the document below:"
        label.font = Fonts.createSize(13)

        return label
    }()

    let backButton = RegistrationBackButton()

    override func configureView() {
        addSubview(qtTitle)
        addSubview(bottomView)
        addSubview(agreementView)
        addSubview(pleaseReviewLabel)
        agreementView.addSubview(checkBox)
        addSubview(scrollView)
        scrollView.addSubview(scrollViewLabel)
        addSubview(tutorAgreementButton)
        addSubview(backButton)
        super.configureView()

        applyConstraints()
    }

    override func applyConstraints() {
        super.applyConstraints()

        backButton.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview().inset(DeviceInfo.statusbarHeight)
            }
            make.left.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.1)
            make.width.equalToSuperview().multipliedBy(0.2)
        }

        qtTitle.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }

        bottomView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide.snp.bottom)
            } else {
                make.height.equalTo(0)
            }
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        agreementView.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }

        checkBox.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalTo(agreementView.snp.right).inset(80)
            make.centerY.equalToSuperview()
        }

        tutorAgreementButton.snp.makeConstraints { make in
            make.bottom.equalTo(agreementView.snp.top).inset(-1)
            make.height.equalTo(40)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        pleaseReviewLabel.snp.makeConstraints { make in
            make.bottom.equalTo(tutorAgreementButton.snp.top)
            make.width.equalToSuperview()
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(50)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(qtTitle.snp.bottom).inset(-30)
            make.bottom.equalTo(pleaseReviewLabel.snp.top)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }

        scrollViewLabel.snp.makeConstraints({ make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        })
    }
}

class TutorPolicyVC: BaseViewController {
    override var contentView: TutorPolicyView {
        return view as! TutorPolicyView
    }

    override func loadView() {
        view = TutorPolicyView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.layoutIfNeeded()
        contentView.scrollView.contentSize = CGSize(width: contentView.scrollView.frame.width, height: contentView.scrollViewLabel.frame.height)
        contentView.applyGradient(firstColor: UIColor(hex: "2c467c").cgColor, secondColor: Colors.oldTutorBlue.cgColor, angle: 200, frame: contentView.bounds)
		
		
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func declineButtonAlert() {
        let alertController = UIAlertController(title: "Are You Sure?", message: "All of your progress will be deleted.", preferredStyle: .alert)

        let okButton = UIAlertAction(title: "Ok", style: .destructive) { _ in
            self.navigationController?.popBackToMain()
        }

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in }

        alertController.addAction(okButton)
        alertController.addAction(cancelButton)

        present(alertController, animated: true, completion: nil)
    }

    private func switchToTutorSide(_ completion: @escaping (Bool) -> Void) {
        FirebaseData.manager.fetchTutor(CurrentUser.shared.learner.uid!, isQuery: false) { tutor in
            if let tutor = tutor {
                CurrentUser.shared.tutor = tutor
                Stripe.retrieveConnectAccount(acctId: tutor.acctId, { error, account in
                    if let error = error {
                        AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                        completion(false)
                    } else if let account = account {
                        CurrentUser.shared.connectAccount = account
                        completion(true)
                    } else {
                        completion(false)
                    }
                })
            } else {
                completion(false)
            }
        }
    }

    private func createConnectAccount(_ completion: @escaping (Bool) -> Void) {
        Stripe.createConnectAccountToken(ssn: TutorRegistration.ssn!, line1: TutorRegistration.line1, city: TutorRegistration.city, state: TutorRegistration.state, zipcode: TutorRegistration.zipcode) { token, error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
            } else if let token = token {
                Stripe.createConnectAccount(bankAccountToken: TutorRegistration.bankToken!, connectAccountToken: token, { error, value in
                    if let error = error {
                        AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                        return completion(false)
                    }
                    guard let value = value, value.prefix(4) == "acct" else { return completion(false) }
                    TutorRegistration.acctId = value
                    Tutor.shared.initTutor(completion: { error in
                        completion(error == nil)
                    })
                })
            }
        }
    }

    private func bankErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okButton = UIAlertAction(title: "Ok", style: .destructive) { _ in }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in }

        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
    }

    private func accepted() {
        displayLoadingOverlay()
        createConnectAccount { success in
            if success {
                self.switchToTutorSide({ success in
                    if success {
                        CurrentUser.shared.learner.isTutor = true
                        AccountService.shared.currentUserType = .tutor
                        self.navigationController?.pushViewController(TutorMainPage(), animated: true)
                        let endIndex = self.navigationController?.viewControllers.endIndex
                        self.navigationController?.viewControllers.removeFirst(endIndex! - 1)
                    } else {
                        AlertController.genericErrorAlert(self, title: "Unable to Create Account", message: "Please verify your information was correct.")
                    }
                    self.dismissOverlay()
                })
            } else {
                AlertController.genericErrorAlert(self, title: "Unable to Create Account", message: "Please verify your information was correct.")
                self.dismissOverlay()
            }
        }
    }

    private func declined() {
        declineButtonAlert()
    }

    override func handleNavigation() {
        if touchStartView == contentView.tutorAgreementButton {
            guard let url = URL(string: "https://www.quicktutor.com/ita.pdf") else { return }
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:]) { _ in }
            } else {
                UIApplication.shared.openURL(url)
            }
        } else if touchStartView == contentView.checkBox {
            accepted()
        } else if touchStartView == contentView.backButton {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension NSMutableAttributedString {
    @discardableResult func regular(_ text: String, _ size: CGFloat, _ color: UIColor, _ spacing: CGFloat = 0) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Lato-Regular", size: size)!, .foregroundColor: color]
        let string = NSMutableAttributedString(string: text, attributes: attrs)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        string.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, string.length))

        append(string)

        return self
    }

    @discardableResult func bold(_ text: String, _ size: CGFloat, _ color: UIColor, _ spacing: CGFloat = 0) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Lato-Bold", size: size)!, .foregroundColor: color]
        let string = NSMutableAttributedString(string: text, attributes: attrs)
        append(string)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        string.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, string.length))

        return self
    }
}
