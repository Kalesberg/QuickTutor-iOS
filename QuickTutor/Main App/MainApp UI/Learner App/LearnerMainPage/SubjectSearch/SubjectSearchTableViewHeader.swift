//
//  SubjectSearchTableViewHeader.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/30/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class SubjectSearchTableViewHeader: BaseView {
    let title: UILabel = {
        let label = UILabel()
        label.text = "Quick Search"
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)
        label.textAlignment = .left
        return label
    }()

    let subtitle: UILabel = {
        let label = UILabel()
        label.text = "Search a variety of tutors within any subcategory"
        label.textColor = .white
        label.font = Fonts.createLightSize(14)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    override func configureView() {
        addSubview(title)
        addSubview(subtitle)

        backgroundColor = Colors.backgroundDark

        applyConstraints()
    }

    override func applyConstraints() {
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(30)
        }
        subtitle.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(20)
        }
    }
}
