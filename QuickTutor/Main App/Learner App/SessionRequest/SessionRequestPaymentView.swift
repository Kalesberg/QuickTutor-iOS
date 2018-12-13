//
//  SessionRequestPaymentView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol SessionRequestPaymentViewDelegate: class {
    func sessionRequestPaymentView(_ paymentView: SessionRequestPaymentView, didEnter price: Double)
}

class SessionRequestPaymentView: BaseSessionRequestViewSection {
    
    weak var delegate: SessionRequestPaymentViewDelegate?
    
    let paymentTypeView: MockCollectionViewCell = {
        let cell = MockCollectionViewCell()
        cell.primaryButton.setTitle("Per hour", for: .normal)
        cell.secondaryButton.setTitle("Per session", for: .normal)
        cell.titleLabel.text = "Type of payment"
        cell.titleLabel.font = Fonts.createSize(14)
        cell.numberOfButtons = 2
        return cell
    }()
    
    let paymentInputView: SessionRequestPaymentInputView = {
        let view = SessionRequestPaymentInputView()
        return view
    }()
    
    let minimumPriceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "There is a $5.00 minimum to every session"
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = Fonts.createBoldSize(10)
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        setupPaymentTypeView()
        setupPaymentInputView()
        setupMinimumPriceLabel()
        titleLabel.text = "Price"
    }
    
    func setupPaymentTypeView() {
        addSubview(paymentTypeView)
        paymentTypeView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        paymentTypeView.delegate = self
    }
    
    func setupPaymentInputView() {
        addSubview(paymentInputView)
        paymentInputView.anchor(top: paymentTypeView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 66)
        paymentInputView.inputField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setupMinimumPriceLabel() {
        addSubview(minimumPriceLabel)
        minimumPriceLabel.anchor(top: paymentInputView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 12)
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        guard let text = sender.text, text != "" else {
            delegate?.sessionRequestPaymentView(self, didEnter: 0)
            return
        }
        let price = Double(sender.text!)!
        delegate?.sessionRequestPaymentView(self, didEnter: price)
    }
}

extension SessionRequestPaymentView: MockCollectionViewCellDelegate {
    func mockCollectionViewCellDidSelectPrimaryButton(_ cell: MockCollectionViewCell) {
        textFieldDidChange(paymentInputView.inputField)
    }
    
    func mockCollectionViewCellDidSelectSecondaryButton(_ cell: MockCollectionViewCell) {
        textFieldDidChange(paymentInputView.inputField)
    }
}
