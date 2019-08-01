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
        iv.backgroundColor = Colors.newScreenBackground
        iv.clipsToBounds = true
        iv.applyDefaultShadow()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        iv.layer.borderColor = Colors.purple.cgColor
        iv.layer.borderWidth = 1
        return iv
    }()
    
    let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    let imgInfoIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_avatar_user"))
        return imageView
    }()
    
    let lblInfoText: UILabel = {
        let label = UILabel()
        label.text = "Add a photo"
        label.textColor = .white
        label.font = Fonts.createBoldSize(14)
        
        return label
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "• Upload a photo of yourself.\n• You will be able to add more photos later."
        label.textColor = Colors.registrationGray
        label.numberOfLines = 0
        label.font = Fonts.createSize(16)
        return label
    }()
    
    let buttonContainer = UIView()
    
    override func setupViews() {
        super.setupViews()
        setupImageViewButton()
        setupInfoView()
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
    
    private func setupInfoView() {
        addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.center.equalTo(imageView)
        }
        
        infoView.addSubview(imgInfoIcon)
        imgInfoIcon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        infoView.addSubview(lblInfoText)
        lblInfoText.snp.makeConstraints { make in
            make.top.equalTo(imgInfoIcon.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
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
