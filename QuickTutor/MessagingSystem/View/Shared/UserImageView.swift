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
        layer.layer.cornerRadius = 7.5
        return layer
    }()

    func setupViews() {
        setupImageView()
        setupOnlineStatusIndicator()
    }

    private func setupImageView() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }

    private func setupOnlineStatusIndicator() {
        addSubview(onlineStatusIndicator)
        onlineStatusIndicator.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
