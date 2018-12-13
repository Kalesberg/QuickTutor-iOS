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
        field.attributedPlaceholder = NSAttributedString(string: "0.00", attributes: [NSAttributedString.Key.foregroundColor : Colors.gray])
        field.textColor = .white
        return field
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray
        view.layer.cornerRadius = 1
        return view
    }()
    
    let totalLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(12)
        label.text = "Total"
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        return label
    }()
    
    let digitsLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(12)
        label.text = "$0.00"
        label.textColor = .white
        return label
    }()
    
    func setupViews() {
        setupMainView()
        setupDollarSignLabel()
        setupInputField()
        setupSeparator()
        setupTotalLabel()
        setupDigitsLabel()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
        layer.cornerRadius = 4
        layer.borderColor = Colors.gray.cgColor
        layer.borderWidth = 1
    }
    
    func setupDollarSignLabel() {
        addSubview(dollarSignLabel)
        dollarSignLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 13, height: 0)
    }
    
    func setupInputField() {
        addSubview(inputField)
        inputField.anchor(top: topAnchor, left: dollarSignLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        inputField.delegate = self
    }
    
    func setupSeparator() {
        addSubview(separator)
        separator.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 95, width: 2, height: 12)
        addConstraint(NSLayoutConstraint(item: separator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func setupTotalLabel() {
        addSubview(totalLabel)
        totalLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 25, width: 50, height: 14)
    }
    
    func setupDigitsLabel() {
        addSubview(digitsLabel)
        digitsLabel.anchor(top: totalLabel.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 25, width: 50, height: 14)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SessionRequestPaymentInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //        totalLabel.attributedText = totalLabel.attr
        return true
    }
}
