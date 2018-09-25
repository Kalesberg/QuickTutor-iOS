//
//  TipAmountCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TipAmountCell: UICollectionViewCell {
    let button: DimmableButton = {
        let button = DimmableButton()
        button.setTitleColor(Colors.learnerPurple, for: .normal)
        button.titleLabel?.font = Fonts.createSize(14)
        button.backgroundColor = .white
        button.setTitle("$6", for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = false
        button.layer.cornerRadius = 21
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        button.isUserInteractionEnabled = false
        return button
    }()

    override var isSelected: Bool {
        didSet {
            if isSelected {
                button.backgroundColor = Colors.learnerPurple
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .white
                button.setTitleColor(Colors.learnerPurple, for: .normal)
            }
        }
    }

    func setupViews() {
        addButton()
    }

    func addButton() {
        addSubview(button)
        button.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
