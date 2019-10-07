//
//  QTTutorDiscoverTipCollectionViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/13/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTTutorDiscoverTipCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    var tip: QTNewsModel!
    var cellWidth: CGFloat = 0
    
    static var reuseIdentifier: String {
        return String(describing: QTTutorDiscoverTipCollectionViewCell.self)
    }
    
    // MARK: - Functions
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
        imageView.layer.cornerRadius = 5
        
        return imageView
    }()
    
    func setupViews() {
        setupContainerView()
        setupImageView()
        setupMaskBackgroundView()
        setupLabel()
    }
    
    func setupContainerView() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().offset(-8)
        }
    }
    
    func setupImageView() {
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    func setupMaskBackgroundView() {
        containerView.addSubview(maskBackgroundView)
        maskBackgroundView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(54)
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: cellWidth, height: 54)
        gradientLayer.colors = [UIColor.clear,
                                UIColor.black.withAlphaComponent(0.8)].map({$0.cgColor})
        gradientLayer.locations = [0, 1]
        maskBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
        maskBackgroundView.layer.cornerRadius = 5
        maskBackgroundView.clipsToBounds = true
    }
    
    func setupLabel() {
        maskBackgroundView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    private func addShadow() {
        containerView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: .zero, radius: 5)
        containerView.layer.cornerRadius = 5
    }
    
    func setSkeletonView() {
        isSkeletonable = true
        contentView.isSkeletonable = true
        containerView.isSkeletonable = true
        maskBackgroundView.isSkeletonable = true
        
        label.isHidden = true
        imageView.isHidden = true
    }
    
    func setData(tip: QTNewsModel) {
        if isSkeletonActive {
            hideSkeleton()
        }
        label.text = tip.title
        imageView.setImage(url: tip.image)
        label.isHidden = false
        imageView.isHidden = false
    }
    
    
    // MARK: - Actions
    
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        cellWidth = (UIScreen.main.bounds.size.width - 55) / 2
        setupViews()
        setSkeletonView()
        
        addShadow()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
