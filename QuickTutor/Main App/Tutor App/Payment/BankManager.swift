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
	
	var backButton = NavbarButtonX()
	
	override var leftButton: NavbarButton {
		get {
			return backButton
		}
		set {
			backButton = newValue as! NavbarButtonX
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
			Stripe.stripeManager.retrieveBankList(acctId: acctId, { (bankList) in
				if let bankList = bankList {
					self.bankList = bankList.data
				}
			})
		}
	}
	
	var bankList : [ConnectAccount.Data]? {
		didSet {
			contentView.tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
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
	
	override func handleNavigation() {
		if (touchStartView is NavbarButtonX) {
			let transition = CATransition()
			let nav = self.navigationController
			
			DispatchQueue.main.async {
				nav?.view.layer.add(transition.popFromTop(), forKey: nil)
				nav?.popViewController(animated: false)
			}
		}
	}
	
	// TODO: Check if they have any pending sessions.
	
	private func defaultCardAlert(card: STPCard) {
		let alertController = UIAlertController(title: "Default Payout Method?", message: "Do you want this card to be your default payout method?", preferredStyle: .actionSheet)
		let setDefault = UIAlertAction(title: "Set as Default", style: .default) { (alert) in
			
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
		let count = bankList?.count ?? 0
		return count + 1
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.estimatedRowHeight
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let endIndex = bankList?.count ?? 0
		
		if indexPath.row != endIndex {
			let cell = tableView.dequeueReusableCell(withIdentifier: "bankCell", for: indexPath) as! BankManagerTableViewCell
			
			guard let bank = bankList else { return cell }

			insertBorder(cell: cell)
			
			//Not sure what we want to put here. But for now it will have bank name, and bankholder name
			cell.bankName.text = bank[indexPath.row].bank_name
			cell.holderName.text = bank[indexPath.row].account_holder_name
			
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "addCardCell", for: indexPath) as! AddCardTableViewCell
			
			cell.addCard.text = "Add bank account"
			
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == bankList?.count {
			if bankList?.count == 5 {
				print("too many banks")
				return
			}
			navigationController?.pushViewController(TutorAddBank(), animated: true)
		} else {
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
		
			tableView.deleteRows(at: [indexPath], with: .fade)
			tableView.reloadData()
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
	
	func configureTableViewCell() {
		addSubview(bankName)
		addSubview(holderName)
		
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
	}
}
