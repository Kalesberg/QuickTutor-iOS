//
//  LocationView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

class LocationView : MainLayoutTitleBackButton {
	let tableView: UITableView = {
		let tableView = UITableView()
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 44
		tableView.separatorStyle = .singleLine
		tableView.separatorColor = .black
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = Colors.backgroundDark
		tableView.tableFooterView = UIView()
		return tableView
	}()
	
	let searchTextField: SearchTextField = {
		let textField = SearchTextField()
		textField.placeholder.text = "Search For an Address"
		textField.textField.font = Fonts.createSize(18)
		textField.textField.tintColor = (AccountService.shared.currentUserType == .learner) ? Colors.learnerPurple : Colors.tutorBlue
		textField.textField.autocapitalizationType = .words
		
		return textField
	}()
	

	override func configureView() {
		addSubview(searchTextField)
		addSubview(tableView)
		super.configureView()
		
		title.label.text = "Location"
	}
	override func applyConstraints() {
		super.applyConstraints()
		searchTextField.snp.makeConstraints { make in
			make.top.equalTo(navbar.snp.bottom)
			make.width.equalToSuperview().multipliedBy(0.9)
			make.height.equalTo(80)
			make.centerX.equalToSuperview()
		}
		tableView.snp.makeConstraints { make in
			make.top.equalTo(searchTextField.snp.bottom)
			make.width.equalToSuperview()
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaLayoutGuide)
			} else {
				make.bottom.equalToSuperview()
			}
			make.centerX.equalToSuperview()
		}
	}
}
