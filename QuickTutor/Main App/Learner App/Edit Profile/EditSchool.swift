//
//  EditSchool.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/1/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
//TODO Design:
//  - fix up cell view
//TODO Backend:
//  - add barebones searchbar and tableview/cells... i can design it

import Foundation
import UIKit

class EditSchoolView : EditProfileMainLayout {
	
	var tableView = UITableView()
	var searchBar = UISearchBar()
	var header = UIView()
	
	override func configureView() {
		addSubview(tableView)
		addSubview(header)
		header.addSubview(searchBar)
		super.configureView()
		
		title.label.text = "School"
		titleLabel.label.text = "School I attend"
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 44
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		
		searchBar.sizeToFit()
		searchBar.searchBarStyle = .minimal
		searchBar.backgroundImage = UIImage(color: UIColor.clear)
		
		
		let textField = searchBar.value(forKey: "searchField") as? UITextField
		textField?.font = Fonts.createSize(18)
		textField?.textColor = .white
		textField?.adjustsFontSizeToFitWidth = true
		textField?.autocapitalizationType = .words
		textField?.attributedPlaceholder = NSAttributedString(string: "Enter a school", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		textField?.keyboardAppearance = .dark
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(titleLabel.snp.bottom).multipliedBy(1.35)
			make.width.equalToSuperview().multipliedBy(0.9)
			make.height.equalToSuperview().multipliedBy(0.5)
			make.centerX.equalToSuperview()
		}
		header.snp.makeConstraints { (make) in
			make.bottom.equalTo(tableView.snp.top)
			make.width.equalTo(tableView.snp.width)
			make.left.equalTo(tableView.snp.left)
			make.height.equalTo(55)
		}
		searchBar.snp.makeConstraints { (make) in
			make.width.equalToSuperview()
			make.height.equalToSuperview()
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview()
		}
	}
}

class EditSchool : BaseViewController {
	
	override var contentView: EditSchoolView {
		return view as! EditSchoolView
	}
	
	var schoolArray : NSArray = []
	var filteredSchools : NSArray = []
	var shouldUpdateSearchResults = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		hideKeyboardWhenTappedAround()
		configure()
		loadListOfSchools()
	}
	override func loadView() {
		view = EditSchoolView()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		//contentView.searchBar.becomeFirstResponder()
	}
	private func configure() {
		
		contentView.searchBar.delegate = self
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		contentView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "idCell")
	}
	
	override func handleNavigation() {
		if (touchStartView is NavbarButtonSave) {
			//save button pressed
		}
	}
	
	private func loadListOfSchools() {
		let pathToFile = Bundle.main.path(forResource: "schools", ofType: "txt")
		if let path = pathToFile {
			do {
				let school = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
				schoolArray = school.components(separatedBy: "\n") as NSArray
			} catch {
				schoolArray = [""]
				print("Try-catch error")
			}
		}
	}
}

extension EditSchool : UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if shouldUpdateSearchResults {
			return filteredSchools.count
		}
		return 0
	}
	
	internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath)
		formatTableView(cell)
		
		if shouldUpdateSearchResults {
			cell.textLabel?.text = (filteredSchools[indexPath.row] as! String)
		}
		return cell
	}
	
	internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		var school : String
		
		if shouldUpdateSearchResults {
			school = filteredSchools[indexPath.row] as! String
			FirebaseData.manager.updateValue(node: "student-info", value: ["sch" : school])
			LearnerData.userData.school = school
			navigationController?.popViewController(animated: true)
		}
	}
	
	private func formatTableView(_ cell: UITableViewCell) {
		let border = UIView(frame:CGRect(x: 0, y: cell.contentView.frame.size.height - 1.0, width: cell.contentView.frame.size.width, height: 2))
		border.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		cell.contentView.addSubview(border)
		cell.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		cell.textLabel?.textColor = UIColor.white
		cell.textLabel?.font = Fonts.createSize(16)
		
		let cellBackground = UIView()
		cellBackground.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		cell.selectedBackgroundView = cellBackground
	}
}

extension EditSchool : UISearchBarDelegate, UIScrollViewDelegate {
	
	private func scrollToTop() {
		contentView.tableView.reloadData()
		let indexPath = IndexPath(row: 0, section: 0)
		contentView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
	}
	
	internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		if searchText.count < 2 {
			shouldUpdateSearchResults = false
			contentView.tableView.reloadData()
			return
		}
		
		shouldUpdateSearchResults = true
		if let searchString = contentView.searchBar.text {
			let predicate = NSPredicate(format: "SELF contains[c] %@", searchString)
			
			filteredSchools = schoolArray.filtered(using: predicate) as NSArray
			
			if filteredSchools.count > 0 {
				scrollToTop()
			}
		}
		contentView.tableView.reloadData()
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.view.endEditing(true)
	}
}

