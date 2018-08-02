//
//  SearchSubjects.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class SearchSubjectsView : MainLayoutOneButton, Keyboardable {
	
	var keyboardComponent = ViewComponent()
	var filters = NavbarButtonFilters()
	
	var backButton = NavbarButtonXLight()
	
	let headerView = SectionHeader()
	
	override var leftButton : NavbarButton {
		get {
			return backButton
		} set {
			backButton = newValue as! NavbarButtonXLight
		}
	}
	
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
	
	let newTableView : UITableView = {
		let tableView = UITableView(frame: .zero, style: .grouped)
		let header = SubjectSearchTableViewHeader()
		header.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 75)
		
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
		
		tableView.estimatedRowHeight = 55
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = Colors.backgroundDark
		tableView.alpha = 0.0
		
		return tableView
	}()
	
	override func configureView() {
		navbar.addSubview(searchBar)
		addSubview(newTableView)
		addSubview(categoryCollectionView)
		addSubview(tableView)
		addSubview(keyboardView)
		super.configureView()
		
		searchTextField = searchBar.value(forKey: "searchField") as? UITextField
		
		searchTextField?.font = Fonts.createSize(16)
		searchTextField?.textColor = .white
		searchTextField?.adjustsFontSizeToFitWidth = true
		searchTextField?.autocapitalizationType = .words
		searchTextField?.attributedPlaceholder = NSAttributedString(string: "search anything", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		searchTextField?.keyboardAppearance = .dark
		searchTextField.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		
		backButton.image.image = #imageLiteral(resourceName: "back-button")
		headerView.backgroundColor = Colors.backgroundDark
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		searchBar.snp.makeConstraints { (make) in
			make.left.equalTo(backButton.snp.right)
			make.right.height.equalToSuperview()
			make.centerY.equalTo(backButton.image)
		}
		
	//		categoryCollectionView.snp.makeConstraints { (make) in
//			make.top.equalTo(searchBar.snp.bottom).inset(-20)
//			make.width.centerX.equalToSuperview()
//            if UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480 {
//                make.height.equalTo(235)
//            } else {
//                make.height.equalTo(295)
//            }
//		}
		
		newTableView.snp.makeConstraints { (make) in
			make.top.equalTo(searchBar.snp.bottom).inset(-3)
			make.width.equalToSuperview().multipliedBy(0.95)
			make.centerX.equalToSuperview()
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaLayoutGuide)
			} else {
				make.bottom.equalTo(layoutMargins.bottom)
			}
		}
		
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
			make.width.centerX.equalToSuperview()
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		layoutIfNeeded()
	}
}

class SearchSubjects: BaseViewController {
	
	var connectedTutor: AWTutor!
	
	override var contentView: SearchSubjectsView {
		return view as! SearchSubjectsView
	}
	
	override func loadView() {
		view = SearchSubjectsView()
	}
	
	var categories : [Category] = [.academics, .arts, .auto, .business, .lifestyle, .health, .language, .outdoors, .remedial, .sports, .tech, .trades]
	
	var searchTimer = Timer()
	var initialSetup : Bool = false
	var automaticScroll : Bool = false
	var shouldUpdateSearchResults = false

	var inlineCellIndexPath : IndexPath?
	var selectedCategory : Category?
	
	var filteredSubjects : [(String, String)] = []
	var allSubjects : [(String, String)] = []
	
	var tableViewIsActive : Bool = false {
		didSet {
			contentView.backButton.image.image = tableViewIsActive ? #imageLiteral(resourceName: "xbuttonlight") : #imageLiteral(resourceName: "back-button")
			shouldUpdateSearchResults = tableViewIsActive
		}
	}
	
	var initialIndex : IndexPath? = IndexPath(item: 6, section: 0)

	override func viewDidLoad() {
		super.viewDidLoad()
		if let subjects = SubjectStore.loadTotalSubjectList() {
			self.allSubjects = subjects
			self.allSubjects.shuffle()
		}
		hideKeyboardWhenTappedAround()
		configureDelegates()
	
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let defaults = UserDefaults.standard
		if defaults.bool(forKey: "showSubjectTutorial1.0") {
			displayTutorial()
			defaults.set(false, forKey: "showSubjectTutorial1.0")
		}
		contentView.searchBar.becomeFirstResponder()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if !initialSetup && initialIndex != nil {
			contentView.categoryCollectionView.selectItem(at: initialIndex, animated: false, scrollPosition: .centeredHorizontally)
			initialSetup = true
		}
		contentView.categoryCollectionView.reloadData()
	}
	
	private func configureDelegates() {
		
		contentView.categoryCollectionView.delegate = self
		contentView.categoryCollectionView.dataSource = self
		contentView.categoryCollectionView.register(CategorySelectionCollectionViewCell.self, forCellWithReuseIdentifier: "categoryCollectionViewCell")
		
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		contentView.tableView.register(SubjectTableViewCell.self, forCellReuseIdentifier: "subjectTableViewCell")

		contentView.newTableView.delegate = self
		contentView.newTableView.dataSource = self
		contentView.newTableView.register(SubjectSearchCategoryCell.self, forCellReuseIdentifier: "categoryCell")
		contentView.newTableView.register(SubjectSearchSubcategoryCell.self, forCellReuseIdentifier: "subcategoryCell")
		
		contentView.searchBar.delegate = self
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	private func tableView(shouldDisplay bool: Bool, _ completion: @escaping () -> Void) {
		tableViewIsActive = bool
		UIView.animate(withDuration: 0.15, animations: {
			self.contentView.categoryCollectionView.alpha = bool ? 0.0 : 1.0
		}) { (_) in
			UIView.animate(withDuration: 0.15, animations: {
				self.contentView.tableView.alpha = bool ? 1.0 : 0.0
				return completion()
			})
		}
	}
    
    func displayTutorial() {
        
        let tutorial = TutorCardTutorial()
        tutorial.label.text = "Swipe left and right for more subjects!"
        contentView.addSubview(tutorial)
        
        tutorial.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        UIView.animate(withDuration: 1, animations: {
            tutorial.alpha = 1
        }, completion: { (true) in
            UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse], animations: {
                tutorial.imageView.center.x -= 20
                tutorial.imageView.center.x += 20
            })
        })
    }

	override func handleNavigation() {
		if touchStartView is NavbarButtonXLight {
			if tableViewIsActive {
				tableView(shouldDisplay: false) {
					self.contentView.searchBar.text = ""
				}
			} else {
				let nav = self.navigationController				
				DispatchQueue.main.async {
					nav?.view.layer.add(CATransition().popFromTop(), forKey: nil)
					nav?.popViewController(animated: false)
				}
			}
		}
	}
}

extension SearchSubjects : SelectedSubcategory {
	
	func didSelectSubcategory(resource: String, subject: String, index: Int) {
		let next = TutorConnect()
		next.subcategory = subject.lowercased()
		next.contentView.searchBar.text = subject
		self.navigationController?.pushViewController(next, animated: true)
	}
}

extension SearchSubjects : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return categories.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCollectionViewCell", for: indexPath) as! CategorySelectionCollectionViewCell
		cell.category = categories[indexPath.item]
		cell.delegate = self
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: UIScreen.main.bounds.width - 20, height: collectionView.frame.height)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 20
	}
}

extension SearchSubjects : UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		if tableView.tag == 1 {
			return inlineCellIndexPath != nil ? categories.count + 1 : categories.count
		}
		return shouldUpdateSearchResults ? filteredSubjects.count : allSubjects.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if tableView.tag == 1 {
			let tableViewHeight = tableView.bounds.height
			let tempHeight = tableViewHeight / CGFloat(12)
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
				cell.delegate = self
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! SubjectSearchCategoryCell
				let index = (inlineCellIndexPath != nil && indexPath.section > inlineCellIndexPath!.section) ? indexPath.section - 1 : indexPath.section
				cell.title.text = categories[index].mainPageData.displayName

				if inlineCellIndexPath != nil && inlineCellIndexPath!.section - 1 == indexPath.section {
					cell.dropDownArrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
				} else {
					cell.dropDownArrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / -2))
				}
				return cell
			}
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "subjectTableViewCell", for: indexPath) as! SubjectTableViewCell
			
			if shouldUpdateSearchResults {
				cell.subject.text = filteredSubjects[indexPath.section].0
				cell.subcategory.text = filteredSubjects[indexPath.section].1
			} else {
				cell.subject.text = allSubjects[indexPath.section].0
				cell.subcategory.text = allSubjects[indexPath.section].1
			}
			return cell
		}
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
			guard let cell = tableView.cellForRow(at: indexPath) as? SubjectTableViewCell else { return }
			
			let next = TutorConnect()
			next.subject = (cell.subcategory.text!,cell.subject.text!)
			next.contentView.searchBar.text = "\(cell.subcategory.text!) • \(cell.subject.text!)"
			self.navigationController?.pushViewController(next, animated: true)
			tableView.deselectRow(at: indexPath, animated: true)
		}
	}
	func calculateDatePickerIndexPath(_ selectedIndexPath : IndexPath) -> IndexPath {
		return (inlineCellIndexPath != nil && inlineCellIndexPath!.section < selectedIndexPath.section) ? IndexPath(row: 0, section: selectedIndexPath.section) : IndexPath(row: 0, section: selectedIndexPath.section + 1)
	}
}

extension SearchSubjects : DidSelectSubcategoryCell {
	func didSelectSubcategoryCell(subcategory: String) {
		let next = TutorConnect()
		next.subcategory = subcategory.lowercased()
		next.contentView.searchBar.text = subcategory
		self.navigationController?.pushViewController(next, animated: true)
	}
}

extension SearchSubjects : UISearchBarDelegate {
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		if searchBar.text!.count > 0 {
			tableView(shouldDisplay: true) {/* 🤭 */}
		}
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		automaticScroll = true
		searchTimer.invalidate()
		guard searchText != "", searchText.count > 0 else {
			return tableView(shouldDisplay: false) {
				self.contentView.searchBar.text = ""
				self.automaticScroll = false
			}
		}
		func startTimer(){
			searchTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(searchSubjects(_:)), userInfo: searchText, repeats: true)
		}
		startTimer()
	}
	
	@objc private func searchSubjects(_ sender: Timer) {
		guard let searchText = sender.userInfo as? String else { return }
		searchTimer.invalidate()
		tableView(shouldDisplay: true) {
			self.filteredSubjects = self.allSubjects.filter({$0.0.localizedCaseInsensitiveContains(searchText)}).sorted(by: <)
			self.contentView.tableView.reloadData()
		}
	}
}
extension SearchSubjects : UIScrollViewDelegate {
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
		guard filteredSubjects.count < 1 else { return }
		contentView.tableView.reloadData()
		contentView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
		automaticScroll = false
	}
}
