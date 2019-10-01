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
    
    static var reuseIdentifier: String {
        return String(describing: CategoryCollectionViewCell.self)
    }
    
    let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    let maskBackgroundView: UIView = {
        let view = UIView()
        return view
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSemiBoldSize(17)
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        
        return label
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRadius([.topLeft, .topRight], radius: 5)
        return imageView
    }()

    func setupViews() {
        setupContainerView()
        setupImageView()
        setupMaskBackgroundView()
        setupLabel()
    }
    
    func setupContainerView() {
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-8)
            make.height.equalToSuperview().offset(-8)
        }
    }
    
    func setupImageView() {
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(172)
            make.centerX.equalToSuperview()
        }
    }
    
    func setupMaskBackgroundView() {
        containerView.addSubview(maskBackgroundView)
        maskBackgroundView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(61)
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 122, height: 61)
        gradientLayer.colors = [UIColor.clear,
                                UIColor.black.withAlphaComponent(0.8)].map({$0.cgColor})
        gradientLayer.locations = [0, 1]
        maskBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
        maskBackgroundView.cornerRadius([.topLeft, .topRight], radius: 5)
        maskBackgroundView.clipsToBounds = true
    }
    
    func setupLabel() {
        maskBackgroundView.addSubview(label)
        label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-5)
        }
    }
    
    private func addShadow() {
        containerView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: .zero, radius: 5)
        containerView.layer.cornerRadius = 5
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupViews()
        addShadow()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
