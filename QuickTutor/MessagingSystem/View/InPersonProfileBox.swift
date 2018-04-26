//
//  InPersonProfileBox.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/23/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class InPersonProfileBox: SessionProfileBox {
    
    let infoBox: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.navBarColor
        view.layer.cornerRadius = 4
        return view
    }()
    
    let subjectLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createSize(16)
        label.text = "Botany"
        return label
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createSize(12)
        label.text = "Length: 120 mins, $17.00 / hr"
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        setupInfoBox()
        setupSubjectLabel()
        setupInfoLabel()
    }
    
    override func setupImageView() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 115)
        imageView.layer.cornerRadius = 57.5
    }
    
    override func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.anchor(top: imageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    }
    
    func setupInfoBox() {
        addSubview(infoBox)
        infoBox.anchor(top: nameLabel.bottomAnchor, left: boundingBox.leftAnchor, bottom: nil, right: boundingBox.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 80)
    }
    
    func setupSubjectLabel() {
        infoBox.addSubview(subjectLabel)
        subjectLabel.anchor(top: infoBox.topAnchor, left: infoBox.leftAnchor, bottom: nil, right: infoBox.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    }
    
    func setupInfoLabel() {
        infoBox.addSubview(infoLabel)
        infoLabel.anchor(top: subjectLabel.bottomAnchor, left: infoBox.leftAnchor, bottom: infoBox.bottomAnchor, right: infoBox.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
    }
    
}

