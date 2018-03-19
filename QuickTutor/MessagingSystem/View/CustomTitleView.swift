//
//  File.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/2/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class CustomTitleView: UIView {
    
    var user: User!
    
    let imageView: UserImageView = {
        let iv = UserImageView()
        iv.imageView.layer.cornerRadius = 19
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    
    let activeLabel: UILabel = {
        let label = UILabel()
        label.text = "Active 1 ago"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func updateUI(user: User) {
        self.user = user
        updateOnlineStatusIndicator()
        titleLabel.text = user.username
    }
    
    func setupViews() {
        setupImageView()
        setupTitleView()
        setupActiveLabel()
    }
    
    private func setupImageView() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 38, height: 38)
    }
    
    private func setupTitleView() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: imageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    }
    
    private func setupActiveLabel() {
        addSubview(activeLabel)
        activeLabel.anchor(top: titleLabel.bottomAnchor, left: imageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 2, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 12)
    }
    
    private func updateOnlineStatusIndicator() {
        imageView.onlineStatusIndicator.backgroundColor = user.isOnline ? .green : .red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
