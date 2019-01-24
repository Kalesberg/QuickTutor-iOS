//
//  AdjustFiltersCollectViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class ResetFiltersButton: InteractableView, Interactable {
    let resetButton: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(18)
        label.textColor = .white
        label.text = "Reset Filters"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    override func configureView() {
        addSubview(resetButton)
        super.configureView()

        backgroundColor = Colors.purple
        layer.cornerRadius = resetButton.frame.height / 2
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false

        applyConstraints()
    }

    override func applyConstraints() {
        resetButton.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        }
    }

    func touchStart() {
        alpha = 0.6
    }

    func didDragOff() {
        alpha = 1.0
    }
}

class NoResultsView: InteractableView, Interactable {
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(45)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    override func configureView() {
        addSubview(label)
        super.configureView()

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.5)
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        }
    }
}
