//
//  SubjectSearchSubcategoryCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/30/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

protocol DidSelectSubcategoryCell {
	func didSelectSubcategoryCell(subcategory: String)
}

class SubjectSearchSubcategoryCell : UITableViewCell {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	
	let tableView : UITableView = {
		let tableView = UITableView()
		
		tableView.allowsSelection = true
		tableView.backgroundColor = Colors.backgroundDark
		tableView.isScrollEnabled = false
		tableView.separatorInset.left = 5
		tableView.separatorColor = .black

		return tableView
	}()

	//TODO: Update this Datasource, it has bad practice written all over it.
	var dataSource = [String]() {
		didSet {
			tableView.reloadData()
		}
	}
	var subcategoryIcons = [UIImage]()
	
	var delegate : DidSelectSubcategoryCell?
	
	func configureTableViewCell() {
		addSubview(tableView)
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(SubjectSubcategoryTableViewCell.self, forCellReuseIdentifier: "subcategoryCell")
		
		backgroundColor = Colors.backgroundDark
		
		applyConstraints()
	}
	
	func applyConstraints() {
		tableView.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(5)
			make.centerY.height.right.equalToSuperview()
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
}

extension SubjectSearchSubcategoryCell : UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "subcategoryCell", for: indexPath) as! SubjectSubcategoryTableViewCell
		cell.icon.image = subcategoryIcons[indexPath.row]
		cell.title.text = dataSource[indexPath.row]
		cell.iconHeight = tableView.frame.height / CGFloat(dataSource.count)
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.frame.height / CGFloat(dataSource.count)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? SubjectSubcategoryTableViewCell else { return }
		delegate?.didSelectSubcategoryCell(subcategory: cell.title.text!)
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

class SubjectSubcategoryTableViewCell : UITableViewCell {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureTableViewCell()
	}
	
	var icon = UIImageView()
	
	var iconHeight : CGFloat?
	
	var title : UILabel = {
		let label = UILabel()

		label.textColor = .white
		label.font = Fonts.createSize(15)
		label.textAlignment = .left
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	func configureTableViewCell() {
		addSubview(icon)
		addSubview(title)

		let cellBackground = UIView()
		cellBackground.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		selectedBackgroundView = cellBackground
		
		backgroundColor = Colors.backgroundDark
		accessoryType = .disclosureIndicator
		
		icon.alpha = 0.8
		applyConstraints()
	}
	
	func applyConstraints() {
		title.snp.makeConstraints { (make) in
			make.left.equalTo(icon.snp.right).inset(-10)
			make.centerY.height.right.equalToSuperview()
		}
		icon.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.left.equalToSuperview().inset(10)
			make.width.height.equalTo(iconHeight ?? 30)
		}
	}
}
