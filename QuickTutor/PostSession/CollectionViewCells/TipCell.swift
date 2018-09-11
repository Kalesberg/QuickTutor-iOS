//
//  TipCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Stripe


class TipCell : BasePostSessionCell, CustomTipPresenter {
	
	let tipContainer : UIView = {
		let view = UIView()
		view.backgroundColor = Colors.navBarColor
		return view
	}()
	
	let tipOption0 : UIButton = {
		let button = UIButton()
		
		button.backgroundColor = Colors.learnerPurple
		button.setTitle("No Tip", for: .normal)
		button.titleLabel?.font = Fonts.createSize(15)
		button.tag = 0
		
		return button
	}()
	let tipOption1 : UIButton = {
		let button = UIButton()
		
		button.backgroundColor = Colors.learnerPurple
		button.setTitle("$2", for: .normal)
		button.titleLabel?.font = Fonts.createSize(15)
		button.tag = 1

		return button
	}()
	
	let tipOption2 : UIButton = {
		let button = UIButton()
		
		button.backgroundColor = Colors.learnerPurple
		button.setTitle("$4", for: .normal)
		button.titleLabel?.font = Fonts.createSize(15)
		button.tag = 2

		return button
	}()
	
	let tipOption3 : UIButton = {
		let button = UIButton()
		
		button.backgroundColor = Colors.learnerPurple
		button.setTitle("$6", for: .normal)
		button.titleLabel?.font = Fonts.createSize(15)
		button.tag = 3
		
		return button
	}()
	
	let tipOption4 : UIButton = {
		let button = UIButton()
		
		button.backgroundColor = Colors.learnerPurple
		button.setTitle("Custom", for: .normal)
		button.setTitleColor(Colors.selectedPurple, for: .selected)
		button.titleLabel?.font = Fonts.createSize(18)
		button.titleLabel?.adjustsFontSizeToFitWidth = true
		button.tag = 4
		
		return button
	}()
	
	let totalLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = Colors.learnerPurple
		label.textAlignment = .center
		label.font = Fonts.createBoldSize(18)
		label.text = "Total: $18.00"
		
		return label
	}()
	
	lazy var buttons = [tipOption0, tipOption1, tipOption2, tipOption3, tipOption4]
	
	lazy var stackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [tipOption0, tipOption1, tipOption2, tipOption3, tipOption4])
		
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
		stackView.contentMode = .scaleAspectFill
		stackView.spacing = 10
		
		return stackView
	}()
	
	var customTipModal: CustomTipModal?
	
	var amountToTip = 0.0 {
		didSet {
			totalLabel.text = "Total: $" + String(format: "%.2f", amountToTip + (total / 100))
			delegate?.didSelectTipPercentage(tipAmount: Int(amountToTip))
		}
	}
	
	var delegate : PostSessionInformationDelegate?
	var selectedButton : Int? = nil
	
	var total : Double = 0.0 {
		didSet {
			totalLabel.text = "Total: $" + String(format: "%.2f", total / 100)
		}
	}

	var buttonAmounts = [0, 2, 4, 6]
	var customer : STPCustomer!
	
	override func configureCollectionViewCell() {
		addSubview(tipContainer)
		tipContainer.addSubview(stackView)
		tipContainer.addSubview(totalLabel)
		super.configureCollectionViewCell()
		
		setupButtons()
	}
	override func applyConstraints() {
		super.applyConstraints()
		tipContainer.snp.makeConstraints { (make) in
			make.top.equalTo(backgroundHeaderView.snp.bottom).inset(-1)
			make.centerX.width.equalToSuperview()
			make.height.equalTo(150)
		}
		stackView.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview().multipliedBy(1.2)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.94)
			make.height.equalTo(44)
		}
		totalLabel.snp.makeConstraints { (make) in
			make.top.width.centerX.equalToSuperview()
			make.bottom.equalTo(stackView.snp.top)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		tipContainer.roundCorners([.bottomLeft, .bottomRight], radius: 4)
		buttons.forEach { $0.layer.cornerRadius = 5 }
	}
	
	private func setupButtons() {
		buttons.forEach({$0.addTarget(self, action: #selector(tipButtonPressed(_:)), for: .touchUpInside)})
		tipOption4.addTarget(self, action: #selector(customTipButtonPressed(_:)), for: .touchUpInside)
	}
	
	@objc private func tipButtonPressed(_ sender: UIButton) {
		if sender.tag == selectedButton {
			guard sender.tag != 4 else { return }
			totalLabel.text = "Total: $" + String(format: "%.2f", total / 100)
			buttons[sender.tag].backgroundColor = Colors.learnerPurple
			selectedButton = nil
			delegate?.didSelectTipPercentage(tipAmount: 0)
		} else if selectedButton == nil {
			updateTotalLabel(tag: sender.tag)
			buttons[sender.tag].backgroundColor = Colors.selectedPurple
			selectedButton = sender.tag
			guard sender.tag != 4 else { return }
			delegate?.didSelectTipPercentage(tipAmount: Int(buttonAmounts[sender.tag]))
		} else {
			updateTotalLabel(tag: sender.tag)
			buttons[sender.tag].backgroundColor = Colors.selectedPurple
			buttons[selectedButton!].backgroundColor = Colors.learnerPurple
			selectedButton = sender.tag
			guard sender.tag != 4 else { return }
			delegate?.didSelectTipPercentage(tipAmount: Int(buttonAmounts[sender.tag]))
		}
	}
	
	@objc private func customTipButtonPressed(_ sender: UIButton) {
		customTipModal = CustomTipModal()
		customTipModal?.parent = self
		customTipModal?.show()
	}
	
	private func updateTotalLabel(tag: Int) {
		guard tag != 4 else { return }
		let newTotal = total + Double(buttonAmounts[tag] * 100)
		totalLabel.text = "Total: $" + String(format: "%.2f", newTotal / 100)
	}

	private func getTipAmounts(total: Int) -> [Int] {
		return []
	}
	func didPressCancel() {
		tipOption4.backgroundColor = Colors.learnerPurple
		selectedButton = nil
		delegate?.didSelectTipPercentage(tipAmount: 0)
	}
}
