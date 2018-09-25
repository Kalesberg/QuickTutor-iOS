//
//  NewMessageHeader.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/6/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class NewMessageHeader: UICollectionReusableView {
    let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Connection Requests"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()

    let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.learnerPurple
        view.layer.cornerRadius = 2
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateUI(text: String) {
        headerLabel.text = text
        headerLabel.widthAnchor.constraint(equalToConstant: (headerLabel.text?.estimateFrameForFontSize(20).width)! + 20).isActive = true
    }

    func setupViews() {
        setupHeaderLabel()
        setupLine()
        backgroundColor = Colors.darkBackground
    }

    func setupHeaderLabel() {
        addSubview(headerLabel)
        headerLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 10.5, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
    }

    func setupLine() {
        addSubview(separatorLine)
        separatorLine.anchor(top: headerLabel.bottomAnchor, left: headerLabel.leftAnchor, bottom: nil, right: headerLabel.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 4)
    }
}
