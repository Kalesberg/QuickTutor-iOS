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
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
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
        setupContainerView()
        setupBankIcon()
        setupBankNameLabel()
        setupBankAccountNumberLabel()
        setupDefaultBankLabel()
    }
    
    func setupMainView() {
        containerView.backgroundColor = Colors.newScreenBackground
        containerView.layer.borderColor = Colors.gray.cgColor
        containerView.layer.borderWidth = 1
        containerView.layer.cornerRadius = 4
    }
    
    private func setupContainerView() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview()
        }
    }
    
    func setupBankIcon() {
        containerView.addSubview(bankIcon)
        bankIcon.anchor(top: nil, left: containerView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        addConstraint(NSLayoutConstraint(item: bankIcon, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func setupBankNameLabel() {
        containerView.addSubview(bankName)
        bankName.anchor(top: containerView.topAnchor, left: bankIcon.rightAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        bankNameLabelWidthAnchor = bankName.widthAnchor.constraint(equalToConstant: 80)
        bankNameLabelWidthAnchor?.isActive = true
        layoutIfNeeded()
    }
    
    func setupBankAccountNumberLabel() {
        containerView.addSubview(accountLast4)
        accountLast4.anchor(top: containerView.topAnchor, left: bankName.rightAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 60, height: 0)
    }
    
    func setupDefaultBankLabel() {
        containerView.addSubview(defaultBank)
        defaultBank.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 70, height: 30)
        addConstraint(NSLayoutConstraint(item: defaultBank, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func updateUI(_ bank: ExternalAccountsData) {
        bankName.text = bank.bank_name
        accountLast4.text = "•••• \(bank.last4)"
        defaultBank.isHidden = !bank.default_for_currency
        bankIcon.tintColor = bank.default_for_currency ? Colors.purple : UIColor.white
        let anchorWidth = bank.bank_name?.estimateFrameForFontSize(14, extendedWidth: true).width ?? 40
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
