//
//  PaymentMethodCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class PaymentMethodCell: UICollectionViewCell {
    let cardIcon: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "cardIcon"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createSize(14)
        label.text = "Payment Method"
        return label
    }()

    let typeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        label.font = Fonts.createSize(14)
        label.text = "VISA"
        return label
    }()
    
    let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.learnerPurple
        return view
    }()
    
    func setupViews() {
        setupCardIcon()
        setupTitleLabel()
        setupTypeLabel()
        setupSeparatorLine()
    }
    
    func setupCardIcon() {
        addSubview(cardIcon)
        cardIcon.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 12, paddingLeft: 0, paddingBottom: 12, paddingRight: 0, width: 30, height: 0)
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: cardIcon.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 150, height: 0)
    }
    
    func setupTypeLabel() {
        addSubview(typeLabel)
        typeLabel.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 0)
    }
    
    func setupSeparatorLine() {
        addSubview(separatorLine)
        separatorLine.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
}

