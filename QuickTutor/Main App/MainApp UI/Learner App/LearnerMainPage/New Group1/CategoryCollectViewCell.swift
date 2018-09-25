//
//  CategoryCollectViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    let view: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.navBarColor
        return view
    }()

    let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(14)
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    required override init(frame _: CGRect) {
        super.init(frame: .zero)
        configureView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        roundCorners([.topRight, .topLeft], radius: 7)
        view.layer.cornerRadius = 7
    }

    func configureView() {
        addSubview(view)
        addSubview(label)
        addSubview(imageView)

        applyDefaultShadow()

        applyConstraints()
    }

    func applyConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }
        view.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
            make.top.equalTo(imageView.snp.bottom).inset(5)
        }
        label.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).inset(2)
            make.width.equalToSuperview().inset(4)
        }
    }
}
