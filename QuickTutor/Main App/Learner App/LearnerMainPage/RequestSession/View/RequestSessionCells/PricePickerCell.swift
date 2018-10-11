//
//  PricePickerCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class RequestSessionPriceCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    let header: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.3882352941, green: 0.3960784314, blue: 0.7647058824, alpha: 1)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.font = Fonts.createSize(15)
        return label
    }()

    let footer: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = Fonts.createLightSize(13)
        label.text = "Although your tutor has a set rate, each individual session can be negotiable."
        label.numberOfLines = 0
        return label
    }()

    let container: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.navBarColor
        view.layer.cornerRadius = 6
        return view
    }()

    var textField: NoPasteTextField = {
        let textField = NoPasteTextField()
        textField.font = Fonts.createBoldSize(32)
        textField.textColor = .white
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        textField.keyboardAppearance = .dark
        textField.tintColor = Colors.tutorBlue
        textField.isUserInteractionEnabled = false
        return textField
    }()

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

    var increasePriceTimer: Timer?
    var decreasePriceTimer: Timer?

    var currentPrice = 5
    var amount: String = "5"

    var delegate: RequestSessionDelegate?

    func configureTableViewCell() {
        contentView.addSubview(header)
        contentView.addSubview(footer)
        contentView.addSubview(container)
        container.addSubview(textField)
        container.addSubview(increaseButton)
        container.addSubview(decreaseButton)

        backgroundColor = Colors.navBarColor
        selectionStyle = .none
        textField.delegate = self

        decreaseButton.addTarget(self, action: #selector(decreasePrice), for: .touchDown)
        decreaseButton.addTarget(self, action: #selector(endDecreasePrice), for: [.touchUpInside, .touchUpOutside])
        increaseButton.addTarget(self, action: #selector(increasePrice), for: .touchDown)
        increaseButton.addTarget(self, action: #selector(endIncreasePrice), for: [.touchUpInside, .touchUpOutside])

        applyConstraints()
    }

    private func updateTextField(_ amount: String) {
        guard let this = Int(amount) else { return }
        guard let number = this as NSNumber? else { return }
        currentPrice = this
        textField.attributedText = NSMutableAttributedString().bold("$\(number)", 32, .white).regular("/hr", 15, .white)
        delegate?.priceDidChange(price: currentPrice)
    }

    @objc func decreasePrice() {
        guard currentPrice > 0 else {
            amount = ""
            return
        }
        decreasePriceTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            guard self.currentPrice > 0 else {
                self.amount = String(self.currentPrice)
                return
            }
            self.currentPrice -= 1
            self.textField.attributedText = NSMutableAttributedString().bold("$\(self.currentPrice)", 32, .white).regular("/hr", 15, .white)
            self.amount = String(self.currentPrice)
            self.delegate?.priceDidChange(price: self.currentPrice)
        }
        decreasePriceTimer?.fire()
    }

    @objc func endDecreasePrice() {
        decreasePriceTimer?.invalidate()
    }

    @objc func increasePrice() {
        guard currentPrice < 1000 else {
            amount = String(currentPrice)
            return
        }
        currentPrice += 1
        textField.attributedText = NSMutableAttributedString().bold("$\(currentPrice)", 32, .white).regular("/hr", 15, .white)
        amount = String(currentPrice)
        delegate?.priceDidChange(price: currentPrice)
        increasePriceTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true, block: { _ in
            guard self.currentPrice < 1000 else {
                self.amount = String(self.currentPrice)
                return
            }
            self.currentPrice += 1
            self.textField.attributedText = NSMutableAttributedString().bold("$\(self.currentPrice)", 32, .white).regular("/hr", 15, .white)
            self.amount = String(self.currentPrice)
            self.delegate?.priceDidChange(price: self.currentPrice)
        })
    }

    @objc func endIncreasePrice() {
        increasePriceTimer?.invalidate()
    }

    func applyConstraints() {
        header.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(20)
            make.left.equalToSuperview().inset(3)
            make.height.equalTo(40)
        }
        container.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.96)
            make.center.equalToSuperview()
            make.height.equalTo(60)
        }
        footer.snp.makeConstraints { make in
            make.top.equalTo(container.snp.bottom)
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview().inset(3)
        }
        increaseButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(17)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        decreaseButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(17)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        textField.snp.makeConstraints { make in
            make.left.equalTo(decreaseButton.snp.right).inset(-10)
            make.right.equalTo(increaseButton.snp.left).inset(-10)
            make.centerY.equalToSuperview()
        }
    }
}

extension RequestSessionPriceCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")

        if string == "" && amount.count == 1 {
            let formattedString = NSMutableAttributedString()

            formattedString
                .bold("$5", 32, .white)
                .regular("  /hr", 15, .white)
            textField.attributedText = formattedString
            amount = ""
            currentPrice = 0
            return false
        }
        if string == "" && amount.count > 0 {
            amount.removeLast()
            updateTextField(amount)
        }

        if string == numberFiltered {
            let temp = (amount + string)
            guard let number = Int(temp), number < 1001 else {
                // showError
                return false
            }
            amount = temp
            updateTextField(amount)
        }
        return false
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        return true
    }
}
