//
//  TutorAddSubjects.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/14/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
/*
	Tutors must pick a subcategory before being allowed to search
	There should probably be a 'Done' button top right and not a next button on this frame.
 	need a title that can disappear and come back
	This could probably be in a tableview, but i wanted to know how the icons looked at their sizes before committing to a change like that.
	I feel like the size of those icons will change alot about this page.
*/

import Foundation
import UIKit

struct Selected {
	let path : String
	let subject : String
}

class TutorAddSubjectsView : MainLayoutTwoButton, Keyboardable {
	
	var keyboardComponent = ViewComponent()
	
	let headerView = SectionHeader()
	
	let noSelectedItemsLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .center
		label.font = Fonts.createSize(16)
		label.adjustsFontSizeToFitWidth = true
		label.text = "Add subjects you would like to teach"
		
		return label
	}()
	
	let searchBar : UISearchBar = {
		let searchBar = UISearchBar()
		
		searchBar.sizeToFit()
		searchBar.searchBarStyle = .minimal
		searchBar.backgroundImage = UIImage(color: UIColor.clear)
		
		let textField = searchBar.value(forKey: "searchField") as? UITextField
		textField?.font = Fonts.createSize(16)
		textField?.textColor = .white
		textField?.adjustsFontSizeToFitWidth = true
		textField?.autocapitalizationType = .words
		textField?.attributedPlaceholder = NSAttributedString(string: "Experiences", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		textField?.keyboardAppearance = .dark
		
		return searchBar
	}()
	
	let customLayout = SubjectSearchCollectionViewLayout(cellsPerRow: 3, minimumInteritemSpacing: 15, minimumLineSpacing: 15, sectionInset: UIEdgeInsets(top: 1, left: 10, bottom: 1, right: 10))
	
	let collectionView : UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		
		collectionView.backgroundColor = .clear
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.tag = 0
		
		return collectionView
	}()
	
	let pickedCollectionView : UICollectionView = {
		let collectionView : UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		let layout = UICollectionViewFlowLayout()
		
		layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 5.0
		layout.minimumLineSpacing = 5.0
		layout.itemSize.width = 40
		
		collectionView.collectionViewLayout = layout
		collectionView.backgroundColor = .clear
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.tag = 2
		
		return collectionView
	}()
	
	let categoryCollectionView : UICollectionView = {
		let collectionView : UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		let layout = UICollectionViewFlowLayout()
		
		layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 1)
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 0.0
		
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
		tblView.allowsMultipleSelection = true
		tblView.alpha = 0.0
		
		return tblView
	}()
	
    var backButton = NavbarButtonX()
    var doneButton = NavbarButtonDone()
    
	override var leftButton : NavbarButton {
		get {
			return backButton
		} set {
			backButton = newValue as! NavbarButtonX
		}
	}
    
    override var rightButton : NavbarButton {
        get {
            return doneButton
        } set {
            doneButton = newValue as! NavbarButtonDone
        }
    }
	
	override func configureView() {
		addSubview(noSelectedItemsLabel)
		addSubview(collectionView)
		addSubview(categoryCollectionView)
		addSubview(pickedCollectionView)
		addSubview(tableView)
		navbar.addSubview(searchBar)
		addSubview(keyboardView)
		super.configureView()
	
		headerView.backgroundColor = Colors.backgroundDark
		backButton.image.image = #imageLiteral(resourceName: "back-button")
		collectionView.collectionViewLayout = customLayout

		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		searchBar.snp.makeConstraints { (make) in
			make.top.equalTo(backButton.snp.top)
			make.left.equalTo(backButton.snp.right)
			make.right.equalToSuperview()
			make.height.equalToSuperview()
		}
		noSelectedItemsLabel.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-10)
			make.height.equalTo(45)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
		}
		pickedCollectionView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-10)
			make.height.equalTo(45)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
		}
		
		collectionView.snp.makeConstraints { (make) in
			make.top.equalTo(pickedCollectionView.snp.bottom).inset(-10)
			make.height.equalToSuperview().dividedBy(2.8)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
		}
		categoryCollectionView.snp.makeConstraints { (make) in
			make.top.equalTo(collectionView.snp.bottom).inset(-10)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			make.height.equalTo(35)
		}
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(pickedCollectionView.snp.bottom).inset(-10)
			make.bottom.equalTo(safeAreaLayoutGuide)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
	}
	
	override func layoutSubviews() {
		layoutIfNeeded()
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
	
	var categories : [Category] = [.academics, .arts, .auto, .business, .experiences, .health, .language, .outdoors, .remedial, .sports, .tech, .trades]
	
	var selectedSubjects : [String] = []
	
	var automaticScroll : Bool = false
	
	var initialSetup : Bool = false
	
	var subIndex : Int?
	
	var index : Int = 0
	
	var subjects : [String] = []
	
	var filteredSubjects : [String] = []
	
	var selected : [Selected] = []
	
	var tableViewIsActive : Bool = false {
		didSet {
			contentView.backButton.image.image = tableViewIsActive ? #imageLiteral(resourceName: "navbar-x") : #imageLiteral(resourceName: "back-button")
		}
	}
	
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
		
		let initialIndex = IndexPath(item: categories.count / 2, section: 0)
		
		if !initialSetup {
			contentView.categoryCollectionView.selectItem(at: initialIndex, animated: false, scrollPosition: .centeredHorizontally)
			contentView.searchBar.placeholder = self.categories[self.selectedCategory].subcategory.phrase
			initialSetup = true
		}
		
		contentView.collectionView.reloadData()
	}
	private func configureDelegates() {
		
		contentView.pickedCollectionView.delegate = self
		contentView.pickedCollectionView.dataSource = self
		contentView.pickedCollectionView.register(PickedSubjectsCollectionViewCell.self, forCellWithReuseIdentifier: "pickedCollectionViewCell")
		
		contentView.collectionView.delegate = self
		contentView.collectionView.dataSource = self
		contentView.collectionView.register(SubjectCollectionViewCell.self, forCellWithReuseIdentifier: "subjectCollectionViewCell")
		
		contentView.categoryCollectionView.delegate = self
		contentView.categoryCollectionView.dataSource = self
		contentView.categoryCollectionView.register(CategorySelectionCollectionViewCell.self, forCellWithReuseIdentifier: "categoryCollectionViewCell")
		
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		contentView.tableView.register(AddSubjectsTableViewCell.self, forCellReuseIdentifier: "addSubjectsCell")
		
		contentView.searchBar.delegate = self
		
	}


	private func tableView(shouldDisplay bool: Bool) {
		contentView.searchBar.text = ""
		tableViewIsActive = !tableViewIsActive
		UIView.animate(withDuration: 0.5, animations: {
			self.contentView.collectionView.alpha = bool ? 0.0 : 1.0
			return
		})
		
		UIView.animate(withDuration: 0.5, animations: {
			self.contentView.tableView.alpha = bool ? 1.0 : 0.0
			return
		})
	}
	
	private func removeItem (item: Int) {
		
		selectedSubjects.remove(at: item)
		selected.remove(at: item)
		
		let indexPath = IndexPath(row: item, section: 0)
		
		self.contentView.pickedCollectionView.performBatchUpdates({
			
			self.contentView.pickedCollectionView.deleteItems(at: [indexPath])
		
		}) { (finished) in
			
			self.contentView.pickedCollectionView.reloadItems(at:
				self.contentView.pickedCollectionView.indexPathsForVisibleItems)
			self.contentView.noSelectedItemsLabel.isHidden = (self.selectedSubjects.count == 0) ? false : true
			self.contentView.tableView.reloadData()
		}
	}
	
	private func newCategorySelected(_ indexPath : Int) {
		
		UIView.animate(withDuration: 0.5, animations: {
			self.contentView.collectionView.alpha = 0.0
			return
		})
		
		selectedCategory = indexPath
		SubjectStore.readCategory(resource: self.categories[selectedCategory].subcategory.fileToRead) { (subjects) in
			self.subjects = subjects
		}
		filteredSubjects = []
		contentView.tableView.reloadData()
		
		UIView.animate(withDuration: 0.5, animations: {
			self.contentView.collectionView.alpha = 1.0
			self.contentView.searchBar.placeholder =  self.categories[self.selectedCategory].subcategory.phrase
			return
		})
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func handleNavigation() {
		if touchStartView is NavbarButtonX {
			if tableViewIsActive {
				
				SubjectStore.readCategory(resource: categories[selectedCategory].subcategory.fileToRead) { (subjects) in
					self.subjects = subjects
				}
				
				tableView(shouldDisplay: false)
				shouldUpdateSearchResults = false
				filteredSubjects = []
				subIndex = nil
				self.dismissKeyboard()
			
			} else {
				self.dismissKeyboard()
				navigationController?.popViewController(animated: true)
			}
		
		} else if touchStartView is NavbarButtonDone {
			TutorRegistration.subjects = selected
			navigationController?.pushViewController(TutorBio(), animated: true)
		}
	}
}

extension TutorAddSubjects : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView.tag == 0 {
			return 6
		} else if collectionView.tag == 1 {
			return 12
		} else {
			return selectedSubjects.count
		}
	}
	
	internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView.tag == 0 {
			return contentView.customLayout.itemSize
		} else if collectionView.tag == 1 {
			return CGSize(width: (categories[indexPath.item].subcategory.displayName as NSString).size(withAttributes: nil).width + 30, height: 35)
		} else {
			if selectedSubjects.count > 0 {
				return CGSize(width: (selectedSubjects[indexPath.row] as NSString).size(withAttributes: nil).width + 35, height: 30)
			} else {
				return CGSize(width: 60, height: 30)
			}
		}
	}

	internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView.tag == 0 {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subjectCollectionViewCell", for: indexPath) as! SubjectCollectionViewCell
			cell.imageView.image = categories[selectedCategory].subcategory.icon[indexPath.item]
			cell.label.text = categories[selectedCategory].subcategory.subcategories[indexPath.item]
			
			return cell
		} else if collectionView.tag == 1 {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCollectionViewCell", for: indexPath) as! CategorySelectionCollectionViewCell
			
			cell.category.text = categories[indexPath.item].subcategory.displayName
			
			return cell
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pickedCollectionViewCell", for: indexPath) as! PickedSubjectsCollectionViewCell
			cell.subject.text = selectedSubjects[indexPath.item]
			return cell
		}
	}

	internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch collectionView.tag {
		case 0:

			shouldUpdateSearchResults = true
			
			SubjectStore.readSubcategory(resource: self.categories[selectedCategory].subcategory.fileToRead, subjectString: categories[selectedCategory].subcategory.subcategories[indexPath.item]) { (subjects) in
				self.filteredSubjects = subjects
				self.contentView.tableView.reloadData()
				self.scrollToTop()
			}
			
			subIndex = indexPath.item
			contentView.headerView.category.text = self.categories[selectedCategory].subcategory.subcategories[subIndex!]
			tableView(shouldDisplay: true)
		
		case 1:
			newCategorySelected(indexPath.item)
			collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
		case 2:
			let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
			
			let remove = UIAlertAction(title: "Remove", style: .destructive) { (_) in
				self.removeItem(item: indexPath.item)
			}
			
			let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			
			alert.addAction(remove)
			alert.addAction(cancel)
			
			self.present(alert, animated: true)
			
		default:
			break
		}
	}
}

extension TutorAddSubjects : UITableViewDelegate, UITableViewDataSource {
	
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
		let cell = tableView.dequeueReusableCell(withIdentifier: "addSubjectsCell", for: indexPath) as! AddSubjectsTableViewCell
		
		if shouldUpdateSearchResults {
			cell.subject.text = filteredSubjects[indexPath.row]
			if selectedSubjects.contains(filteredSubjects[indexPath.row])  {
				cell.selectedIcon.isSelected = true
			} else{
				cell.selectedIcon.isSelected = false
			}
		} else {
			cell.subject.text = subjects[indexPath.row]
			if selectedSubjects.contains(subjects[indexPath.row])  {
				cell.selectedIcon.isSelected = true
			} else{
				cell.selectedIcon.isSelected = false
			}
		}
		return cell
	}
	
	internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return contentView.headerView
	}
	
	internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 50
	}
	
	internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if selectedSubjects.count > 20 {
			print("Too many subjects")
			tableView.deselectRow(at: indexPath, animated: true)
			return
		}
		guard let cell = tableView.cellForRow(at: indexPath) as? AddSubjectsTableViewCell else {
			return
		}
		
		if selectedSubjects.contains(cell.subject.text!) {
			cell.selectedIcon.isSelected = false
			removeItem(item: selectedSubjects.index(of: cell.subject.text!)!)
			tableView.deselectRow(at: indexPath, animated: true)
			return
		}
		
		cell.selectedIcon.isSelected = true
		
		self.contentView.noSelectedItemsLabel.isHidden = true
		
		selectedSubjects.append(cell.subject.text!)

		SubjectStore.findSubCategory(resource: categories[selectedCategory].mainPageData.displayName.lowercased(), subject: cell.subject.text!) { (subcategory) in
			self.selected.append(Selected(path: "\(subcategory)", subject: cell.subject.text!))
		}
		
		let index = IndexPath(item: selectedSubjects.endIndex - 1, section: 0)
		
		contentView.pickedCollectionView.performBatchUpdates({ [weak self] () -> Void in
			
			self?.contentView.pickedCollectionView.insertItems(at: [index])
			
			}, completion:nil)
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension TutorAddSubjects : UISearchBarDelegate {
	
	internal func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		tableView(shouldDisplay: true)
		if subIndex == nil {
			contentView.headerView.category.text = categories[selectedCategory].mainPageData.displayName
		}
	}
	
	internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		automaticScroll = true

		if searchText == "" {
			scrollToTop()
			filteredSubjects = subjects
			contentView.tableView.reloadData()
			automaticScroll = false
			return
		}
		
		shouldUpdateSearchResults = true
		filteredSubjects = subjects.filter({$0.contains(searchText.lowercased())})
		contentView.tableView.reloadData()
		
		if filteredSubjects.count > 0 {
			scrollToTop()
		}
	}
}
extension TutorAddSubjects : UIScrollViewDelegate {
	
	func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		if !automaticScroll {
			self.view.endEditing(true)
		}
	}
	private func scrollToTop() {
		contentView.tableView.reloadData()
		let indexPath = IndexPath(row: 0, section: 0)
		contentView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
		automaticScroll = false
	}
	

}
