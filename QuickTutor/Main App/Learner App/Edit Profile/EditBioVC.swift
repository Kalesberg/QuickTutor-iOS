//
//  EditBio.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/17/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import Foundation
import UIKit

class EditBioTextView: BaseView {
    let textView: UITextView = {
        let textView = UITextView()

        textView.font = Fonts.createSize(20)
        textView.keyboardAppearance = .dark
        textView.textColor = .white
        textView.tintColor = .white
        textView.backgroundColor = .clear
        textView.returnKeyType = .default
        textView.font = Fonts.createSize(18)

        return textView
    }()

    override func configureView() {
        addSubview(textView)

        if AccountService.shared.currentUserType == .learner {
            textView.text = CurrentUser.shared.learner.bio
        } else if AccountService.shared.currentUserType == .tutor {
            if CurrentUser.shared.tutor != nil {
                textView.text = CurrentUser.shared.tutor.tBio
            } else {
                print("does not exist")
            }
        }
        applyConstraints()
    }

    override func applyConstraints() {
        textView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.left.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(30)
        }
    }
}

