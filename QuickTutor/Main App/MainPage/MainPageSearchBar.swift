//
//  MainPageSearchBar.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/23/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class SearchBar: BaseView, Interactable {
    var searchIcon = UIImageView()
    var searchLabel = CenterTextLabel()

    override func configureView() {
        addSubview(searchIcon)
        addSubview(searchLabel)

        backgroundColor = .white
        layer.cornerRadius = 12

        searchIcon.image = UIImage(named: "navbar-search")
        searchIcon.scaleImage()

        searchLabel.label.text = "Search"
        searchLabel.label.font = Fonts.createSize(18)
        searchLabel.label.textColor = UIColor(red: 128 / 255, green: 128 / 255, blue: 128 / 255, alpha: 1.0)
        searchLabel.applyConstraints()

        applyConstraints()
    }

    override func applyConstraints() {
        searchIcon.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.18)
            make.height.equalToSuperview().multipliedBy(0.6)
            make.centerY.equalToSuperview()
        }
        searchLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
