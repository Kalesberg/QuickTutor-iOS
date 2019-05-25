//
//  BankManagerCollectionViewCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/25/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SwipeCellKit

class BankManagerCollectionViewCell: SwipeCollectionViewCell {
    
    let bankIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "bankIcon")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = .white
        return iv
    }()
    
    let bankName: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.font = Fonts.createBlackSize(14)
        label.textColor = .white
        return label
    }()
    
    let accountLast4: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.font = Fonts.createBlackSize(14)
        label.textColor = .white
        return label
    }()
    
    let defaultBank: UILabel = {
        let label = UILabel()
        label.text = "Default"
        label.font = Fonts.createBoldSize(14)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.backgroundColor = Colors.purple
        label.isHidden = true
        label.clipsToBounds = true
        return label
    }()
    
    var bankNameLabelWidthAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupMainView()
        setupBankIcon()
        setupBankNameLabel()
        setupBankAccountNumberLabel()
        setupDefaultBankLabel()
    }
    
    func setupMainView() {
        contentView.backgroundColor = Colors.darkBackground
        contentView.layer.borderColor = Colors.gray.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 4
    }
    
    func setupBankIcon() {
        contentView.addSubview(bankIcon)
        bankIcon.anchor(top: nil, left: contentView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        addConstraint(NSLayoutConstraint(item: bankIcon, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func setupBankNameLabel() {
        contentView.addSubview(bankName)
        bankName.anchor(top: contentView.topAnchor, left: bankIcon.rightAnchor, bottom: contentView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        bankNameLabelWidthAnchor = bankName.widthAnchor.constraint(equalToConstant: 80)
        bankNameLabelWidthAnchor?.isActive = true
        layoutIfNeeded()
    }
    
    func setupBankAccountNumberLabel() {
        contentView.addSubview(accountLast4)
        accountLast4.anchor(top: contentView.topAnchor, left: bankName.rightAnchor, bottom: contentView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 60, height: 0)
    }
    
    func setupDefaultBankLabel() {
        contentView.addSubview(defaultBank)
        defaultBank.anchor(top: nil, left: nil, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 70, height: 30)
        addConstraint(NSLayoutConstraint(item: defaultBank, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func updateUI(_ bank: ExternalAccountsData) {
        bankName.text = bank.bank_name
        accountLast4.text = "•••• \(bank.last4)"
        defaultBank.isHidden = !bank.default_for_currency
        bankIcon.tintColor = bank.default_for_currency ? Colors.purple : UIColor.white
        let anchorWidth = bank.bank_name?.estimateFrameForFontSize(14).width ?? 40
        bankNameLabelWidthAnchor?.constant = anchorWidth + 5
        layoutIfNeeded()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
