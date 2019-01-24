//
//  InviteOthersView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/14/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class InviteOthersView: UIView {
	
	let container: UIView = {
		let view = UIView()
		view.backgroundColor = Colors.green
		view.layer.cornerRadius = 5
		return view
	}()
	
	let imageView: UIImageView = {
		let view = UIImageView()
		view.image = #imageLiteral(resourceName: "invite-contacts")
		return view
	}()
	
	let label: UILabel = {
		let label = UILabel()
		label.font = Fonts.createBoldSize(16)
		label.textAlignment = .center
		label.textColor = .white
		label.text = "Share QuickTutor with your friends and family. Invite them to join the party!"
		label.numberOfLines = 2
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	
	let searchTextField: SearchTextField = {
		let textField = SearchTextField()
		textField.placeholder.text = "Search"
		textField.textField.attributedPlaceholder = NSAttributedString(string: "Your Contacts",
																	   attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
		textField.placeholder.font = Fonts.createBoldSize(20)
		textField.textField.font = Fonts.createSize(20)
		textField.textField.tintColor = (AccountService.shared.currentUserType == .learner) ? Colors.purple : Colors.purple
		return textField
	}()
	
	let tableView: UITableView = {
		let tableView = UITableView()
		tableView.rowHeight = 50
		tableView.backgroundColor = Colors.registrationDark
		tableView.isScrollEnabled = true
		tableView.separatorInset.left = 0
		tableView.separatorColor = Colors.divider
		tableView.showsVerticalScrollIndicator = false
		tableView.isScrollEnabled = true
		tableView.isUserInteractionEnabled = true
		tableView.tableFooterView = UIView()
		tableView.allowsMultipleSelection = true
		return tableView
	}()
	
	let connectContacts = InviteOthersBackgroundView()
	
	
    func configureView() {
		addSubview(container)
		addSubview(imageView)
		container.addSubview(label)
		addSubview(searchTextField)
		addSubview(tableView)
		addSubview(connectContacts)
        backgroundColor = Colors.darkBackground
	}
	
    func applyConstraints() {
		imageView.snp.makeConstraints { make in
			make.top.equalToSuperview().inset(10)
			make.centerX.equalToSuperview()
		}
		
		container.snp.makeConstraints { make in
			make.width.equalToSuperview().multipliedBy(0.9)
			make.height.equalTo(70)
			make.centerX.equalToSuperview()
			make.top.equalTo(imageView.snp.bottom).inset(15)
		}
		
		label.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview()
			make.left.right.equalToSuperview().inset(5)
		}
		searchTextField.snp.makeConstraints { make in
			make.top.equalTo(container.snp.bottom).inset(-5)
			make.width.equalToSuperview().multipliedBy(0.95)
			make.centerX.equalToSuperview()
			make.height.equalTo(80)
		}
		tableView.snp.makeConstraints { make in
			make.top.equalTo(searchTextField.snp.bottom)
			make.width.centerX.equalToSuperview()
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
			} else {
				make.bottom.equalToSuperview()
			}
		}
		connectContacts.snp.makeConstraints { make in
			make.top.equalTo(container.snp.bottom).inset(-100)
			make.width.centerX.equalToSuperview()
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
			} else {
				make.bottom.equalToSuperview()
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
