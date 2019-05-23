//
//  SessionRequestPaymentInputView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class SessionRequestPaymentInputView: UIView {
    
    let dollarSignLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(20)
        label.textAlignment = .left
        label.textColor = .white
        label.text = "$"
        return label
    }()
    
    let inputField: UITextField = {
        let field = UITextField()
        field.font = Fonts.createSize(20)
        field.textAlignment = .left
        field.keyboardType = .decimalPad
        field.keyboardAppearance = .dark
        field.tintColor = Colors.gray
        field.attributedPlaceholder = NSAttributedString(string: "0.00", attributes: [.foregroundColor: Colors.gray])
        field.textColor = .white
        return field
    }()
    
    let separator1: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray
        view.layer.cornerRadius = 1
        return view
    }()
    
    let feeLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(15)
        label.textAlignment = .left
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    let separator2: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray
        view.layer.cornerRadius = 1
        return view
    }()
    
    let totalLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(13)
        label.text = "Total"
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        return label
    }()
    
    let digitsLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(13)
        label.text = "$0.00"
        label.textColor = .white
        return label
    }()
    
    func setupViews() {
        setupMainView()
        setupDollarSignLabel()
        setupInputField()
        setupSeparator1()
        setupTotalLabel()
        setupDigitsLabel()
        setupSeparator2()
        setupFeeLabel()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
        layer.cornerRadius = 4
        layer.borderColor = Colors.gray.cgColor
        layer.borderWidth = 1
        layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: .zero, radius: 4)
    }
    
    func setupDollarSignLabel() {
        addSubview(dollarSignLabel)
        dollarSignLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.equalTo(16)
        }
    }
    
    func setupInputField() {
        addSubview(inputField)
        inputField.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.left.equalTo(dollarSignLabel.snp.right).offset(5)
        }
    }
    
    func setupSeparator1() {
        addSubview(separator1)
        separator1.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(inputField.snp.right).offset(10)
            make.height.equalTo(12)
            make.width.equalTo(2)
        }
    }
    
    func setupTotalLabel() {
        addSubview(totalLabel)
        totalLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(50)
        }
    }
    
    func setupDigitsLabel() {
        addSubview(digitsLabel)
        digitsLabel.snp.makeConstraints { make in
            make.top.equalTo(totalLabel.snp.bottom).offset(4)
            make.right.equalTo(totalLabel.snp.right)
            make.width.equalTo(totalLabel.snp.width)
        }
    }
    
    func setupSeparator2() {
        addSubview(separator2)
        separator2.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(totalLabel.snp.left).offset(-10)
            make.size.equalTo(separator1.snp.size)
        }
    }
    
    func setupFeeLabel() {
        addSubview(feeLabel)
        feeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(separator1.snp.right).offset(10)
            make.right.equalTo(separator2.snp.left).offset(10)
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
