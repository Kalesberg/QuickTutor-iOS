//
//  TutorAddSubjects.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/14/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorAddSubjectsView : MainLayoutOneButton {
	
	var searchBar = UISearchBar()
	var backButton = NavbarButtonBack()
	var tableView = UITableView()
	var nextButton        = RegistrationNextButton()
	
	override var leftButton: NavbarButton {
		get {
			return backButton
		} set {
			backButton = newValue as! NavbarButtonBack
		}
	}
	
	override func configureView() {
		navbar.addSubview(leftButton)
		navbar.addSubview(searchBar)
		addSubview(nextButton)
		
		super.configureView()
		
		searchBar.searchBarStyle = .minimal
		searchBar.backgroundImage = UIImage(color: UIColor.clear)
		
		let textField = searchBar.value(forKey: "searchField") as? UITextField
		textField?.font = Fonts.createSize(18)
		textField?.textColor = .white
		textField?.adjustsFontSizeToFitWidth = true
		textField?.autocapitalizationType = .words
		textField?.attributedPlaceholder = NSAttributedString(string: "Subjects I Teach", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		textField?.keyboardAppearance = .dark
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		leftButton.allignLeft()
		
		searchBar.snp.makeConstraints { (make) in
			make.height.equalTo(55)
			make.left.equalTo(leftButton.snp.right).inset(5)
			make.right.equalToSuperview().inset(5)
			make.centerY.equalTo(backButton).inset(6)
		}
		nextButton.snp.makeConstraints { (make) in
			make.top.equalTo(searchBar.snp.bottom).inset(-20)
			make.width.equalToSuperview()
			make.height.equalTo(60)
			make.centerX.equalToSuperview()
		}
	}
}


class TutorAddSubjects : BaseViewController {
	
	override var contentView: TutorAddSubjectsView {
		return view as! TutorAddSubjectsView
	}
	override func loadView() {
		view = TutorAddSubjectsView()
	}
	
	var shouldUpdateSearchResults = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		contentView.searchBar.delegate = self
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		contentView.searchBar.becomeFirstResponder()
	}
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	override func handleNavigation() {
		if touchStartView is RegistrationNextButton {
			self.navigationController?.pushViewController(TutorBio(), animated: true)
		}
	}
}

extension TutorAddSubjects : UISearchBarDelegate {
	
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
		//		if let searchString = contentView.searchBar.text {
		//			let predicate = NSPredicate(format: "SELF contains[c] %@", searchString)
		//
		//			filteredSchools = schoolArray.filtered(using: predicate) as NSArray
		//
		//			if filteredSchools.count > 0 {
		//				scrollToTop()
		//			}
		//		}
		contentView.tableView.reloadData()
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.view.endEditing(true)
	}
}

