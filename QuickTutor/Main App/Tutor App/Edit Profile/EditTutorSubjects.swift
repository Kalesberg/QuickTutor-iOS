//
//  EditTutorSubjects.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/18/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class EditTutorSubjectsView : MainLayoutTwoButton, Keyboardable {
	
	var keyboardComponent = ViewComponent()
	
	let headerView = SectionHeader()
	
	let nextButton = TutorPreferencesNextButton()

	let noSelectedItemsLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.textAlignment = .center
		label.font = Fonts.createSize(16)
		label.adjustsFontSizeToFitWidth = true
		label.text = "Add subjects you would like to teach"
		
		return label
	}()
	var searchTextField : UITextField!
	
	let searchBar : UISearchBar = {
		let searchBar = UISearchBar()
		
		searchBar.sizeToFit()
		searchBar.searchBarStyle = .minimal
		searchBar.backgroundImage = UIImage(color: UIColor.clear)
		
		return searchBar
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
		collectionView.tag = 1
		
		return collectionView
	}()
	
	let categoryCollectionView : UICollectionView = {
		let collectionView : UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		let layout = UICollectionViewFlowLayout()
		
		layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 0.0
		
		collectionView.backgroundColor = Colors.backgroundDark
		collectionView.collectionViewLayout = layout
		collectionView.backgroundColor = .clear
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.isPagingEnabled = true
		collectionView.decelerationRate = UIScrollViewDecelerationRateFast
		
		collectionView.tag = 0
		
		return collectionView
	}()
	
	let tableView : UITableView = {
		let tableView = UITableView()
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 44
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		tableView.allowsMultipleSelection = true
		tableView.alpha = 0.0
		
		return tableView
	}()
	
	var backButton = NavbarButtonX()
	var cancelButton = NavbarButtonDone()
	
	override var leftButton : NavbarButton {
		get {
			return backButton
		} set {
			backButton = newValue as! NavbarButtonX
		}
	}
	override var rightButton: NavbarButton  {
		get {
			return cancelButton
		} set {
			cancelButton = newValue as! NavbarButtonDone
		}
	}
	
	override func configureView() {
		addSubview(noSelectedItemsLabel)
		addSubview(categoryCollectionView)
		addSubview(pickedCollectionView)
		addSubview(tableView)
		addSubview(nextButton)
		navbar.addSubview(searchBar)
		addSubview(keyboardView)
		super.configureView()
		
		searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		searchTextField?.font = Fonts.createSize(16)
		searchTextField?.textColor = .white
		searchTextField?.adjustsFontSizeToFitWidth = true
		searchTextField?.autocapitalizationType = .words
		searchTextField?.attributedPlaceholder = NSAttributedString(string: "Search for anything", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		searchTextField?.keyboardAppearance = .dark
		
		
		backButton.image.image = #imageLiteral(resourceName: "backButton")
		nextButton.label.text = "Save"
		cancelButton.label.label.text = "Add"
		headerView.backgroundColor = Colors.backgroundDark
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		searchBar.snp.makeConstraints { (make) in
			make.left.equalTo(backButton.snp.right)
			make.right.equalTo(rightButton.snp.left)
			make.height.equalToSuperview()
			make.centerY.equalTo(backButton.image)
		}
        
		noSelectedItemsLabel.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-6)
			make.height.equalTo(45)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
		}
        
		pickedCollectionView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-6)
			make.height.equalTo(45)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
		}

		categoryCollectionView.snp.makeConstraints { (make) in
			make.top.equalTo(pickedCollectionView.snp.bottom).inset(-6)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
            if UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480 {
                make.height.equalTo(235)
            } else {
                make.height.equalTo(295)
            }
		}
		
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(pickedCollectionView.snp.bottom).inset(-10)
			make.bottom.equalTo(safeAreaLayoutGuide)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
		nextButton.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
			if (UIScreen.main.bounds.height == 812) {
				make.height.equalTo(80)
			} else {
				make.height.equalTo(60)
			}
		}
	}
	
	override func layoutSubviews() {
		layoutIfNeeded()
		navbar.backgroundColor = Colors.tutorBlue
		statusbarView.backgroundColor = Colors.tutorBlue
	}
}


class EditTutorSubjects : BaseViewController {
	
	override var contentView: EditTutorSubjectsView {
		return view as! EditTutorSubjectsView
	}
	override func loadView() {
		view = EditTutorSubjectsView()
	}
	
	let ref : DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)
	
	var shouldUpdateSearchResults = false
	
	var didSelectCategory = false {
		didSet {
			if didSelectCategory == false {
				contentView.headerView.category.text = ""
			}
		}
	}
	
	var categories : [Category] = [.academics, .arts, .auto, .business, .experiences, .health, .language, .outdoors, .remedial, .sports, .tech, .trades]
	
	var tutor : AWTutor!
	
	var selectedSubjects : [String] = [] {
		didSet {
			contentView.noSelectedItemsLabel.isHidden = !selectedSubjects.isEmpty
			contentView.categoryCollectionView.reloadData()
		}
	}
	var selected : [Selected] = [] {
		didSet {
			contentView.categoryCollectionView.reloadData()
		}
	}
	
	var automaticScroll : Bool = false
	
	var initialSetup : Bool = false
	
	var filteredSubjects : [(String, String)] = []
	var partialSubjects : [(String, String)] = []
	var allSubjects : [(String, String)] = []
	
	var tableViewIsActive : Bool = false {
		didSet {
			contentView.backButton.image.image = tableViewIsActive ? #imageLiteral(resourceName: "navbar-x") : #imageLiteral(resourceName: "backButton")
			contentView.nextButton.isHidden = tableViewIsActive
			shouldUpdateSearchResults = tableViewIsActive
		}
	}
	
	var selectedCategory : Int = 6 {
		didSet {
			DispatchQueue.main.async {
				self.contentView.categoryCollectionView.reloadData()
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		hideKeyboardWhenTappedAround()
		configureDelegates()
		
		if let subjects = SubjectStore.loadTotalSubjectList() {
			self.allSubjects = subjects
			self.allSubjects.shuffle()
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
			initialSetup = true
		}
		contentView.categoryCollectionView.reloadData()
	}
	private func configureDelegates() {
		
		contentView.pickedCollectionView.delegate = self
		contentView.pickedCollectionView.dataSource = self
		contentView.pickedCollectionView.register(PickedSubjectsCollectionViewCell.self, forCellWithReuseIdentifier: "pickedCollectionViewCell")
		
		contentView.categoryCollectionView.delegate = self
		contentView.categoryCollectionView.dataSource = self
		contentView.categoryCollectionView.register(CategorySelectionCollectionViewCell.self, forCellWithReuseIdentifier: "categoryCollectionViewCell")
		
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		contentView.tableView.register(AddSubjectsTableViewCell.self, forCellReuseIdentifier: "addSubjectsCell")
		
		contentView.searchBar.delegate = self
		
	}
	
	
	private func tableView(shouldDisplay bool: Bool, _ completion: @escaping () -> Void) {
		tableViewIsActive = bool
		UIView.animate(withDuration: 0.25, animations: {
			self.contentView.categoryCollectionView.alpha = bool ? 0.0 : 1.0
			return
		})
		
		UIView.animate(withDuration: 0.25, animations: {
			self.contentView.tableView.alpha = bool ? 1.0 : 0.0
			completion()
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
			
			self.contentView.nextButton.label.text = "Save (\(self.selected.count))"

			self.contentView.noSelectedItemsLabel.isHidden = (self.selectedSubjects.count == 0) ? false : true
			
			self.contentView.tableView.reloadData()
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	private func deleteSubjects() {
		
		var currentSubs: [String] = []
		var newSubs : [String] = []
		var subcategoriesToDelete : [String] = []
		
		for i in tutor.selected {
			currentSubs.append(i.path)
		}
		
		for j in selected {
			newSubs.append(j.path)
		}
		
		for k in currentSubs.unique {
			if !newSubs.contains(k) {
				subcategoriesToDelete.append(k)
			}
		}
		
		for i in 0..<subcategoriesToDelete.count {
		
			print("subjectToDelete", subcategoriesToDelete[i])
			
			self.ref.child("subcategory").child(subcategoriesToDelete[i].lowercased()).child(Auth.auth().currentUser!.uid).removeValue()
			self.ref.child("subject").child(Auth.auth().currentUser!.uid).child(subcategoriesToDelete[i].lowercased()).removeValue()
		}
		
		tutor.subjects = self.selectedSubjects
		tutor.selected = self.selected
		
	}
	
	private func saveSubjects() {
		
		var subcategories : [String] = []
		var subjectDict = [String : [String]]()
		
		var post : [String : Any] = [:]
		print(selected)
		for i in selected {
			subcategories.append(i.path)
		}

		for subcategory in subcategories.unique {
			
			let path = subcategory
			var arr : [String] = []
			
			for subject in selected {
				if path == subject.path {
					arr.append(subject.subject)
				}
			}
			subjectDict[path] = arr
		}
		
		var updateSubjectValues 	= [String : Any]()
		var updateSubcategoryValues = [String : Any]()
		
		for key in subjectDict {
			
			let subjects = key.value.compactMap({$0}).joined(separator: "$")
			
			updateSubjectValues["/subject/\(Auth.auth().currentUser!.uid)/\(key.key.lowercased())"] = ["p": tutor.price!, "r" : 5, "sbj" : subjects, "hr" : 0, "nos" : 0]
			
			updateSubcategoryValues["/subcategory/\(key.key.lowercased())/\(Auth.auth().currentUser!.uid)"] = ["r" : 5, "p" : tutor.price!, "dst" : tutor.distance!, "hr" : 0,"nos" : 0, "sbj" : subjects]
		}
		print("UpdatedSubject: ", updateSubjectValues)
		
		post.merge(updateSubjectValues) { (_, last) in last }
		post.merge(updateSubcategoryValues) { (_, last) in last }
		
		ref.root.updateChildValues(post) { (error, databaseRef) in
			if let error = error {
				print(error.localizedDescription)
			}
			
			CurrentUser.shared.tutor.subjects = self.selectedSubjects
			CurrentUser.shared.tutor.selected = self.selected
			
			self.displaySavedAlertController()
		}
	}
	
	private func displaySavedAlertController() {
		let alertController = UIAlertController(title: "Saved!", message: "Your changes have been saved", preferredStyle: .alert)
		
		self.present(alertController, animated: true, completion: nil)
		
		let when = DispatchTime.now() + 1
		
		DispatchQueue.main.asyncAfter(deadline: when){
			alertController.dismiss(animated: true){
				self.navigationController?.popViewController(animated: true)
			}
		}
		
	}
	private func backButtonAlert() {
		let alertController = UIAlertController(title: "Are You Sure?", message: "All of your progress will be deleted.", preferredStyle: .alert)
		
		let okButton = UIAlertAction(title: "Ok", style: .destructive) { (alert) in
			self.navigationController?.popViewController(animated: true)
			
		}
		
		let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
			
		}
		
		alertController.addAction(okButton)
		alertController.addAction(cancelButton)
		
		self.present(alertController, animated: true, completion: nil)
	}
	override func handleNavigation() {
		if touchStartView is TutorPreferencesNextButton {
			deleteSubjects()
			saveSubjects()
		} else if touchStartView is NavbarButtonDone {
			tableView(shouldDisplay: false) {
				self.didSelectCategory = false
				self.contentView.searchBar.text = ""
			}
		} else if touchStartView is NavbarButtonX {
			tableViewIsActive ? tableView(shouldDisplay: false) {
				self.didSelectCategory = false
				self.contentView.searchBar.text = ""
				} : backButtonAlert()
		}
	}
}

extension EditTutorSubjects : SelectedSubcategory {
	
	func didSelectSubcategory(resource: String, subject: String, index: Int) {

		if let subjects = SubjectStore.readSubcategory(resource: resource, subjectString: subject) {
			self.partialSubjects = subjects
			self.filteredSubjects = self.partialSubjects
			self.contentView.headerView.category.text = subject
			
		}
		
		tableView(shouldDisplay: true) {
			self.didSelectCategory = true
			self.contentView.searchBar.becomeFirstResponder()
			self.scrollToTop()
			self.contentView.tableView.reloadData()
		}
	}
}

extension EditTutorSubjects : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		if collectionView.tag == 0 {
			return categories.count
		} else {
			return selectedSubjects.count
		}
	}
	
	internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView.tag == 0 {
			
			return CGSize(width: UIScreen.main.bounds.width - 20, height: collectionView.frame.height)
		} else {
			if selectedSubjects.count > 0 {
				return CGSize(width: (selectedSubjects[indexPath.row] as NSString).size(withAttributes: nil).width + 55, height: 30)
			} else {
				return CGSize(width: 60, height: 30)
			}
		}
	}
	
	internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView.tag == 0 {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCollectionViewCell", for: indexPath) as! CategorySelectionCollectionViewCell
			
			cell.category = categories[indexPath.item]
			cell.delegate = self
			
			return cell
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pickedCollectionViewCell", for: indexPath) as! PickedSubjectsCollectionViewCell
			cell.subject.text = selectedSubjects[indexPath.item]
			return cell
		}
	}
	
	internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView.tag == 1 {
			let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
			
			let remove = UIAlertAction(title: "Remove", style: .destructive) { (_) in
				self.removeItem(item: indexPath.item)
			}
			
			let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			
			alert.addAction(remove)
			alert.addAction(cancel)
			
			self.present(alert, animated: true)
		}
	}
	
	internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		
		if collectionView.tag == 0 {
			return 20
		}
		return 0
	}
}

extension EditTutorSubjects : UITableViewDelegate, UITableViewDataSource {
	
	internal func numberOfSections(in tableView: UITableView) -> Int {
		
		if shouldUpdateSearchResults {
			return filteredSubjects.count
		}
		return allSubjects.count
	}
	
	internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "addSubjectsCell", for: indexPath) as! AddSubjectsTableViewCell
		
		if shouldUpdateSearchResults {
			cell.subcategory.isHidden = didSelectCategory
			cell.subject.text = filteredSubjects[indexPath.section].0
			cell.subcategory.text = filteredSubjects[indexPath.section].1
			cell.selectedIcon.isSelected = selectedSubjects.contains(filteredSubjects[indexPath.section].0)
			
		} else {
			
			cell.subject.text = allSubjects[indexPath.section].0
			cell.subcategory.text = allSubjects[indexPath.section].1
			cell.selectedIcon.isSelected = selectedSubjects.contains(allSubjects[indexPath.section].0)
		}
		return cell
	}
	
	internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 55
	}
	
	internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 0 {
			return contentView.headerView
		}
		let view : UIView = {
			let view  = UIView()
			
			view.backgroundColor = Colors.darkBackground
			
			return view
		}()
		
		return view
	}
	
	internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if section == 0 {
			return 50
		}
		return 5
	}
	
	internal func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if section != 0{
			return 5
		}
		return 0
	}
	
	internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if selectedSubjects.count > 20 {
			
			print("Too many subjects")
			tableView.deselectRow(at: indexPath, animated: true)
			return
		}
		
		guard let cell = tableView.cellForRow(at: indexPath) as? AddSubjectsTableViewCell else { return }
		
		if selectedSubjects.contains(cell.subject.text!) {
			
			cell.selectedIcon.isSelected = false
			
			removeItem(item: selectedSubjects.index(of: cell.subject.text!)!)
			
			tableView.deselectRow(at: indexPath, animated: true)
			
			return
		}
		
		cell.selectedIcon.isSelected = true
		
		self.contentView.noSelectedItemsLabel.isHidden = true
		
		selectedSubjects.append(cell.subject.text!)
		
		self.selected.append(Selected(path: cell.subcategory.text!, subject: cell.subject.text!))
		
		let index = IndexPath(item: selectedSubjects.endIndex - 1, section: 0)
		
		contentView.pickedCollectionView.performBatchUpdates({ [weak self] () -> Void in
			
			self?.contentView.pickedCollectionView.insertItems(at: [index])
			
			},completion: nil)
		
		let endIndex = IndexPath(item: selectedSubjects.count - 1, section: 0)
		
		contentView.pickedCollectionView.scrollToItem(at: endIndex, at: .right, animated: true)
		
		contentView.pickedCollectionView.reloadData()
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		self.contentView.nextButton.label.text = "Save (\(self.selected.count))"
	}
}

extension EditTutorSubjects : UISearchBarDelegate {
	
	internal func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		if searchBar.text!.count < 1 {
			if didSelectCategory {
				contentView.tableView.reloadData()
			}
		} else {
			tableView(shouldDisplay: true) {}
		}
	}
	
	internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		automaticScroll = true
		
		if searchText == ""  {
			
			tableView(shouldDisplay: false) {
				self.didSelectCategory = false
				self.contentView.searchBar.text = ""
				self.automaticScroll = false
			}
			return
		}
		
		if didSelectCategory {
			filteredSubjects = partialSubjects.filter({$0.0.contains(searchText.lowercased())})
			contentView.tableView.reloadData()
			return
			
		} else {
			tableView(shouldDisplay: true) {
				self.filteredSubjects = self.allSubjects.filter({$0.0.contains(searchText.lowercased())})
				self.contentView.tableView.reloadData()
			}
		}
		if filteredSubjects.count > 0 {
			scrollToTop()
		}
	}
}

extension EditTutorSubjects : UIScrollViewDelegate {
	
	func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		if !automaticScroll {
			self.view.endEditing(true)
		}
	}
	
//	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//		let x = scrollView.contentOffset.x
//		let w = scrollView.bounds.size.width
//		let currentPage = Int(ceil(x / w))
//
//	}
	private func scrollToTop() {
		contentView.tableView.reloadData()
		let indexPath = IndexPath(row: 0, section: 0)
		contentView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
		automaticScroll = false
	}
}
