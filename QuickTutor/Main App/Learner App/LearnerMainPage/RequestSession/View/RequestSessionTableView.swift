//
//  RequestSessionTableView.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class RequestSessionBackgroundView :  UIView {
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		configureView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	let title : UILabel = {
		let label = UILabel()
		
		label.text = "Request Session"
		label.textColor = .white
		label.textAlignment = .center
		label.font = Fonts.createBoldSize(21)
		
		return label
	}()
	
	let tableView : UITableView = {
		let tableView = UITableView()
		
		tableView.allowsMultipleSelection = false
		tableView.backgroundColor = Colors.navBarColor
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .singleLine
		tableView.separatorColor = UIColor.black
		tableView.isScrollEnabled = false
		
		return tableView
	}()
	
	var dateFormatter = DateFormatter()
	var datePickerIndexPath : IndexPath?
	var requestData : TutorPreferenceData!
	
	 func configureView() {
		addSubview(title)
		addSubview(tableView)

		isUserInteractionEnabled = true
		configureDelegates()
		backgroundColor = #colorLiteral(red: 0.3882352941, green: 0.3960784314, blue: 0.7647058824, alpha: 1)
		applyConstraints()
	}
	func applyConstraints() {
		title.snp.makeConstraints { (make) in
			make.top.width.centerX.equalToSuperview()
			make.height.equalTo(44)
		}
		tableView.snp.makeConstraints { (make) in
			make.right.equalToSuperview()
			make.top.equalTo(title.snp.bottom)
			make.bottom.equalToSuperview()
			make.left.equalToSuperview().inset(3)
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.roundCorners([.topLeft, .topRight], radius: 6)
	}
	
	private func configureDelegates() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(RequestSessionTableViewCell.self, forCellReuseIdentifier: "requestSessionCell")
		tableView.register(RequestSessionDatePickerCell.self, forCellReuseIdentifier: "datePickerCell")
		tableView.register(RequestSessionDurationPickerCell.self, forCellReuseIdentifier: "durationPickerCell")
		tableView.register(RequestSessionPriceCell.self, forCellReuseIdentifier: "priceCell")
		tableView.register(RequestSessionSubjectPickerCell.self, forCellReuseIdentifier: "subjectPickerCell")
		tableView.register(RequestSessionTypeCell.self, forCellReuseIdentifier: "sessionTypeCell")
	}

}

extension RequestSessionBackgroundView : UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let tableViewHeight = tableView.bounds.height
		let tempHeight = tableViewHeight / CGFloat(5)
		if datePickerIndexPath != nil && datePickerIndexPath!.row == indexPath.row {
			let height = tempHeight > 44 ? tempHeight : 44
			return tableViewHeight - height
		}
		return (tempHeight > 44) ? tempHeight : 44
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? RequestSessionTableViewCell else { return }
		UIView.animate(withDuration: 0.2) {
			cell.icon.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
		}
		let offset = cell.frame.height
		switch indexPath.row {
		case 0: break
		case 1: tableView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
		case 2: tableView.setContentOffset(CGPoint(x: 0, y: offset * 2), animated: true)
		case 3: tableView.setContentOffset(CGPoint(x: 0, y: offset * 3), animated: true)
		case 4 : tableView.setContentOffset(CGPoint(x: 0, y: offset * 4), animated: true)
		default: return
		}
		tableView.beginUpdates()
		if datePickerIndexPath != nil && datePickerIndexPath!.row - 1 == indexPath.row {
			tableView.deleteRows(at: [datePickerIndexPath!], with: .automatic)
			datePickerIndexPath = nil
			UIView.animate(withDuration: 0.2) {
				cell.icon.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / -2))
			}
		} else {
			if datePickerIndexPath != nil {
				tableView.deleteRows(at: [datePickerIndexPath!], with: .automatic)
			}
			datePickerIndexPath = calculateDatePickerIndexPath(indexPath)
			tableView.insertRows(at: [datePickerIndexPath!], with: .automatic)
		}
		tableView.deselectRow(at: indexPath, animated: true)
		tableView.endUpdates()
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func calculateDatePickerIndexPath(_ selectedIndexPath : IndexPath) -> IndexPath {
		return (datePickerIndexPath != nil && datePickerIndexPath!.row < selectedIndexPath.row) ? IndexPath(row: selectedIndexPath.row, section: 0) : IndexPath(row: selectedIndexPath.row + 1, section: 0)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var rows = RequestSessionCellFactory.requestSessionCells.count
		if datePickerIndexPath != nil {
			rows += 1
		}
		return rows
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if datePickerIndexPath != nil && datePickerIndexPath!.row == indexPath.row {
			let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
			headerView.backgroundColor = .black
			switch indexPath.row - 1 {
			case 0:
				let cell = tableView.dequeueReusableCell(withIdentifier: "subjectPickerCell", for: indexPath) as! RequestSessionSubjectPickerCell
				cell.addSubview(headerView)
				cell.datasource = requestData.subjects
				cell.delegate = self
				return cell
			case 1:
				let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell",  for: indexPath) as! RequestSessionDatePickerCell
				cell.delegate = self
				cell.datePicker.minimumDate = Date().adding(minutes: 15)
				cell.datePicker.maximumDate = Date().adding(days: 30)
				cell.datePicker.setDate(RequestSessionData.startTime != nil ? RequestSessionData.startTime! : Date().adding(minutes: 15), animated: true)
				cell.addSubview(headerView)
				return cell
			case 2:
				let cell = tableView.dequeueReusableCell(withIdentifier: "durationPickerCell",  for: indexPath) as! RequestSessionDurationPickerCell
				cell.delegate = self
				cell.addSubview(headerView)
				return cell
			case 3:
				let cell = tableView.dequeueReusableCell(withIdentifier: "priceCell", for: indexPath) as! RequestSessionPriceCell
				cell.addSubview(headerView)
				cell.delegate = self
				cell.textField.attributedText = NSMutableAttributedString().bold("$\(RequestSessionData.price ?? requestData.pricePreference)", 32, .white).regular("/hr", 15, .white)
				cell.header.attributedText = NSMutableAttributedString().bold("Tutors recommended price: $\(requestData.pricePreference)", 15, #colorLiteral(red: 0.3882352941, green: 0.3960784314, blue: 0.7647058824, alpha: 1)).regular("/hr", 11, #colorLiteral(red: 0.3882352941, green: 0.3960784314, blue: 0.7647058824, alpha: 1))
				cell.currentPrice = RequestSessionData.price ?? requestData.pricePreference
				cell.amount = "\(RequestSessionData.price ?? requestData.pricePreference)"
				return cell
			case 4:
				let cell = tableView.dequeueReusableCell(withIdentifier: "sessionTypeCell", for: indexPath) as! RequestSessionTypeCell
				cell.requestData = requestData
				cell.delegate = self
				return cell
			default:
				return UITableViewCell()
			}
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "requestSessionCell", for: indexPath) as! RequestSessionTableViewCell
			let index = (datePickerIndexPath != nil && indexPath.row > datePickerIndexPath!.row) ? indexPath.row - 1: indexPath.row
			cell.title.text = RequestSessionCellFactory.requestSessionCells[index].cellData.title
			cell.subtitle.attributedText = RequestSessionCellFactory.requestSessionCells[index].cellData.subtitle
			return cell
		}
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 1
	}
}
extension RequestSessionBackgroundView : RequestSessionDelegate {
	func isOnlineChanged(isOnline: Bool?) {
		guard let cell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as?  RequestSessionTableViewCell else { return }
		if isOnline == nil {
			cell.subtitle.attributedText = NSMutableAttributedString().regular("Choose a session type", 15, .white)
			RequestSessionData.isOnline = nil
		} else {
			cell.subtitle.attributedText = NSMutableAttributedString().bold(isOnline! ? "Online (Video)" : "In-Person", 15, .white)
			RequestSessionData.isOnline = isOnline
		}
	}
	func sessionSubjectChanged(subject: String) {
		guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RequestSessionTableViewCell else { return }
		if subject == "Choose a subject" {
			cell.subtitle.attributedText = NSMutableAttributedString().regular(subject, 15, .white)
			RequestSessionData.subject = nil
		} else {
			cell.subtitle.attributedText = NSMutableAttributedString().bold(subject, 15, .white)
			RequestSessionData.subject = subject
		}
	}
	func startTimeDateChanged(date: Date) {
		dateFormatter.dateFormat = "EEEE MMMM d'\(date.daySuffix())', h:mm a"
		guard let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RequestSessionTableViewCell else { return }
		cell.subtitle.attributedText = NSMutableAttributedString().bold(dateFormatter.string(from: date), 15, .white)
		RequestSessionData.startTime = date
	}
	func durationChanged(displayDuration: String?, duration: Int?) {
		guard let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? RequestSessionTableViewCell else { return }
		cell.subtitle.attributedText = NSMutableAttributedString().bold(displayDuration != nil ? displayDuration! : "Choose a session duration", 15, .white)
		RequestSessionData.duration = duration != nil ? duration! : nil
		RequestSessionData.displayDuration = displayDuration != nil ? displayDuration! : nil
	}
	func priceDidChange(price: Int) {
		guard let cell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? RequestSessionTableViewCell else { return }
		cell.subtitle.attributedText = NSMutableAttributedString().bold("$\(price)", 15, .white).regular("/hr", 11, .white)
		RequestSessionData.price = price
	}
}
