//
//  AnotherQuestion.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class AnotherQuestionView: MainLayoutHeader, Keyboardable {
    var keyboardComponent = ViewComponent()
    var anotherQuestionBody = SectionBody()

    var container = UIView()
    var textField = NoPasteTextField()
    var line = UIView()
    var submitButton = SubmitButton()

    override func configureView() {
        addKeyboardView()
        addSubview(anotherQuestionBody)
        addSubview(container)
        container.addSubview(textField)
        container.addSubview(line)
        container.addSubview(submitButton)
        super.configureView()

        title.label.text = "Help"
        header.text = "I have another question"

        anotherQuestionBody.text = "If you’ve run into a problem we haven’t mentioned, please leave us a note of your issue and we’ll get back to you as soon as possible via email. "

        textField.tintColor = Colors.learnerPurple
        textField.font = Fonts.createSize(20)
        textField.isEnabled = true
        textField.textColor = .white

        line.backgroundColor = Colors.registrationDark
    }

    override func applyConstraints() {
        super.applyConstraints()

        anotherQuestionBody.constrainSelf(top: header.snp.bottom)

        container.snp.makeConstraints { make in
            make.top.equalTo(anotherQuestionBody.snp.bottom)
            make.width.equalTo(anotherQuestionBody)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(keyboardView.snp.top)
        }

        textField.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.5)
        }

        line.snp.makeConstraints { make in
            make.bottom.equalTo(textField).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(1)
            make.centerX.equalToSuperview()
        }

        submitButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(250)
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.centerX.equalToSuperview()
        }
    }
}

class AnotherQuestionVC: BaseViewController {
    override var contentView: AnotherQuestionView {
        return view as! AnotherQuestionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.textField.becomeFirstResponder()
    }

    override func loadView() {
        view = AnotherQuestionView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func handleNavigation() {
        if touchStartView == contentView.submitButton {
            if contentView.textField.text!.count > 5 {
                postQuestion()
            }
        }
    }

    private func postQuestion() {
        FirebaseData.manager.updateAdditionalQuestions(value: ["question": contentView.textField.text!], completion: { error in
            if let error = error {
                print("try again! ", error)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
}
