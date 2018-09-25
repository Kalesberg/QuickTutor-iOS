//
//  TutorAddSubjects.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/14/18.
//  Copyright © 2018 QuickTutor. All rights reserved.


import Foundation
import UIKit

class TutorAddSubjectsView : MainLayoutTwoButton, Keyboardable {
	
	var keyboardComponent = ViewComponent()
    let headerView : UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(20)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
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
	
	let categoryTableView : UITableView = {
		let tableView = UITableView(frame: .zero, style: .grouped)
		
		let header = SubjectSearchTableViewHeader()
		header.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 75)
		header.subtitle.text = "Search a subject within any subcategory"
		
		tableView.showsVerticalScrollIndicator = false
		tableView.separatorStyle = .none
		tableView.backgroundColor = Colors.backgroundDark
		tableView.sectionFooterHeight = 3
		tableView.sectionHeaderHeight = 0
		tableView.tableHeaderView = header
		
		tableView.tag = 1
		
		return tableView
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
		let tableView = UITableView.init(frame: .zero, style: .grouped)
		
		tableView.rowHeight = 40
		tableView.separatorStyle = .singleLine
		tableView.separatorColor = .black
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = Colors.backgroundDark
		tableView.allowsMultipleSelection = true
		tableView.alpha = 0.0
		tableView.tableFooterView = UIView()
		
		return tableView
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
		addSubview(categoryTableView)
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
		searchTextField?.attributedPlaceholder = NSAttributedString(string: "Search for anything", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
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
		categoryTableView.snp.makeConstraints { (make) in
			make.top.equalTo(pickedCollectionView.snp.bottom)
			make.width.equalToSuperview().multipliedBy(0.95)
			make.centerX.equalToSuperview()
			make.bottom.equalTo(nextButton.snp.top)
		}

		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(pickedCollectionView.snp.bottom)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
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
				contentView.headerView.text = ""
			}
		}
	}
	
	var selectedSubjects : [String] = [] {
		didSet {
			contentView.errorLabel.isHidden = !(selectedSubjects.count == 0)
			contentView.noSelectedItemsLabel.isHidden = !selectedSubjects.isEmpty
		}
	}
	
	var selected : [Selected] = []
	var automaticScroll : Bool = false

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
	
	var tableViewIsActive : Bool = false {
		didSet {
			contentView.backButton.image.image = tableViewIsActive ? #imageLiteral(resourceName: "navbar-x") : #imageLiteral(resourceName: "backButton")
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
//		if UserDefaults.standard.bool(forKey: "showBecomeTutorTutorial1.0") {
//			displayTutorial()
//			UserDefaults.standard.set(false, forKey: "showBecomeTutorTutorial1.0")
//		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
	}
	
//	func displayTutorial() {
//
//		let tutorial = TutorCardTutorial()
//		tutorial.label.text = "Swipe left and right for more subjects!"
//		contentView.addSubview(tutorial)
//
//		tutorial.snp.makeConstraints { (make) in
//			make.edges.equalToSuperview()
//		}
//
//		contentView.leftButton.isUserInteractionEnabled = false
//		contentView.rightButton.isUserInteractionEnabled = false
//		contentView.searchBar.isUserInteractionEnabled = false
//
//		UIView.animate(withDuration: 1, animations: {
//			tutorial.alpha = 1
//		}, completion: { (true) in
//			UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse], animations: {
//				tutorial.imageView.center.x -= 20
//				tutorial.imageView.center.x += 20
//			}, completion: { (true) in
//
//				self.contentView.leftButton.isUserInteractionEnabled = true
//				self.contentView.rightButton.isUserInteractionEnabled = true
//				self.contentView.searchBar.isUserInteractionEnabled = true
//			})
//		})
//	}
	
	private func configureDelegates() {
		
		contentView.pickedCollectionView.delegate = self
		contentView.pickedCollectionView.dataSource = self
		contentView.pickedCollectionView.register(PickedSubjectsCollectionViewCell.self, forCellWithReuseIdentifier: "pickedCollectionViewCell")

		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		contentView.tableView.register(AddSubjectsTableViewCell.self, forCellReuseIdentifier: "addSubjectsCell")
		
		contentView.categoryTableView.delegate = self
		contentView.categoryTableView.dataSource = self
		contentView.categoryTableView.register(SubjectSearchCategoryCell.self, forCellReuseIdentifier: "categoryCell")
		contentView.categoryTableView.register(SubjectSearchSubcategoryCell.self, forCellReuseIdentifier: "subcategoryCell")
		
		contentView.searchBar.delegate = self
	}
	
	private func tableView(shouldDisplay bool: Bool,_ completion: @escaping () -> Void) {
		tableViewIsActive = bool
		UIView.animate(withDuration: 0.2, animations: {
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
				contentView.errorLabel.text = "Must choose at least 1 subject."
				contentView.errorLabel.isHidden = false
			}
		}
	}
}

extension TutorAddSubjects : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

extension TutorAddSubjects : UITableViewDelegate, UITableViewDataSource {
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
		return tableView.tag == 1 ? 0 : 25
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
	
	func calculateDatePickerIndexPath(_ selectedIndexPath : IndexPath) -> IndexPath {
		return (inlineCellIndexPath != nil && inlineCellIndexPath!.section < selectedIndexPath.section) ? IndexPath(row: 0, section: selectedIndexPath.section) : IndexPath(row: 0, section: selectedIndexPath.section + 1)
	}
}

extension TutorAddSubjects : DidSelectSubcategoryCell {
	func didSelectSubcategoryCell(resource: String?, subcategory: String) {
		guard let resource = resource else { return }
		if let subjects = SubjectStore.readSubcategory(resource: resource, subjectString: subcategory) {
			print("Partial Subjects: ", partialSubjects)
			self.partialSubjects = subjects
			self.filteredSubjects = self.partialSubjects
			self.contentView.headerView.text = "   " + subcategory
		}
		tableView(shouldDisplay: true) {
			self.didSelectCategory = true
			self.contentView.tableView.reloadData()
			self.contentView.searchBar.becomeFirstResponder()
			self.scrollToTop()
		}
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
		if searchText == ""  && !didSelectCategory { //handle case when there is no searchText.
			tableView(shouldDisplay: false) {
				self.didSelectCategory = false
				self.contentView.searchBar.text = ""
				self.automaticScroll = false
			}
		} else if searchText == ""  && didSelectCategory { //handle case when there is no searchText but a subcategory was chosen.
			filteredSubjects = partialSubjects
			contentView.tableView.reloadData()
		} else if didSelectCategory { //handle case when there is search text and subcategory is chosen.
			filteredSubjects = partialSubjects.filter({ return $0.0.range(of: searchText, options: .caseInsensitive) != nil }).sorted(by: { $0.0.count < $1.0.count })
			contentView.tableView.reloadData()
		} else { //handle case when thre is search text and no subcategory is chosen.
			tableView(shouldDisplay: true) {
				self.filteredSubjects = self.allSubjects.filter({ return $0.0.range(of: searchText, options: .caseInsensitive) != nil }).sorted(by: { $0.0.count < $1.0.count })
				self.contentView.tableView.reloadData()
			}
		}
		scrollToTop()
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
	private func scrollToTop() {
		if filteredSubjects.count < 1 { return }
		contentView.tableView.reloadData()
		contentView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
		automaticScroll = false
	}
}
