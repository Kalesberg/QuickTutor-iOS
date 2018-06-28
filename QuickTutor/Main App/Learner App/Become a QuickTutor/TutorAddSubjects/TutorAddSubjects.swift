//
//  TutorAddSubjects.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/14/18.
//  Copyright © 2018 QuickTutor. All rights reserved.


import Foundation
import UIKit

struct Selected {
	let path : String
	let subject : String
}

protocol SelectedSubcategory {
	func didSelectSubcategory(resource: String, subject: String, index: Int)
}

class TutorAddSubjectsView : MainLayoutTwoButton, Keyboardable {
	
	var keyboardComponent = ViewComponent()
	let headerView = SectionHeader()
	let nextButton = TutorPreferencesNextButton()
	
	let errorLabel : UILabel = {
		let label = UILabel()
		
		label.font = Fonts.createItalicSize(17)
		label.textColor = .red
		label.isHidden = true
		label.textAlignment = .center
		
		return label
	}()
	
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
	
	let pickedCollectionView : UICollectionView = {
		let collectionView : UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		let layout = UICollectionViewFlowLayout()
		
		layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
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
	
	let tableView : UITableView = {
		let tblView = UITableView.init(frame: .zero, style: .grouped)
		
		tblView.rowHeight = 55
		tblView.separatorInset.left = 0
		tblView.separatorStyle = .none
		tblView.showsVerticalScrollIndicator = false
		tblView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		tblView.allowsMultipleSelection = true
		tblView.alpha = 0.0
		
		return tblView
	}()
	
	var backButton = NavbarButtonXLight()
	var cancelButton = NavbarButtonDone()
	
	override var leftButton : NavbarButton {
		get {
			return backButton
		} set {
			backButton = newValue as! NavbarButtonXLight
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
		navbar.addSubview(searchBar)
		addSubview(noSelectedItemsLabel)
		addSubview(categoryCollectionView)
		addSubview(pickedCollectionView)
		addSubview(tableView)
		addSubview(nextButton)
		addSubview(keyboardView)
		addSubview(errorLabel)
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
		headerView.backgroundColor = Colors.backgroundDark
		cancelButton.label.label.text = "Add"
		cancelButton.isHidden = true
		
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
			make.top.equalTo(navbar.snp.bottom).inset(-4)
			make.height.equalTo(45)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
		}
		
		pickedCollectionView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-5)
			make.height.equalTo(45)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
		}
		
		categoryCollectionView.snp.makeConstraints { (make) in
			make.top.equalTo(pickedCollectionView.snp.bottom)
			make.width.equalToSuperview()
			if UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480 {
				make.height.equalTo(235)
			} else {
				make.height.equalTo(295)
			}
			
			make.centerX.equalToSuperview()
			
		}
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(pickedCollectionView.snp.bottom)
			make.bottom.equalTo(nextButton.snp.top)
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
		errorLabel.snp.makeConstraints { (make) in
			make.bottom.equalTo(nextButton.snp.top)
			make.height.equalTo(45)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
	}
	
	override func layoutSubviews() {
		layoutIfNeeded()
		navbar.backgroundColor = Colors.tutorBlue
		statusbarView.backgroundColor = Colors.tutorBlue
	}
}


class TutorAddSubjects : BaseViewController {
	override var contentView: TutorAddSubjectsView {
		return view as! TutorAddSubjectsView
	}
	override func loadView() {
		view = TutorAddSubjectsView()
	}
	
	var categories : [Category] = [.academics, .arts, .auto, .business, .lifestyle, .health, .language, .outdoors, .remedial, .sports, .tech, .trades]
	
	var shouldUpdateSearchResults = false
	
	var didSelectCategory = false {
		didSet {
			if didSelectCategory == false {
				contentView.headerView.category.text = ""
			}
		}
	}
	
	var selectedSubjects : [String] = [] {
		didSet {
			contentView.errorLabel.isHidden = !(selectedSubjects.count == 0)
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
			contentView.backButton.image.image = tableViewIsActive ? #imageLiteral(resourceName: "xbuttonlight") : #imageLiteral(resourceName: "backButton")
			contentView.nextButton.isHidden = tableViewIsActive
			contentView.cancelButton.isHidden = !tableViewIsActive
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
		if UserDefaults.standard.bool(forKey: "showBecomeTutorTutorial1.0") {
			displayTutorial()
			UserDefaults.standard.set(false, forKey: "showBecomeTutorTutorial1.0")
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let initialIndex = IndexPath(item: categories.count / 2, section: 0)
		contentView.categoryCollectionView.reloadData()
		
		if !initialSetup {
			contentView.categoryCollectionView.selectItem(at: initialIndex, animated: false, scrollPosition: .centeredHorizontally)
			initialSetup = true
		}
		contentView.categoryCollectionView.reloadData()
	}
	
	func displayTutorial() {
		
		let tutorial = TutorCardTutorial()
		tutorial.label.text = "Swipe left and right for more subjects!"
		contentView.addSubview(tutorial)
		
		tutorial.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		contentView.leftButton.isUserInteractionEnabled = false
		contentView.rightButton.isUserInteractionEnabled = false
		contentView.searchBar.isUserInteractionEnabled = false
		
		UIView.animate(withDuration: 1, animations: {
			tutorial.alpha = 1
		}, completion: { (true) in
			UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse], animations: {
				tutorial.imageView.center.x -= 20
				tutorial.imageView.center.x += 20
			}, completion: { (true) in
				
				self.contentView.leftButton.isUserInteractionEnabled = true
				self.contentView.rightButton.isUserInteractionEnabled = true
				self.contentView.searchBar.isUserInteractionEnabled = true
			})
		})
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
	
	private func tableView(shouldDisplay bool: Bool,_ completion: @escaping () -> Void) {
		tableViewIsActive = bool
		UIView.animate(withDuration: 0.2, animations: {
			self.contentView.categoryCollectionView.alpha = bool ? 0.0 : 1.0
		}) { (_) in
			UIView.animate(withDuration: 0.2, animations: {
				self.contentView.tableView.alpha = bool ? 1.0 : 0.0
				return completion()
			})
		}
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
			self.contentView.nextButton.label.text = "Next (\(self.selected.count))"
			self.contentView.noSelectedItemsLabel.isHidden = (self.selectedSubjects.count == 0) ? false : true
			self.contentView.tableView.reloadData()
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	private func backButtonAlert() {
		let alertController = UIAlertController(title: "Are You Sure?", message: "All of your progress will be deleted.", preferredStyle: .alert)
		let okButton = UIAlertAction(title: "Ok", style: .destructive) { (_) in
			self.navigationController?.popViewController(animated: true)
		}
		
		let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
		alertController.addAction(okButton)
		alertController.addAction(cancelButton)
		self.present(alertController, animated: true, completion: nil)
	}
	
	private func scrollToTop() {
		contentView.tableView.reloadData()
		let indexPath = IndexPath(row: 0, section: 0)
		contentView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
		automaticScroll = false
	}
	
	override func handleNavigation() {
		if touchStartView is NavbarButtonXLight {
			tableViewIsActive ? tableView(shouldDisplay: false) {
				self.didSelectCategory = false
				self.contentView.searchBar.text = ""
				} : backButtonAlert()
			
		} else if touchStartView is NavbarButtonDone {
			tableView(shouldDisplay: false) {
				self.didSelectCategory = false
				self.contentView.searchBar.text = ""
			}
		} else if touchStartView is TutorPreferencesNextButton {
			if selectedSubjects.count > 0 {
				TutorRegistration.subjects = selected
				navigationController?.pushViewController(TutorPreferences(), animated: true)
			} else {
				contentView.errorLabel.text = "Must choose atleast 1 subject."
				contentView.errorLabel.isHidden = false
			}
		}
	}
}
extension TutorAddSubjects : SelectedSubcategory {
	
	func didSelectSubcategory(resource: String, subject: String, index: Int) {
		if let subjects = SubjectStore.readSubcategory(resource: resource, subjectString: subject) {
			self.partialSubjects = subjects
			self.filteredSubjects = self.partialSubjects
			self.contentView.headerView.category.text = subject
		}
		tableView(shouldDisplay: true) {
			self.didSelectCategory = true
			self.contentView.tableView.reloadData()
			self.contentView.searchBar.becomeFirstResponder()
			self.scrollToTop()
		}
	}
}

extension TutorAddSubjects : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionView.tag == 0 ? categories.count : selectedSubjects.count
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
		return collectionView.tag == 0 ? 20 : 0
	}
}

extension TutorAddSubjects : UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return shouldUpdateSearchResults ? filteredSubjects.count : allSubjects.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return section == 0 ? 30 : 0
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return section != 0 ? 5 : 0
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? AddSubjectsTableViewCell else { return }
		
		if selectedSubjects.count >= 20 && !cell.selectedIcon.isSelected  {
			AlertController.genericErrorAlert(self, title: "Too Many Subjects", message: "We currently only allow tutors to choose 20 subjects. These can be changed later on.")
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
		self.contentView.noSelectedItemsLabel.isHidden = true
		selectedSubjects.append(cell.subject.text!)
		self.selected.append(Selected(path: cell.subcategory.text!, subject: cell.subject.text!))
		let index = IndexPath(item: selectedSubjects.endIndex - 1, section: 0)
		contentView.pickedCollectionView.performBatchUpdates({ [weak self] () -> Void in
			self?.contentView.pickedCollectionView.insertItems(at: [index])
			}, completion: nil)
		let endIndex = IndexPath(item: selectedSubjects.count - 1, section: 0)
		contentView.pickedCollectionView.scrollToItem(at: endIndex, at: .right, animated: true)
		contentView.pickedCollectionView.reloadData()
		tableView.deselectRow(at: indexPath, animated: true)
		self.contentView.nextButton.label.text = "Next (\(self.selected.count))"
	}
}

extension TutorAddSubjects : UISearchBarDelegate {
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		if searchBar.text!.count > 0 {
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
			filteredSubjects = partialSubjects.filter({$0.0.localizedCaseInsensitiveContains(searchText)})
			contentView.tableView.reloadData()
			return
			
		} else {
			tableView(shouldDisplay: true) {
				self.filteredSubjects = self.allSubjects.filter({$0.0.localizedCaseInsensitiveContains(searchText)})
				self.contentView.tableView.reloadData()
			}
		}
		if filteredSubjects.count > 0 {
			scrollToTop()
		}
	}
}

//smooth search/scrolling
extension TutorAddSubjects : UIScrollViewDelegate {
	func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		if !automaticScroll {
			self.view.endEditing(true)
		}
	}
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		if !automaticScroll {
			self.view.endEditing(true)
		}
	}
}
