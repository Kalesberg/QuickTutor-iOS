//
//  AddTutorVCView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

class AddTutorView: MainLayoutTitleBackButton {
	let tableView: UITableView = {
		let tableView = UITableView()
		
		tableView.rowHeight = 50
		tableView.separatorInset.left = 10
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = Colors.backgroundDark
		
		return tableView
	}()
	
	let searchTextField: SearchTextField = {
		let textField = SearchTextField()
		
		textField.placeholder.text = "Search Usernames"
		textField.textField.font = Fonts.createSize(16)
		textField.textField.tintColor = Colors.learnerPurple
		textField.textField.autocapitalizationType = .words
		
		return textField
	}()
	
	let loadingIndicator = AWLoadingIndicatorView()
	
	override func configureView() {
		addSubview(tableView)
		addSubview(searchTextField)
		addSubview(loadingIndicator)
		super.configureView()
		
		title.label.text = "Add Tutor by Username"
		title.label.textAlignment = .center
		
		navbar.backgroundColor = Colors.learnerPurple
		statusbarView.backgroundColor = Colors.learnerPurple
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		searchTextField.snp.makeConstraints { make in
			make.top.equalTo(navbar.snp.bottom)
			make.width.equalToSuperview().multipliedBy(0.9)
			make.height.equalTo(80)
			make.centerX.equalToSuperview()
		}
		loadingIndicator.snp.makeConstraints { make in
			make.top.equalTo(searchTextField.snp.bottom)
			make.centerX.width.equalToSuperview()
			make.height.equalTo(30)
		}
		tableView.snp.makeConstraints { make in
			make.centerX.width.equalToSuperview()
			make.top.equalTo(searchTextField.snp.bottom)
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaLayoutGuide)
			} else {
				make.bottom.equalTo(layoutMargins.bottom)
			}
		}
	}
}
