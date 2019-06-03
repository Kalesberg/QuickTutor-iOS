//
//  UploadImageVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/15/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class UploadImageVCView: BaseRegistrationView {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = Colors.gray
        iv.clipsToBounds = true
        iv.tag = 1
        iv.applyDefaultShadow()
        if #available(iOS 11.0, *) {
            iv.adjustsImageSizeForAccessibilityContentSizeCategory = true
        }
        iv.image = UIImage(named: "uploadImageDefaultImage")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "· Upload a photo of yourself.\n· You will be able to add more photos later."
        label.textColor = Colors.registrationGray
        label.numberOfLines = 0
        label.font = Fonts.createSize(16)
        return label
    }()
    
    let buttonContainer = UIView()
    
    override func setupViews() {
        super.setupViews()
        setupImageViewButton()
        setupInfoLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.frame.size.height / 2
    }
    
    func setupImageViewButton() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.equalTo(215)
            make.height.equalTo(215)
            make.top.equalTo(titleLabel.snp.bottom).offset(80)
            make.centerX.equalToSuperview()
        }
    }
    
    func setupInfoLabel() {
        addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.right.lessThanOrEqualToSuperview().offset(-30)
            make.bottomMargin.equalToSuperview().offset(-100)
        }
    }
    
    override func updateTitleLabel() {
        titleLabel.text = "Alright, time to add a photo!"
    }
    
}
