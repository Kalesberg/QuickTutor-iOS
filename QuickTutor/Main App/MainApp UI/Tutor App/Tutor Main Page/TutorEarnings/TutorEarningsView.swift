//
//  TutorEarningsView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class TutorEarningsView: MainLayoutTitleBackButton {
	let summaryLabel: UILabel = {
		let label = UILabel()
		let formattedString = NSMutableAttributedString()
		formattedString
			.bold("Earnings in past 7 days:\n", 15, .white)
			.bold("Earnings in past 30 days:\n", 15, .white)
			.bold("All time earnings:", 15, .white)
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 8
		formattedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, formattedString.length))
		
		label.attributedText = formattedString
		label.numberOfLines = 0
		return label
	}()
	
	let label: UILabel = {
		let label = UILabel()
		return label
	}()
	
	let earningsLabel = UILabel()
	
	let infoContainer: UIView = {
		let view = UIView()
		view.backgroundColor = Colors.navBarColor
		return view
	}()
	
	let imageView: UIImageView = {
		let view = UIImageView()
		view.image = #imageLiteral(resourceName: "green-pattern").alpha(0.39)
		view.contentMode = .scaleAspectFill
		view.clipsToBounds = true
		view.backgroundColor = Colors.green
		return view
	}()
	
	let earningsContainer = UIView()
	
	let earnings2018: UILabel = {
		let label = UILabel()
		label.font = Fonts.createBoldSize(15)
		label.textColor = .white
		label.text = "2018 EARNINGS"
		label.textAlignment = .center
		return label
	}()
	
	let recentStatementsLabel: UILabel = {
		let label = UILabel()
		label.text = "Recent Statements"
		label.textColor = .white
		label.font = Fonts.createBoldSize(18)
		return label
	}()
	
	let tableView: UITableView = {
		let tableView = UITableView()
		tableView.rowHeight = 50
		tableView.separatorInset.left = 0
		tableView.separatorColor = Colors.divider
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = .clear
		tableView.tableFooterView = UIView()
		tableView.alwaysBounceVertical = true
		return tableView
	}()
	
	override func configureView() {
		addSubview(imageView)
		imageView.addSubview(label)
		addSubview(infoContainer)
		infoContainer.addSubview(summaryLabel)
		infoContainer.addSubview(earningsLabel)
		addSubview(earningsContainer)
		earningsContainer.addSubview(earnings2018)
		addSubview(tableView)
		addSubview(recentStatementsLabel)
		super.configureView()
		insertSubview(statusbarView, at: 1)
		insertSubview(navbar, at: 2)
		
		navbar.backgroundColor = Colors.green
		statusbarView.backgroundColor = Colors.green
		title.label.text = "Earnings"
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		earningsContainer.applyGradient(firstColor: UIColor(hex: "1A943F").cgColor, secondColor: UIColor(hex: "1FB45C").cgColor, angle: 80, frame: earningsContainer.bounds)
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		imageView.snp.makeConstraints { make in
			make.top.equalTo(navbar.snp.bottom)
			make.width.equalToSuperview()
			make.height.equalTo(110)
			make.centerX.equalToSuperview()
		}
		
		label.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		earningsContainer.snp.makeConstraints { make in
			make.height.equalTo(30)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.top.equalTo(imageView.snp.bottom).inset(-1)
		}
		earnings2018.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}
		infoContainer.snp.makeConstraints { make in
			make.top.equalTo(earnings2018.snp.bottom).inset(-1)
			make.height.equalTo(100)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
		
		summaryLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().inset(15)
			make.height.equalToSuperview()
			make.centerY.equalToSuperview()
		}
		
		earningsLabel.snp.makeConstraints { make in
			make.right.equalToSuperview().inset(15)
			make.height.equalToSuperview()
			make.centerY.equalToSuperview()
		}
		
		recentStatementsLabel.snp.makeConstraints { make in
			make.left.equalToSuperview().inset(15)
			make.height.equalTo(40)
			make.top.equalTo(infoContainer.snp.bottom).inset(-10)
		}
		
		tableView.snp.makeConstraints { make in
			make.top.equalTo(recentStatementsLabel.snp.bottom)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaLayoutGuide)
			} else {
				make.bottom.equalToSuperview()
			}
		}
	}
}
