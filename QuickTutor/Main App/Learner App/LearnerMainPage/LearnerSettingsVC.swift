//
//  Settings.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import SnapKit
import UIKit

class SettingsItem: BaseView {
    var label = UILabel()
    var divider = UIView()

    override func configureView() {
        addSubview(label)
        addSubview(divider)
        super.configureView()

        label.textColor = .white
        label.numberOfLines = 0

        divider.backgroundColor = Colors.divider
    }

    override func applyConstraints() {
        divider.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(1.0)
        }
    }
}

class SettingsInteractableItem: SettingsItem, InteractableBackground {
    var backgroundComponent = ViewComponent()

    override func configureView() {
        super.configureView()
        isUserInteractionEnabled = true
        addBackgroundView()
    }
}

class ArrowItem: SettingsInteractableItem {
    var arrow = UILabel()

    override func configureView() {
        addSubview(arrow)
        super.configureView()

        arrow.font = Fonts.createBoldSize(30)
        arrow.textColor = .white
        arrow.text = "›"

        label.font = Fonts.createSize(15)

        applyConstraints()
    }

    override func applyConstraints() {
        super.applyConstraints()

        label.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.centerY.equalToSuperview()
        }

        arrow.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalTo(30)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview().inset(-4)
        }
    }
}
