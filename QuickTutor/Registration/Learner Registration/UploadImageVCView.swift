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
    
    let takePhotoButton: DimmableButton = {
        let button = DimmableButton()
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.setTitle("  Take a photo", for: .normal)
        button.setImage(UIImage(named: "camera"), for: .normal)
        return button
    }()
    
    let line: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 0.5
        return view
    }()
    
    let choosePhotoButton: DimmableButton = {
        let button = DimmableButton()
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.setTitle("  Camera roll", for: .normal)
        button.setImage(UIImage(named: "cameraRollIcon"), for: .normal)
        return button
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
        setupTakePhotoButton()
        setupLine()
        setupChoosePhotoButton()
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
    
    func setupTakePhotoButton() {
        addSubview(takePhotoButton)
        takePhotoButton.anchor(top: imageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 75, paddingBottom: 0, paddingRight: 0, width: 95, height: 20)
    }
    
    func setupLine() {
        addSubview(line)
        line.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 1, height: 8)
        addConstraint(NSLayoutConstraint(item: line, attribute: .centerY, relatedBy: .equal, toItem: takePhotoButton, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: line, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupChoosePhotoButton() {
        addSubview(choosePhotoButton)
        choosePhotoButton.anchor(top: imageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 75, width: 95, height: 20)
    }
    
    func setupInfoLabel() {
        addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(75)
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.height.equalTo(44)
        }
    }
    
    override func updateTitleLabel() {
        titleLabel.text = "Alright, time to add a photo!"
        titleLabelHeightAnchor?.constant = 30
        layoutIfNeeded()
    }
    
}
