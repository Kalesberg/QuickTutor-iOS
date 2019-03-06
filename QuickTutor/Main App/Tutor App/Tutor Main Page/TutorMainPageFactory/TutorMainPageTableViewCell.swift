//
//  TutorMainPageTableViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/23/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class TutorMainPageTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let title: UILabel = {
        let label = UILabel()

        label.sizeToFit()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    let subtitle: UILabel = {
        let label = UILabel()

        label.sizeToFit()
        label.numberOfLines = 0
        label.textColor = Colors.grayText
        label.font = Fonts.createSize(13)
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    let blueView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.purple
        view.clipsToBounds = true
        return view
    }()

    let arrow: UILabel = {
        let label = UILabel()
        label.text = "»"
        label.font = Fonts.createSize(40)
        label.textColor = Colors.purple
        return label
    }()

    func configureTableViewCell() {
        addSubview(title)
        addSubview(subtitle)
        addSubview(blueView)
        addSubview(arrow)

        backgroundColor = Colors.navBarColor
        layer.cornerRadius = 4
        clipsToBounds = true

        applyDefaultShadow()
        applyConstraints()
    }

    func applyConstraints() {
        blueView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(3)
            make.height.centerY.equalToSuperview()
        }
        arrow.snp.makeConstraints { make in
            make.centerY.equalToSuperview().inset(-4)
            make.width.equalToSuperview().multipliedBy(0.1)
            make.right.equalToSuperview()
        }
        title.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.6)
            make.left.equalToSuperview().inset(15)
            make.right.equalTo(arrow.snp.left)
        }
        subtitle.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(1.4)
            make.left.equalToSuperview().inset(15)
            make.right.equalTo(arrow.snp.left)
        }
    }

    func touchStart() {
        alpha = 0.7
    }

    func didDragOff() {
        alpha = 1.0
    }
}

class TutorMainPageWarningTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let title: UILabel = {
        let label = UILabel()

        label.sizeToFit()
        label.numberOfLines = 0
        label.textColor = Colors.yellow
        label.font = Fonts.createBoldSize(18)
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    let subtitle: UILabel = {
        let label = UILabel()

        label.sizeToFit()
        label.numberOfLines = 0
        label.textColor = Colors.grayText
        label.font = Fonts.createSize(13)
        label.adjustsFontSizeToFitWidth = true

        return label
    }()

    let yellowView: UIView = {
        let view = UIView()

        view.backgroundColor = Colors.yellow
        view.clipsToBounds = true

        return view
    }()

    let warningIcon: UIImageView = {
        let imageView = UIImageView()

        return imageView
    }()

    func configureTableViewCell() {
        addSubview(title)
        addSubview(subtitle)
        addSubview(yellowView)
        addSubview(warningIcon)

        backgroundColor = Colors.navBarColor
        layer.cornerRadius = 4
        clipsToBounds = true

        applyDefaultShadow()
        applyConstraints()
    }

    func applyConstraints() {
        yellowView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalTo(3)
            make.height.centerY.equalToSuperview()
        }
        warningIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview().inset(-4)
            make.width.equalToSuperview().multipliedBy(0.1)
            make.right.equalToSuperview()
        }
        title.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.6)
            make.left.equalToSuperview().inset(15)
            make.right.equalTo(warningIcon.snp.left)
        }
        subtitle.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(1.4)
            make.left.equalToSuperview().inset(15)
            make.right.equalTo(warningIcon.snp.left)
        }
    }

    func touchStart() {
        alpha = 0.7
    }

    func didDragOff() {
        alpha = 1.0
    }
}
