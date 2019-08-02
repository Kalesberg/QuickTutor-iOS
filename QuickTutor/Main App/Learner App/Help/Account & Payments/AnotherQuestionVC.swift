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
    
    var submitButton = SubmitButton()
    
    var textView: MessageTextView = {
        let field = MessageTextView()
        field.layer.borderColor = UIColor(red: 44/255, green: 44/255, blue: 58/255, alpha: 1).cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 4
        field.placeholderLabel.text = "Start type..."
        field.tintColor = Colors.purple
        field.font = Fonts.createSize(14)
        field.textColor = .white
        field.keyboardAppearance = .dark
        field.autocorrectionType = .no
        return field
    }()
    
    override func configureView() {
        addKeyboardView()
        addSubview(anotherQuestionBody)
        addSubview(container)
        container.addSubview(textView)
        
        container.addSubview(submitButton)
        submitButton.layer.cornerRadius = 4
        
        super.configureView()

        header.text = "I have another question"

        anotherQuestionBody.text = "If you’ve run into a problem we haven’t mentioned, please leave us a note of your issue and we’ll get back to you as soon as possible via email. "
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

        textView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(70)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.5)
        }

        submitButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.equalTo(180)
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
        navigationItem.title = "I have another question"

        contentView.textView.becomeFirstResponder()
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
            if contentView.textView.text!.count > 5 {
                postQuestion()
            }
        }
    }

    private func postQuestion() {
        FirebaseData.manager.updateAdditionalQuestions(value: ["question": contentView.textView.text!], completion: { error in
            if let error = error {
                print("try again! ", error)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
}
