//
//  SubjectCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class SubjectCollectionViewCell: UICollectionViewCell {
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createSize(15)
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    required override init(frame _: CGRect) {
        super.init(frame: .zero)
        configureView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureView() {
        addSubview(imageView)
        addSubview(label)

        contentView.layer.cornerRadius = 5

        applyConstraints()
    }

    func applyConstraints() {
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(-10)
            if UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480 {
                make.height.width.equalToSuperview().multipliedBy(0.5)
            } else {
                make.height.width.equalToSuperview().multipliedBy(0.55)
            }
        }
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().inset(2)
            make.centerX.equalToSuperview()
        }
    }
}
