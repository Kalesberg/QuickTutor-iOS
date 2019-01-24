//
//  AddTutorVCView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

class AddTutorView: UIView {
	let tableView: UITableView = {
		let tableView = UITableView()
		tableView.rowHeight = 50
		tableView.separatorInset.left = 10
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = Colors.darkBackground
		return tableView
	}()
	
	let searchTextField: SearchTextField = {
		let textField = SearchTextField()
		textField.placeholder.text = "Search Usernames"
		textField.textField.font = Fonts.createSize(16)
		textField.textField.tintColor = Colors.purple
		textField.textField.autocapitalizationType = .words
		return textField
	}()
	
	let loadingIndicator = AWLoadingIndicatorView()
	
    func configureView() {
        backgroundColor = Colors.darkBackground
		addSubview(tableView)
		addSubview(searchTextField)
		addSubview(loadingIndicator)
	}
	
    func applyConstraints() {
		searchTextField.snp.makeConstraints { make in
			make.top.equalToSuperview()
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        applyConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
