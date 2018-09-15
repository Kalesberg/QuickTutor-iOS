//
//  SearchSubjects.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class SearchSubjectsView : SearchLayoutView, Keyboardable {
	
	var keyboardComponent = ViewComponent()
	var filters = NavbarButtonLines()
	var backButton = NavbarButtonX()
	
	let headerView = SectionHeader()
	override var leftButton : NavbarButton {
		get {
			return backButton
		} set {
			backButton = newValue as! NavbarButtonX
		}
	}
	
	let collectionView : UICollectionView = {
		
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		
		let customLayout = SubjectSearchCollectionViewLayout(cellsPerRow: 3, minimumInteritemSpacing: 15, minimumLineSpacing: 15, sectionInset: UIEdgeInsets(top: 1, left: 10, bottom: 1, right: 10))
		
		collectionView.collectionViewLayout = customLayout
		collectionView.backgroundColor = .clear
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.tag = 0
		
		return collectionView
	}()
	
	let categoryCollectionView : UICollectionView = {
		
		let collectionView : UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		let layout = UICollectionViewFlowLayout()
		
		layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 1)
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 0.0
		layout.itemSize.width = 100
		
		collectionView.collectionViewLayout = layout
		collectionView.backgroundColor = .clear
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.tag = 1
		
		return collectionView
	}()
	
	let tableView : UITableView = {
		let tblView = UITableView()
		
		tblView.rowHeight = UITableViewAutomaticDimension
		tblView.estimatedRowHeight = 44
		tblView.separatorInset.left = 0
		tblView.separatorStyle = .none
		tblView.showsVerticalScrollIndicator = false
		tblView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		
		tblView.alpha = 0.0
		
		return tblView
	}()
	
	override func configureView() {
		addSubview(collectionView)
		addSubview(categoryCollectionView)
		addSubview(tableView)
		addSubview(keyboardView)
		super.configureView()
		headerView.backgroundColor = Colors.backgroundDark
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		collectionView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-10)
			make.height.equalToSuperview().dividedBy(2.5)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
		}
		categoryCollectionView.snp.makeConstraints { (make) in
			make.top.equalTo(collectionView.snp.bottom)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.1)
		}
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom)
			make.bottom.equalTo(safeAreaLayoutGuide)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
	}
	override func layoutSubviews() {
		layoutIfNeeded()
	}
}

class SearchSubjects: BaseViewController {
	
	override var contentView: SearchSubjectsView {
		return view as! SearchSubjectsView
	}
	
	override func loadView() {
		view = SearchSubjectsView()
	}
	
	var categories : [Category] = [.academics, .arts, .auto, .business, .experiences, .health, .language, .outdoors, .remedial, .sports, .tech, .trades]
	
	var initialSetup : Bool = false

	var subjects : [String] = []
	
	var automaticScroll : Bool = false
	
	var filteredSubjects : [String] = []
	
	var shouldUpdateSearchResults = false
	
	var selectedCategory : Int = 6 {
		didSet {
			DispatchQueue.main.async {
				self.contentView.collectionView.reloadData()
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		hideKeyboardWhenTappedAround()
		configureDelegates()
		
		SubjectStore.readCategory(resource: categories[selectedCategory].subcategory.fileToRead) { (subjects) in
			self.subjects = subjects
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let initialIndex : IndexPath! = IndexPath(item: categories.count / 2, section: 0)
		
		if !initialSetup && initialIndex != nil{
			contentView.categoryCollectionView.selectItem(at: initialIndex, animated: false, scrollPosition: .centeredHorizontally)
			contentView.searchTextField.textField.attributedPlaceholder = NSAttributedString(string: categories[selectedCategory].subcategory.phrase, attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
			initialSetup = true
		}
		contentView.collectionView.reloadData()
	}
	
	private func configureDelegates() {
		contentView.collectionView.delegate = self
		contentView.collectionView.dataSource = self
		contentView.collectionView.register(SubjectCollectionViewCell.self, forCellWithReuseIdentifier: "subjectCollectionViewCell")
		
		contentView.categoryCollectionView.delegate = self
		contentView.categoryCollectionView.dataSource = self
		contentView.categoryCollectionView.register(CategorySelectionCollectionViewCell.self, forCellWithReuseIdentifier: "categoryCollectionViewCell")
		
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		contentView.tableView.register(SubjectTableViewCell.self, forCellReuseIdentifier: "subjectTableViewCell")
		
		contentView.searchTextField.textField.delegate = self
		contentView.searchTextField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@objc private func textFieldDidChange(_ textField: UITextField) {
		automaticScroll = true
		
		if textField.text == "" {
			scrollToTop()
			filteredSubjects = subjects
			contentView.tableView.reloadData()
			automaticScroll = false
			return
		}

		shouldUpdateSearchResults = true
		filteredSubjects = subjects.filter({$0.contains(textField.text!.lowercased())})
		contentView.tableView.reloadData()
		
		if filteredSubjects.count > 0 {
			scrollToTop()
		}
	}
	private func tableView(shouldDisplay bool: Bool) {
		contentView.searchTextField.textField.text = ""
		
		UIView.animate(withDuration: 0.5, animations: {
			self.contentView.collectionView.alpha = bool ? 0.0 : 1.0
			return
		})
		
		UIView.animate(withDuration: 0.5, animations: {
			self.contentView.tableView.alpha = bool ? 1.0 : 0.0
		})
	}
	
	func newCategorySelected(_ indexPath : Int) {
		
		UIView.animate(withDuration: 0.5, animations: {
			self.contentView.collectionView.alpha = 0.0
			return
		})
		
		selectedCategory = indexPath
		filteredSubjects = []
		contentView.tableView.reloadData()
		
		UIView.animate(withDuration: 0.5, animations: {
			self.contentView.collectionView.alpha = 1.0
			self.contentView.searchTextField.textField.attributedPlaceholder =  NSAttributedString(string: self.categories[self.selectedCategory].subcategory.phrase, attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
			return
		})
	}

	override func handleNavigation() {
		if touchStartView is NavbarButtonX {
			if shouldUpdateSearchResults {
				
				tableView(shouldDisplay: false)
				shouldUpdateSearchResults = false
				filteredSubjects = []
				contentView.tableView.reloadData()
				self.dismissKeyboard()
			} else{
				self.dismissKeyboard()
				navigationController?.popViewController(animated: true)
			}
		}
	}
}

extension SearchSubjects : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView.tag == 0 {
			return 6
		} else {
			return 12
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView.tag == 0 {
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subjectCollectionViewCell", for: indexPath) as! SubjectCollectionViewCell
			cell.imageView.image = categories[selectedCategory].subcategory.icon[indexPath.item]
			cell.label.text = categories[selectedCategory].subcategory.subcategories[indexPath.item]
			
			return cell
			
		} else {
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCollectionViewCell", for: indexPath) as! CategorySelectionCollectionViewCell
			
			cell.category.text = categories[indexPath.item].subcategory.displayName
			
			return cell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView.tag == 1  {
			shouldUpdateSearchResults = true
			newCategorySelected(indexPath.item)
			SubjectStore.readCategory(resource: categories[selectedCategory].subcategory.fileToRead) { (subjects) in
				self.subjects = subjects
			}
			filteredSubjects = subjects
			contentView.tableView.reloadData()
			
		} else {
			let next = TutorConnect()
			next.subcategory = categories[selectedCategory].subcategory.subcategories[indexPath.item]
			self.present(next, animated: true, completion: nil)
		}
	}
}
extension SearchSubjects : UITableViewDelegate, UITableViewDataSource {
	
	internal func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if shouldUpdateSearchResults {
			return filteredSubjects.count
		}
		return subjects.count
	}
	
	internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "subjectTableViewCell", for: indexPath) as! SubjectTableViewCell
		if shouldUpdateSearchResults {
			cell.subject.text = (filteredSubjects[indexPath.row])
		}
		return cell
	}
	
	internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let subject = tableView.cellForRow(at: indexPath) as! SubjectTableViewCell
		
		SubjectStore.findSubCategory(resource: categories[selectedCategory].mainPageData.displayName.lowercased(), subject: subject.subject.text!) { (key) in
			let next = TutorConnect()
			next.subject = (key, subject.subject.text!)
			self.present(next, animated: true, completion: nil)
		}
	}
	
	internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return contentView.headerView
	}
	
	internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 50
	}
}

extension SearchSubjects : UIPopoverPresentationControllerDelegate {
	func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
		return .overCurrentContext
	}
}

extension SearchSubjects : UITextFieldDelegate {
	
	private func scrollToTop() {
		contentView.tableView.reloadData()
		let indexPath = IndexPath(row: 0, section: 0)
		contentView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
		automaticScroll = false
	}
	
	func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		if !automaticScroll {
			self.view.endEditing(true)
		}
	}

	internal func textFieldDidBeginEditing(_ textField: UITextField) {
		shouldUpdateSearchResults = true
		tableView(shouldDisplay: true)
	}
}
