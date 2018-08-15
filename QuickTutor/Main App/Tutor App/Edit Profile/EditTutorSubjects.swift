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

class EditTutorSubjectsView : MainLayoutTitleTwoButton, Keyboardable {
	
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
		searchBar.searchBarStyle = .prominent
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
	
	let categoryTableView : UITableView = {
		let tableView = UITableView(frame: .zero, style: .grouped)
		
		let header = SubjectSearchTableViewHeader()
		header.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 75)
		header.subtitle.text = "Search a subject within any subcategory."
		
		tableView.showsVerticalScrollIndicator = false
		tableView.separatorStyle = .none
		tableView.backgroundColor = Colors.backgroundDark
		tableView.sectionFooterHeight = 3
		tableView.sectionHeaderHeight = 0
		tableView.tableHeaderView = header
		
		tableView.tag = 1
		
		return tableView
	}()
	
	let tableView : UITableView = {
		let tableView = UITableView()

		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 44
		tableView.separatorStyle = .singleLine
		tableView.separatorColor = .black
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = Colors.backgroundDark
		tableView.allowsMultipleSelection = true
		tableView.alpha = 0.0
		tableView.tableFooterView = UIView()

		return tableView
	}()
	
	var cancelButton = NavbarButtonDone()
	
	override var rightButton: NavbarButton  {
		get {
			return cancelButton
		} set {
			cancelButton = newValue as! NavbarButtonDone
		}
	}
	
	var backButton = NavbarButtonXLight()
	
	override var leftButton: NavbarButton  {
		get {
			return backButton
		} set {
			backButton = newValue as! NavbarButtonXLight
		}
	}
	
	override func configureView() {
		addSubview(noSelectedItemsLabel)
		addSubview(categoryTableView)
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
		searchTextField.backgroundColor = UIColor.black.withAlphaComponent(0.5)

		
		backButton.image.image = #imageLiteral(resourceName: "backButton")
		nextButton.label.text = "Save"
		cancelButton.label.label.text = "Add"
		cancelButton.isHidden = true
		
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
		
		categoryTableView.snp.makeConstraints { (make) in
			make.top.equalTo(pickedCollectionView.snp.bottom)
			make.width.equalToSuperview().multipliedBy(0.95)
			make.centerX.equalToSuperview()
			make.bottom.equalTo(nextButton.snp.top)
		}
		
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(pickedCollectionView.snp.bottom)
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaLayoutGuide)
			} else {
				make.bottom.equalToSuperview()
			}
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
	
	var categories : [Category] = [.academics, .arts, .auto, .business, .lifestyle, .health, .language, .outdoors, .remedial, .sports, .tech, .trades]
	
	let ref : DatabaseReference! = Database.database().reference(fromURL: Constants.DATABASE_URL)
	
	var automaticScroll : Bool = false
	var shouldUpdateSearchResults = false
	
	var filteredSubjects = [(String, String)]() {
		didSet {
			if filteredSubjects.count == 0 {
				let backgroundView = TutorCardCollectionViewBackground()
				backgroundView.label.attributedText = NSMutableAttributedString().bold("No Search Results", 22, .white)
				contentView.tableView.backgroundView = backgroundView
			} else {
				contentView.tableView.backgroundView = nil
			}
		}
	}
	var partialSubjects = [(String, String)]()
	var allSubjects = [(String, String)]()
	
	var inlineCellIndexPath : IndexPath?
	
	var didSelectCategory = false {
		didSet {
			if didSelectCategory == false {
				contentView.headerView.category.text = ""
			}
		}
	}
	
	var tutor : AWTutor!
	
	var selectedSubjects = [String]() {
		didSet {
			contentView.noSelectedItemsLabel.isHidden = !selectedSubjects.isEmpty
			contentView.nextButton.label.text = "Save (\(selectedSubjects.count))"
		}
	}
	var removedSubjects = [Selected]()
	
	var selected = [Selected]()
	
	var tableViewIsActive : Bool = false {
		didSet {
			contentView.backButton.image.image = tableViewIsActive ? #imageLiteral(resourceName: "xbuttonlight") : #imageLiteral(resourceName: "backButton")
			contentView.nextButton.isHidden = tableViewIsActive
			contentView.cancelButton.isHidden = !tableViewIsActive
			shouldUpdateSearchResults = tableViewIsActive
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
	}
	
	private func configureDelegates() {
		
		contentView.pickedCollectionView.delegate = self
		contentView.pickedCollectionView.dataSource = self
		contentView.pickedCollectionView.register(PickedSubjectsCollectionViewCell.self, forCellWithReuseIdentifier: "pickedCollectionViewCell")

		contentView.categoryTableView.delegate = self
		contentView.categoryTableView.dataSource = self
		contentView.categoryTableView.register(SubjectSearchCategoryCell.self, forCellReuseIdentifier: "categoryCell")
		contentView.categoryTableView.register(SubjectSearchSubcategoryCell.self, forCellReuseIdentifier: "subcategoryCell")
		
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		contentView.tableView.register(AddSubjectsTableViewCell.self, forCellReuseIdentifier: "addSubjectsCell")
		
		contentView.searchBar.delegate = self
	}
	
	private func tableView(shouldDisplay bool: Bool, _ completion: @escaping () -> Void) {
		tableViewIsActive = bool
		UIView.animate(withDuration: 0.25, animations: {
			return
		})
		
		UIView.animate(withDuration: 0.25, animations: {
			self.contentView.tableView.alpha = bool ? 1.0 : 0.0
			return completion()
		})
	}
	
	private func removeItem (item: Int) {
		removedSubjects.append(selected[item])
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
		var newSubs = [String]()
		var subcategoriesToDelete = [String]()
		
		newSubs = selected.map({$0.path})
		
		for k in tutor.selected.map({$0.path}).unique {
			if !newSubs.contains(k) {
				subcategoriesToDelete.append(k)
			}
		}
		
		for i in 0..<subcategoriesToDelete.count {
			let subject = subcategoriesToDelete[i].lowercased().replacingOccurrences(of: "/", with: "_")
			self.ref.child("subject").child(CurrentUser.shared.learner.uid).child(subject).removeValue()
		}
		
		for subject in removedSubjects {
			let formattedSubject = subject.subject.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "#", with: "<").replacingOccurrences(of: ".", with: ">")
			self.ref.child("subcategory").child(subject.path.lowercased()).child(CurrentUser.shared.learner.uid).child(formattedSubject).removeValue()
		}
		tutor.subjects = self.selectedSubjects
		tutor.selected = self.selected
	}
	private func getSubjectDictionary() -> [String : [String]]? {
		var subjectDict = [String : [String]]()

		for subcategory in selected.map({ $0.path }).unique {
			var arr = [String]()
			for subject in selected {
				if subcategory == subject.path {
					arr.append(subject.subject)
				}
			}
			subjectDict[subcategory] = arr
		}
		return subjectDict
	}
	private func saveSubjects() {
		let group = DispatchGroup()
		var subjectsToUploadAfterTheFactUntilIFindABetterWay = [String : [String]]()
		var updateSubjectValues 	= [String : Any]()
		var updateSubcategoryValues = [String : Any]()
		
		guard let subjectDict = getSubjectDictionary() else { return }
		
		for key in subjectDict {
			let subjects = key.value.compactMap({$0}).joined(separator: "$")
			group.enter()
			self.ref.child("subject").child(CurrentUser.shared.learner.uid).child(key.key.lowercased()).observeSingleEvent(of: .value) { (snapshot) in
				if snapshot.exists(){
					self.updateSubjects(node: key.key.lowercased(), values: key.value)
					group.leave()
				} else {
					updateSubjectValues["/subject/\(CurrentUser.shared.learner.uid)/\(key.key.lowercased())"] = ["p": self.tutor.price!, "r" : 5, "sbj" : subjects, "hr" : 0, "nos" : 0]
					group.leave()
				}
			}
			group.enter()
			self.ref.child("subcategory").child(key.key.lowercased()).child(CurrentUser.shared.learner.uid).observeSingleEvent(of: .value) { (snapshot) in
				if snapshot.exists() {
					self.updateSubcategorySubjects(node: key.key.lowercased(), values: key.value)
					group.leave()
				} else {
					subjectsToUploadAfterTheFactUntilIFindABetterWay[key.key.lowercased()] = key.value
					updateSubcategoryValues["/subcategory/\(key.key.lowercased())/\(CurrentUser.shared.learner.uid)"] = ["r" : 5, "p" : self.tutor.price!, "dst" : self.tutor.distance!, "hr" : 0, "sbj" : subjects, "nos" : 0]
					group.leave()
				}
			}
		}
		group.notify(queue: .main) {
			var post = [String : Any]()
			post.merge(updateSubjectValues) { (_, last) in last }
			post.merge(updateSubcategoryValues) { (_, last) in last }
			
			self.ref.updateChildValues(post) { (error, databaseRef) in
				for key in subjectsToUploadAfterTheFactUntilIFindABetterWay {
					self.updateSubcategorySubjects(node: key.key, values: key.value)
				}
				CurrentUser.shared.tutor.subjects = self.selectedSubjects
				CurrentUser.shared.tutor.selected = self.selected
				self.displaySavedAlertController()
			}
		}
	}
	
	private func updateSubcategorySubjects(node: String, values: [String]?) {
		guard values != nil else { return }
		var post = [String : Any]()
		for value in values! {
			let formattedValue = value.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "#", with: "<").replacingOccurrences(of: ".", with: ">")
			post[formattedValue] = formattedValue
		}
		self.ref.child("subcategory").child(node).child(CurrentUser.shared.learner.uid).updateChildValues(post)
	}
	
	private func updateSubjects(node: String, values: [String]?) {
		guard values != nil else { return }
		let subjects = values!.compactMap({$0}).joined(separator: "$")
		self.ref.child("subject").child(CurrentUser.shared.learner.uid).child(node).updateChildValues(["sbj" : subjects])
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
		let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
		alertController.addAction(okButton)
		alertController.addAction(cancelButton)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	override func handleNavigation() {
		if touchStartView is TutorPreferencesNextButton {
			if selectedSubjects.count > 0 {
				deleteSubjects()
				saveSubjects()
			} else {
				AlertController.genericErrorAlertWithoutCancel(self, title: "Oops!", message: "You must have at least 1 subject.")
			}
		} else if touchStartView is NavbarButtonDone {
			tableView(shouldDisplay: false) {
				self.didSelectCategory = false
				self.contentView.searchBar.text = ""
			}
		} else if touchStartView is NavbarButtonXLight {
			if tableViewIsActive {
				tableView(shouldDisplay: false) {
					self.didSelectCategory = false
					self.contentView.searchBar.text = ""
				}
			} else {
				if CurrentUser.shared.tutor.subjects != self.selectedSubjects {
					backButtonAlert()
				} else {
					navigationController?.popViewController(animated: true)
				}
			}
		}
	}
}

extension EditTutorSubjects : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return selectedSubjects.count
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if selectedSubjects.count > 0 {
			return CGSize(width: (selectedSubjects[indexPath.row] as NSString).size(withAttributes: nil).width + 55, height: 30)
		} else {
			return CGSize(width: 60, height: 30)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pickedCollectionViewCell", for: indexPath) as! PickedSubjectsCollectionViewCell
		cell.subject.text = selectedSubjects[indexPath.item]
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

extension EditTutorSubjects : UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		if tableView.tag == 1 {
			return inlineCellIndexPath != nil ? categories.count + 1 : categories.count
		}
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView.tag != 1 {
			return shouldUpdateSearchResults ? filteredSubjects.count : allSubjects.count
		}
		return 1
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if tableView.tag == 1 {
			let tempHeight =  tableView.bounds.height / CGFloat(12)
			if inlineCellIndexPath != nil && inlineCellIndexPath!.section == indexPath.section {
				let height = tempHeight > 44 ? tempHeight : 44
				return height * 5
			}
			return 50
		} else {
			return 55
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView.tag == 1 {
			if inlineCellIndexPath != nil && inlineCellIndexPath?.section == indexPath.section {
				let cell = tableView.dequeueReusableCell(withIdentifier: "subcategoryCell", for: indexPath) as! SubjectSearchSubcategoryCell
				cell.subcategoryIcons = categories[indexPath.section - 1].subcategory.icon
				cell.dataSource = categories[indexPath.section - 1].subcategory.subcategories
				cell.selectedCategory = categories[indexPath.section - 1].subcategory.fileToRead
				cell.delegate = self
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! SubjectSearchCategoryCell
				let index = (inlineCellIndexPath != nil && indexPath.section > inlineCellIndexPath!.section) ? indexPath.section - 1 : indexPath.section
				cell.title.text = categories[index].mainPageData.displayName
				cell.backgroundColor = Colors.tutorBlue
				
				if (inlineCellIndexPath != nil && inlineCellIndexPath!.section - 1 == indexPath.section) {
					cell.dropDownArrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
				} else {
					cell.dropDownArrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / -2))
				}
				return cell
			}
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "addSubjectsCell", for: indexPath) as! AddSubjectsTableViewCell
			let subjects = shouldUpdateSearchResults ? filteredSubjects[indexPath.row] : allSubjects[indexPath.row]
			cell.subcategory.isHidden = didSelectCategory
			cell.subject.text = subjects.0
			cell.subcategory.text = subjects.1
			cell.selectedIcon.isSelected = selectedSubjects.contains(subjects.0)
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if tableView.tag != 1 && section == 0 {
			return contentView.headerView
		}
		return nil
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return tableView.tag == 1 ? 0 : 40
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if tableView.tag == 1 {
			return 3
		}
		return section != 0 ? 5 : 0
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView.tag == 1 {
			let cell = tableView.cellForRow(at: indexPath) as! SubjectSearchCategoryCell
			UIView.animate(withDuration: 0.2) {
				cell.dropDownArrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
			}
			tableView.beginUpdates()
			if inlineCellIndexPath != nil && inlineCellIndexPath!.section - 1 == indexPath.section {
				tableView.deleteSections([inlineCellIndexPath!.section], with: .fade)
				inlineCellIndexPath = nil
				UIView.animate(withDuration: 0.2) {
					cell.dropDownArrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / -2))
				}
			} else {
				if inlineCellIndexPath != nil {
					if let cell = tableView.cellForRow(at: IndexPath(row: inlineCellIndexPath!.row, section: inlineCellIndexPath!.section - 1)) as? SubjectSearchCategoryCell {
						UIView.animate(withDuration: 0.2) {
							cell.dropDownArrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / -2))
						}
					}
					tableView.deleteSections([inlineCellIndexPath!.section], with: .fade)
				}
				inlineCellIndexPath = calculateDatePickerIndexPath(indexPath)
				tableView.insertSections([inlineCellIndexPath!.section], with: .fade)
			}
			tableView.deselectRow(at: indexPath, animated: true)
			tableView.endUpdates()
			if inlineCellIndexPath != nil {
				tableView.scrollToRow(at: IndexPath(row: inlineCellIndexPath!.row, section: inlineCellIndexPath!.section - 1), at: .middle, animated: true)
			}
		} else {
			guard let cell = tableView.cellForRow(at: indexPath) as? AddSubjectsTableViewCell else { return }
			
			if selectedSubjects.count >= 20 && !cell.selectedIcon.isSelected  {
				AlertController.genericErrorAlert(self, title: "Too Many Subjects", message: "We currently only allow tutors to choose 20 subjects.")
				tableView.deselectRow(at: indexPath, animated: true)
				return
			}
			
			if selectedSubjects.contains(cell.subject.text!) {
				cell.selectedIcon.isSelected = false
				removeItem(item: selectedSubjects.index(of: cell.subject.text!)!)
				tableView.deselectRow(at: indexPath, animated: true)
				return
			}
			
			cell.selectedIcon.isSelected = true
			contentView.noSelectedItemsLabel.isHidden = true
			selectedSubjects.append(cell.subject.text!)
			selected.append(Selected(path: cell.subcategory.text!, subject: cell.subject.text!))
			
			let index = IndexPath(item: selectedSubjects.endIndex - 1, section: 0)
			contentView.pickedCollectionView.performBatchUpdates({ [weak self] () -> Void in
				self?.contentView.pickedCollectionView.insertItems(at: [index]) }, completion: nil)
			
			let endIndex = IndexPath(item: selectedSubjects.count - 1, section: 0)
			contentView.pickedCollectionView.scrollToItem(at: endIndex, at: .right, animated: true)
			contentView.pickedCollectionView.reloadData()
			
			tableView.deselectRow(at: indexPath, animated: true)
			
			contentView.nextButton.label.text = "Save (\(self.selected.count))"
		}
	}
	
	func calculateDatePickerIndexPath(_ selectedIndexPath : IndexPath) -> IndexPath {
		return (inlineCellIndexPath != nil && inlineCellIndexPath!.section < selectedIndexPath.section) ? IndexPath(row: 0, section: selectedIndexPath.section) : IndexPath(row: 0, section: selectedIndexPath.section + 1)
	}
}

extension EditTutorSubjects : DidSelectSubcategoryCell {
	func didSelectSubcategoryCell(resource: String?, subcategory: String) {
		guard let resource = resource else { return }
		if let subjects = SubjectStore.readSubcategory(resource: resource, subjectString: subcategory) {
			self.partialSubjects = subjects
			self.filteredSubjects = self.partialSubjects
			self.contentView.headerView.category.text = subcategory
		}
		tableView(shouldDisplay: true) {
			self.didSelectCategory = true
			self.contentView.tableView.reloadData()
			self.contentView.searchBar.becomeFirstResponder()
			self.scrollToTop()
		}
	}
}

extension EditTutorSubjects : UISearchBarDelegate {
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
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
		
		if searchText == ""  && !didSelectCategory {
			tableView(shouldDisplay: false) {
				self.didSelectCategory = false
				self.contentView.searchBar.text = ""
				self.automaticScroll = false
			}
		} else if searchText == ""  && didSelectCategory {
			filteredSubjects = partialSubjects
			contentView.tableView.reloadData()
			return
		} else if didSelectCategory {
			filteredSubjects = partialSubjects.filter({$0.0.localizedCaseInsensitiveContains(searchText)})
			contentView.tableView.reloadData()
		} else {
			tableView(shouldDisplay: true) {
				self.filteredSubjects = self.allSubjects.filter({$0.0.localizedCaseInsensitiveContains(searchText)})
				self.contentView.tableView.reloadData()
			}
		}
		scrollToTop()
	}
}

extension EditTutorSubjects : UIScrollViewDelegate {
	
	func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		if !automaticScroll {
			self.view.endEditing(true)
		}
	}
	private func scrollToTop() {
		if filteredSubjects.count < 1 { return }
		contentView.tableView.reloadData()
		let indexPath = IndexPath(row: 0, section: 0)
		contentView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
		automaticScroll = false
	}
}
