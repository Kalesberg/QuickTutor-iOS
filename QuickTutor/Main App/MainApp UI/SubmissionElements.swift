//
//  SubmitButton.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class SubmitButton: InteractableView, Interactable {
    var label = CenterTextLabel()

    override func configureView() {
        addSubview(label)
        super.configureView()

        backgroundColor = Colors.purple
        layer.cornerRadius = 20
        label.label.text = "SUBMIT"
        label.label.font = Fonts.createBoldSize(16)

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func constrainSelf() {
        snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(250)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
            make.centerX.equalToSuperview()
        }
    }

    func touchStart() {
        alpha = 0.6
    }

    func didDragOff() {
        alpha = 1
    }
}
