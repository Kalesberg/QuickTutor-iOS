//
//  NewMessageCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/13/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

class ContactCell: UICollectionViewCell {
    
    var user: User!
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .clear
        iv.layer.cornerRadius = 25
        iv.clipsToBounds = true
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.lightGrey
        return view
    }()
    
    func setupViews() {
        setupProfilePic()
        setupUsernameLabel()
        setupLine()
    }
    
    func setupProfilePic() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 10.5, paddingBottom: 5, paddingRight: 0, width: 50, height: 50)
    }
        
    func setupUsernameLabel() {
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupLine() {
        addSubview(separatorLine)
        separatorLine.anchor(top: nil, left: profileImageView.leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    func updateUI(user: User) {
        self.user = user
        usernameLabel.text = user.formattedName
        profileImageView.loadImage(urlString: user.profilePicUrl)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

