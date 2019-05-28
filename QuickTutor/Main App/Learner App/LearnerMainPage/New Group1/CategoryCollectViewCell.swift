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
        view.backgroundColor = .clear
        return view
    }()
    
    let bgView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = Colors.newBackground
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
        return imageView
    }()

    func setupViews() {
        setupShadowView()
        setupBgView()
        setupImageView()
        setupLabel()
    }
    
    func setupShadowView() {
        addSubview(shadowView)
        shadowView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-4)
            make.height.equalToSuperview().offset(-8)
        }
    }
    
    private func setupBgView() {
        shadowView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupImageView() {
        bgView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(126)
            make.centerX.equalToSuperview()
        }
    }
    
    func setupLabel() {
        bgView.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
    }
    
    private func addShadow() {
        shadowView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: .zero, radius: 4)
    }
    
    override func layoutSubviews() {
        bgView.layer.cornerRadius = 4
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
