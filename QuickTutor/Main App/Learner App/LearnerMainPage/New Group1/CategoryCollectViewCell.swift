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
    
    let shadowView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
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
//        label.adjustsFontSizeToFitWidth = true
//        label.adjustsFontForContentSizeCategory = true
        
        return label
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        
        return imageView
    }()

    func setupViews() {
        setupShadowView()
        setupContainerView()
        setupImageView()
        setupMaskBackgroundView()
        setupLabel()
    }
    
    func setupShadowView() {
        addSubview(shadowView)
        shadowView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(4)
            make.top.equalToSuperview().offset(4)
        }
    }
    
    func setupContainerView() {
        shadowView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupImageView() {
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        shadowView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: .zero, radius: 5)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupViews()
        addShadow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let oldGradientLayer = maskBackgroundView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            oldGradientLayer.removeFromSuperlayer()
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: CGSize(width: containerView.frame.size.width, height: 61))
        gradientLayer.colors = [UIColor.clear,
                                UIColor.black.withAlphaComponent(0.8)].map({$0.cgColor})
        gradientLayer.locations = [0, 1]
        maskBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
