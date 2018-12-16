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
    
    let titleBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.darkBackground
        view.layer.borderColor = Colors.gray.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
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

    func setupViews() {
        setupImageView()
        setupTitleBackgroundView()
        setupLabel()
    }
    
    func setupTitleBackgroundView() {
        insertSubview(titleBackgroundView, belowSubview: imageView)
        titleBackgroundView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).inset(5)
            make.bottom.equalToSuperview()
        }
    }
    
    func setupImageView() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(108)
            make.centerX.equalToSuperview()
        }
    }
    
    func setupLabel() {
        addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalTo(titleBackgroundView)
            make.top.equalTo(imageView.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().inset(10)
        }
    }
    
    override func layoutSubviews() {
        roundCorners([.topRight, .topLeft], radius: 4)
        titleBackgroundView.layer.cornerRadius = 4
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
