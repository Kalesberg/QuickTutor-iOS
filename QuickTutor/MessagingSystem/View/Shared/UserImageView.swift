//
//  UserImageView.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/13/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class UserImageView: UIView {
    let imageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 30
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let onlineStatusIndicator: UIView = {
        let layer = UIView()
        layer.layer.cornerRadius = 10
        layer.layer.borderColor = Colors.darkBackground.cgColor
        layer.layer.borderWidth = 2
        return layer
    }()
    
    func setupViews() {
        setupImageView()
        setupOnlineStatusIndicator()
    }
    
    private func setupImageView() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupOnlineStatusIndicator() {
        addSubview(onlineStatusIndicator)
        onlineStatusIndicator.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.size.equalToSuperview().multipliedBy(0.3)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.layer.cornerRadius = imageView.frame.size.height / 2
        onlineStatusIndicator.layer.cornerRadius = onlineStatusIndicator.frame.size.height / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
