//
//  Payment.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
//

import UIKit.UITableView
import Stripe

class BankManagerView : MainLayoutTitleOneButton {
	
	let subtitleLabel : LeftTextLabel = {
		let label = LeftTextLabel()
		
		label.label.text = "Payout Methods"
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
	
	var backButton = NavbarButtonBack()
	
	override var leftButton: NavbarButton {
		get {
			return backButton
		}
		set {
			backButton = newValue as! NavbarButtonBack
		}
	}
	
	
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
			make.width.equalToSuperview().multipliedBy(0.85)
			make.height.equalToSuperview().multipliedBy(0.1)
			make.centerX.equalToSuperview()
		}
		
		subtitleLabel.label.snp.remakeConstraints { (make) in
			make.left.equalToSuperview()
			make.centerY.equalToSuperview().multipliedBy(1.25)
			make.width.equalToSuperview()
		}
		
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(subtitleLabel.snp.bottom).inset(-20)
			make.width.equalToSuperview().multipliedBy(0.85)
			make.height.equalToSuperview().multipliedBy(0.5)
			make.centerX.equalToSuperview()
		}

	}
	override func layoutSubviews() {
		super.layoutSubviews()
		navbar.backgroundColor = Colors.tutorBlue
		statusbarView.backgroundColor = Colors.tutorBlue
	}
}

class BankManager : BaseViewController {
	
	override var contentView: BankManagerView {
		return view as! BankManagerView
	}
	
	override func loadView() {
		view = BankManagerView()
	}
	
	var acctId : String! {
		didSet {
			contentView.tableView.reloadData()
		}
	}
	
	var bankList = [ExternalAccountsData]() {
		didSet {
			setBank()
		}
	}

	private var banks = [ExternalAccountsData]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		Stripe.retrieveBankList(acctId: CurrentUser.shared.tutor.acctId, { (bankList) in
			if let bankList = bankList {
				self.bankList = bankList.data
			}
		})
		
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		contentView.tableView.register(BankManagerTableViewCell.self, forCellReuseIdentifier: "bankCell")
		contentView.tableView.register(AddCardTableViewCell.self, forCellReuseIdentifier: "addCardCell")
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
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
	
	private func setBank() {
		self.banks = bankList
		contentView.tableView.reloadData()
	}
	override func handleNavigation() {
		
	}
	
	// TODO: Check if they have any pending sessions.
	
	private func defaultBankAlert(bankId: String) {
		let alertController = UIAlertController(title: "Default Payout Method?", message: "Do you want this card to be your default payout method?", preferredStyle: .actionSheet)
		let setDefault = UIAlertAction(title: "Set as Default", style: .default) { (alert) in
			
			Stripe.updateDefaultBank(account: self.acctId, bankId: bankId, completion: { (account) in
				if let account = account {
					self.bankList = account.data
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

extension BankManager : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return banks.count + 1
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.estimatedRowHeight
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let endIndex = banks.count
		
		if indexPath.row != endIndex {
			let cell = tableView.dequeueReusableCell(withIdentifier: "bankCell", for: indexPath) as! BankManagerTableViewCell
			insertBorder(cell: cell)

			//Not sure what we want to put here. But for now it will have bank name, and bankholder name
			cell.bankName.text = banks[indexPath.row].bank_name
			cell.holderName.text = banks[indexPath.row].account_holder_name
			cell.defaultBank.isHidden = !banks[indexPath.row].default_for_currency
			
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "addCardCell", for: indexPath) as! AddCardTableViewCell
			
			cell.addCard.text = "Add bank account"
			
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return (indexPath.row == banks.count) ? false : true
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == banks.count {
			if banks.count == 5 {
				print("too many banks")
				return
			}
			navigationController?.pushViewController(TutorAddBank(), animated: true)
		} else {
			defaultBankAlert(bankId: banks[indexPath.row].id)
			tableView.deselectRow(at: indexPath, animated: true)
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		return "Remove Bank"
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = AddCardHeaderView()
		view.addCard.text = "Banks"
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			Stripe.removeBank(account: acctId, bankId: banks[indexPath.row].id) { (bankList) in
				if let bankList = bankList {
					self.banks.remove(at: indexPath.row)
					tableView.deleteRows(at: [indexPath], with: .automatic)
					self.bankList = bankList.data
					if self.bankList.count == 0 {
						CurrentUser.shared.tutor.hasPayoutMethod = false
					}
				} else {
					print("Oops soemthing went wrong.")
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

class BankManagerTableViewCell : UITableViewCell {
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let bankName : UILabel = {
		let label = UILabel()
		
		label.textAlignment = .left
		label.adjustsFontSizeToFitWidth = true
		label.font = Fonts.createBoldSize(16)
		label.textColor = .white
		
		return label
	}()
	
	let holderName : UILabel = {
		let label = UILabel()
		
		label.textAlignment = .left
		label.adjustsFontSizeToFitWidth = true
		label.font = Fonts.createBoldSize(16)
		label.textColor = .white
		
		return label
	}()
	
	let defaultBank : UILabel = {
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
	
	func configureTableViewCell() {
		addSubview(bankName)
		addSubview(holderName)
		addSubview(defaultBank)
		let cellBackground = UIView()
		cellBackground.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		selectedBackgroundView = cellBackground
	
		
		backgroundColor = Colors.backgroundDark
		
		applyConstraints()
	}
	
	func applyConstraints() {
		bankName.snp.makeConstraints { (make) in
			make.width.equalToSuperview().multipliedBy(0.5)
			make.height.equalToSuperview()
			make.left.equalToSuperview()
			make.centerY.equalToSuperview()
		}
		holderName.snp.makeConstraints { (make) in
			make.width.equalToSuperview().multipliedBy(0.5)
			make.height.equalToSuperview()
			make.left.equalTo(bankName.snp.right)
			make.centerY.equalToSuperview()
		}
		defaultBank.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.right.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.2)
			make.height.equalToSuperview().multipliedBy(0.4)
		}
	}
}
