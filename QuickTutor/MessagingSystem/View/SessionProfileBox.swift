//
//  SessionProfileBox.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class SessionProfileBox: UIView {
    
    let boundingBox: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.navBarColor
        view.layer.cornerRadius = 4
        return view
    }()
    
    let imageView: CustomImageView = {
        let iv = CustomImageView()
        iv.layer.cornerRadius = 4
        iv.backgroundColor = .clear
        iv.clipsToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createSize(16)
        return label
    }()
    
    func setupViews() {
        setupBoundingBox()
        setupImageView()
        setupNameLabel()
    }
    
    func setupBoundingBox() {
        addSubview(boundingBox)
        boundingBox.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupImageView() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 13.5, paddingBottom: 0, paddingRight: 13.5, width: 0, height: 0)
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 1, constant: 0))
    }
    
    func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: imageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func updateUI(uid: String) {
        guard let myUid = Auth.auth().currentUser?.uid, uid != myUid else {
            DataService.shared.getStudentWithId(uid) { (userIn) in
                guard let user = userIn else { return }
                self.nameLabel.text = user.formattedName.capitalized
                self.imageView.sd_setImage(with: user.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
            }
            return
        }
        
        DataService.shared.getUserOfOppositeTypeWithId(uid) { (userIn) in
            guard let user = userIn else { return }
            self.nameLabel.text = user.formattedName.capitalized
            self.imageView.sd_setImage(with: user.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
