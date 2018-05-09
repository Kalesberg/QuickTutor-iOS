//
//  CardManager.swift
//  QuickTutor
//
//  Created by QuickTutor on 2/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
//	Purpose: This class shows the user his current payment methods. The user can Delete or add cards here.
//	Maximum of 5 cards per user. The add payment button will be disabled when they have 5 cards.
//
/*	TODO: Design
- Warn User when they delete last card.
Backend
- ...
Future
- ...
*/

import UIKit.UITableView
import Stripe

class CardManagerView : MainLayoutTitleBackButton {
	
	let subtitleLabel : LeftTextLabel = {
		let label = LeftTextLabel()
		
		label.label.text = "Payment Methods"
		label.label.textAlignment = .left
		label.label.font = Fonts.createBoldSize(20)
		
		return label
	}()
	
	let tableView : UITableView = {
		let tableView = UITableView()
		
		tableView.estimatedRowHeight = 44
		tableView.isScrollEnabled = false
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.backgroundColor = Colors.backgroundDark
		
		return tableView
	}()
	
	override func configureView() {
		addSubview(subtitleLabel)
		addSubview(tableView)
		super.configureView()
		
		title.label.text = "Payment"
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		subtitleLabel.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom)
			make.width.equalToSuperview().multipliedBy(0.9)
			make.height.equalToSuperview().multipliedBy(0.08)
			make.centerX.equalToSuperview()
		}
		
//        subtitleLabel.label.snp.remakeConstraints { (make) in
//            make.left.equalToSuperview()
//            make.centerY.equalToSuperview().multipliedBy(1.25)
//            make.width.equalToSuperview()
//        }
		
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(subtitleLabel.snp.bottom).inset(-20)
			make.width.equalToSuperview().multipliedBy(0.85)
			make.height.equalToSuperview().multipliedBy(0.5)
			make.centerX.equalToSuperview()
		}
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		navbar.backgroundColor = Colors.learnerPurple
		statusbarView.backgroundColor = Colors.learnerPurple
	}
}

class CardManager : BaseViewController {
	
	override var contentView: CardManagerView {
		return view as! CardManagerView
	}
	
	override func loadView() {
		view = CardManagerView()
	}
	
	var customerId : String!
	
	var customer : STPCustomer! {
		didSet {
			setCustomer()
			contentView.tableView.reloadData()
		}
	}
	
	private var cards = [STPCard]()
	private var defaultCard : STPCard?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		Stripe.retrieveCustomer(cusID: customerId) { (customer, error) in
			if let error = error{
				print(error.localizedDescription)
			} else if let customer = customer {
				self.customer = customer
			}
		}
		
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		contentView.tableView.register(CardManagerTableViewCell.self, forCellReuseIdentifier: "cardCell")
		contentView.tableView.register(AddCardTableViewCell.self, forCellReuseIdentifier: "addCardCell")

	}
	
	private func setCustomer() {
		guard let cards = customer.sources as? [STPCard] else { return }
		self.cards = cards
		guard let defaultCard = customer.defaultSource as? STPCard else { return }
		self.defaultCard = defaultCard
		
		contentView.tableView.reloadData()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.tableView.reloadData()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func handleNavigation() {
		
	}
	
	// TODO: Check if they have any pending sessions.
	
	private func defaultCardAlert(card: STPCard) {
		let alertController = UIAlertController(title: "Default Payment Method?", message: "Do you want this card to be your default Payment method?", preferredStyle: .actionSheet)
		let setDefault = UIAlertAction(title: "Set as Default", style: .default) { (alert) in
			Stripe.updateDefaultSource(customer: self.customer, new: card, completion: { (customer, error)  in
				if let error = error {
					print(error.localizedDescription)
				} else if let customer = customer {
					print("Default Updated")
					self.customer = customer
				}
			})
		}
		
		let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
			alertController.dismiss(animated: true, completion: nil)
		}
		alertController.addAction(setDefault)
		alertController.addAction(cancel)
		
		present(alertController, animated: true, completion: nil)
	}
}


extension CardManager : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (cards.count > 0) ? cards.count + 1 : 1
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.estimatedRowHeight
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let endIndex = cards.count

		if indexPath.row != endIndex {
			let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as! CardManagerTableViewCell
			
			insertBorder(cell: cell)
			print("Reload Data.")
			cell.last4.text = cards[indexPath.row].last4
			cell.brand.image = STPImageLibrary.brandImage(for: cards[indexPath.row].brand)
			cell.defaultcard.isHidden = !(cards[indexPath.row] == defaultCard)
			
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "addCardCell", for: indexPath) as! AddCardTableViewCell
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == cards.count {
			if cards.count == 5 {
				print("too many cards")
				return
			}
			navigationController?.pushViewController(LearnerPayment(), animated: true)
		} else {
			if cards[indexPath.row] != defaultCard {
				defaultCardAlert(card: cards[indexPath.row])
				tableView.deselectRow(at: indexPath, animated: true)
			}
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		return "Remove Card"
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return (indexPath.row == cards.count) ? false : true
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = AddCardHeaderView()
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			Stripe.dettachSource(customer: self.customer, deleting: cards[indexPath.row]) { (customer, error) in
				if let error = error {
					print(error.localizedDescription)
				} else if let customer = customer {
					self.cards.remove(at: indexPath.row)
					tableView.deleteRows(at: [indexPath], with: .automatic)
					self.customer = customer
				}
			}
		}
	}
	
	func insertBorder(cell: UITableViewCell) {
		let border = UIView(frame:CGRect(x: 0, y: cell.contentView.frame.size.height - 1.0, width: cell.contentView.frame.size.width, height: 1))
		border.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		cell.contentView.addSubview(border)
	}
}

class AddCardHeaderView : BaseView {
	
	var addCard : UILabel = {
		let label = UILabel()
		
		label.text = "Cards"
		label.textColor = .white
		label.font = Fonts.createBoldSize(18)
		label.textAlignment = .left
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let footer = UIView()
	
	override func configureView() {
		addSubview(addCard)
		addSubview(footer)
		super.configureView()
		
		footer.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		applyConstraints()
	}
	override func applyConstraints() {
		addCard.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
			make.height.equalToSuperview()
			make.width.equalToSuperview()
		}
		footer.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.height.equalTo(1)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
	}
}

class AddCardTableViewCell : UITableViewCell {
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let addCard : UILabel = {
		let label = UILabel()
		
		label.text = "Add debit or credit card"
		label.textColor = .white
		label.font = Fonts.createSize(18)
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let footer = UIView()
	
	func configureTableViewCell() {
		addSubview(addCard)
		addSubview(footer)
		
		let cellBackground = UIView()
		cellBackground.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		selectedBackgroundView = cellBackground
		
		footer.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		
		backgroundColor = Colors.backgroundDark
		
		applyConstraints()
	}
	
	
	func applyConstraints() {
		addCard.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
			make.height.equalToSuperview()
			make.width.equalToSuperview()
		}
		footer.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.height.equalTo(1)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
	}
}

class CardManagerTableViewCell : UITableViewCell {
	
	var hiddenCardNumbers : UILabel = {
		let label = UILabel()
		
		label.text = "••••"
		label.adjustsFontSizeToFitWidth = true
		label.font = Fonts.createSize(22)
		label.textColor = .white
		
		return label
	}()
	
	var last4 : UILabel = {
		let label = UILabel()
		
		label.adjustsFontSizeToFitWidth = true
		label.font = Fonts.createBoldSize(22)
		label.textColor = .white
		
		return label
	}()
	var brand = UIImageView()
	
	var defaultcard : UILabel = {
		let label = UILabel()
		
		label.text = "Default"
		label.font = Fonts.createSize(15)
		label.textColor = .white
		label.textColor.withAlphaComponent(1.0)
		label.textAlignment = .center
		label.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		label.isHidden = true
		
		return label
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configureTableViewCell() {
		addSubview(hiddenCardNumbers)
		addSubview(last4)
		addSubview(brand)
		addSubview(defaultcard)
		
		let cellBackground = UIView()
		cellBackground.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		selectedBackgroundView = cellBackground
		
		backgroundColor = Colors.backgroundDark
		
		applyConstraints()
	}
	
	
	func applyConstraints() {
		brand.snp.makeConstraints { (make) in
			make.left.equalToSuperview().multipliedBy(1.2)
			make.width.equalToSuperview().multipliedBy(0.12)
			make.height.equalToSuperview().multipliedBy(0.6)
			make.centerY.equalToSuperview()
		}
		hiddenCardNumbers.snp.makeConstraints { (make) in
			make.height.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.1)
			make.left.equalTo(brand.snp.right).multipliedBy(1.2)
			make.centerY.equalToSuperview().multipliedBy(0.85)
		}
		last4.snp.makeConstraints { (make) in
			make.left.equalTo(hiddenCardNumbers.snp.right).multipliedBy(1.1)
			make.width.equalToSuperview().multipliedBy(0.1)
			make.height.equalToSuperview()
			make.centerY.equalToSuperview().multipliedBy(0.85)
		}
		defaultcard.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.right.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.2)
			make.height.equalTo(brand.snp.height)
		}
	}
}
