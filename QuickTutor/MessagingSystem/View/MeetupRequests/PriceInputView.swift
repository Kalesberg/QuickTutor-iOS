//
//  PriceInputView.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/4/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

protocol PriceInputViewDelegate {
    func priceDidChange(_ price: Double)
}

class PriceInputView: UIView {
    
    var delegate: PriceInputViewDelegate?
    
    var currentPrice = 0.00 {
        didSet {
            let priceString = String(format: "%.2f", currentPrice)
            priceLabel.text = "$\(priceString)"
        }
    }
    
    let decreaseButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "decreaseButton"), for: .normal)
        return button
    }()
    
    let increaseButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "increaseButton"), for: .normal)
        return button
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "$0.00"
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(34)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        setupDecreaseButton()
        setupIncreaseButton()
        setupStackView()
    }
    
    private func setupDecreaseButton() {
        decreaseButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        decreaseButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        decreaseButton.addTarget(self, action: #selector(decreasePrice), for: .touchUpInside)
    }
    
    private func setupIncreaseButton() {
        increaseButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        increaseButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        increaseButton.addTarget(self, action: #selector(increasePrice), for: .touchUpInside)
    }
    
    private func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [decreaseButton, priceLabel, increaseButton])
        stackView.alignment = .center
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 50, paddingBottom: 0, paddingRight: 50, width: 0, height: 0)
    }
    
    @objc func decreasePrice() {
        guard currentPrice != 0 else { return }
        currentPrice -= 1
        delegate?.priceDidChange(currentPrice)
    }
    
    @objc func increasePrice() {
        currentPrice += 1
        delegate?.priceDidChange(currentPrice)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}