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
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.newScreenBackground
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    let onlineStatusIndicator: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    func setupViews() {
        setupImageView()
        setupContainerView()
        setupOnlineStatusIndicator()
    }
    
    private func setupImageView() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupContainerView() {
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.size.equalToSuperview().multipliedBy(0.3)
        }
    }
    
    private func setupOnlineStatusIndicator() {
        addSubview(onlineStatusIndicator)
        onlineStatusIndicator.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(2)
            make.left.equalTo(containerView.snp.left).offset(2)
            make.center.equalTo(containerView.snp.center)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.layer.cornerRadius = imageView.frame.size.height / 2
        containerView.layer.cornerRadius = containerView.frame.size.height / 2
        onlineStatusIndicator.layer.cornerRadius = onlineStatusIndicator.frame.size.height / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
