//
//  SearchSubjects.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import CoreLocation

protocol UpdatedFiltersCallback {
	func filtersUpdated(filters: Filters)
}

struct Filters {
	
	let distance: Int?
	let price: Int?
	let sessionType: Bool
	let location : CLLocation?
	
	init(distance: Int?, price: Int?, inPerson: Bool, location: CLLocation?) {
		self.distance = distance
		self.price = price
		self.sessionType = inPerson
		self.location = location
	}
}

class SearchSubjectsView : MainLayoutTwoButton, Keyboardable {
	
	var keyboardComponent = ViewComponent()
	var filters = NavbarButtonFilters()
	
	var backButton = NavbarButtonXLight()
	var applyFiltersButton = NavbarButtonFilters()
	
	let headerView = SectionHeader()
	
	override var leftButton : NavbarButton {
		get {
			return backButton
		} set {
			backButton = newValue as! NavbarButtonXLight
		}
	}
	override var rightButton : NavbarButton {
		get {
			return applyFiltersButton
		}
		set {
			applyFiltersButton = newValue as! NavbarButtonFilters
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
	
	let categoryTableView : UITableView = {
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
		addSubview(categoryTableView)
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
			make.left.equalTo(backButton.snp.right).inset(15)
			make.right.equalTo(applyFiltersButton.snp.left).inset(15)
			make.height.equalTo(leftButton.snp.height)
			make.centerY.equalTo(backButton.image)
		}
		
		categoryTableView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-3)
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
	
	var filters : Filters?
	
	var searchTimer = Timer()
	var automaticScroll : Bool = false
	var shouldUpdateSearchResults = false

	var inlineCellIndexPath : IndexPath?
	
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
	
	var allSubjects = [(String, String)]()
	
	var tableViewIsActive : Bool = false {
		didSet {
			shouldUpdateSearchResults = tableViewIsActive
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		hideKeyboardWhenTappedAround()
		configureDelegates()
		contentView.searchBar.becomeFirstResponder()

		if let subjects = SubjectStore.loadTotalSubjectList() {
			self.allSubjects = subjects
			self.allSubjects.shuffle()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
//		let defaults = UserDefaults.standard
//		if defaults.bool(forKey: "showSubjectTutorial1.0") {
//			displayTutorial()
//			defaults.set(false, forKey: "showSubjectTutorial1.0")
//		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}
	
	private func configureDelegates() {
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		contentView.tableView.register(SubjectTableViewCell.self, forCellReuseIdentifier: "subjectTableViewCell")

		contentView.categoryTableView.delegate = self
		contentView.categoryTableView.dataSource = self
		contentView.categoryTableView.register(SubjectSearchCategoryCell.self, forCellReuseIdentifier: "categoryCell")
		contentView.categoryTableView.register(SubjectSearchSubcategoryCell.self, forCellReuseIdentifier: "subcategoryCell")
		
		contentView.searchBar.delegate = self
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	private func tableView(shouldDisplay bool: Bool, _ completion: @escaping () -> Void) {
		
		tableViewIsActive = bool
		UIView.animate(withDuration: 0.15, animations: {
		}) { (_) in
			UIView.animate(withDuration: 0.15, animations: {
				self.contentView.tableView.alpha = bool ? 1.0 : 0.0
				return completion()
			})
		}
	}
    
//    func displayTutorial() {
//
//        let tutorial = TutorCardTutorial()
//        tutorial.label.text = "Swipe left and right for more subjects!"
//        contentView.addSubview(tutorial)
//
//        tutorial.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
//
//        UIView.animate(withDuration: 1, animations: {
//            tutorial.alpha = 1
//        }, completion: { (true) in
//            UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse], animations: {
//                tutorial.imageView.center.x -= 20
//                tutorial.imageView.center.x += 20
//            })
//        })
//    }

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
		} else if touchStartView is NavbarButtonFilters {
			let next = LearnerFilters()
			next.filters = filters
			next.delegate = self
			self.present(next, animated: true, completion: nil)
		}
	}
}

extension SearchSubjects : UpdatedFiltersCallback {
	func filtersUpdated(filters: Filters) {
		self.filters = filters
		print(filters.distance)
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
				cell.delegate = self
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! SubjectSearchCategoryCell
				let index = (inlineCellIndexPath != nil && indexPath.section > inlineCellIndexPath!.section) ? indexPath.section - 1 : indexPath.section
				cell.title.text = categories[index].mainPageData.displayName
				if (inlineCellIndexPath != nil && inlineCellIndexPath!.section - 1 == indexPath.section) {
					cell.dropDownArrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
				} else {
					cell.dropDownArrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / -2))
				}
				
				return cell
			}
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "subjectTableViewCell", for: indexPath) as! SubjectTableViewCell
			let subjects = shouldUpdateSearchResults ? filteredSubjects : allSubjects
			cell.subject.text = subjects[indexPath.section].0
			cell.subcategory.text = subjects[indexPath.section].1
			return cell
		}
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
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
			tableView.endUpdates()
			if inlineCellIndexPath != nil {
				tableView.scrollToRow(at: IndexPath(row: inlineCellIndexPath!.row, section: inlineCellIndexPath!.section - 1), at: .middle, animated: true)
			}
		} else {
			guard let cell = tableView.cellForRow(at: indexPath) as? SubjectTableViewCell else { return }
			
			let next = TutorConnect()
			next.subject = (cell.subcategory.text!,cell.subject.text!)
			next.contentView.searchBar.text = "\(cell.subcategory.text!) • \(cell.subject.text!)"
			next.filters = self.filters
			next.delegate = self
			self.navigationController?.pushViewController(next, animated: true)
		}
	}
	func calculateDatePickerIndexPath(_ selectedIndexPath : IndexPath) -> IndexPath {
		return (inlineCellIndexPath != nil && inlineCellIndexPath!.section < selectedIndexPath.section) ? IndexPath(row: 0, section: selectedIndexPath.section) : IndexPath(row: 0, section: selectedIndexPath.section + 1)
	}
}

extension SearchSubjects : DidSelectSubcategoryCell {
	func didSelectSubcategoryCell(resource: String?, subcategory: String) {
		let next = TutorConnect()
		next.subcategory = subcategory.lowercased()
		next.contentView.searchBar.text = subcategory
		next.filters = self.filters
		next.delegate = self
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
			self.filteredSubjects = self.allSubjects.filter({$0.0.localizedCaseInsensitiveContains(searchText)})
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
		guard filteredSubjects.count > 0 else { return }
		contentView.tableView.reloadData()
		contentView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
		automaticScroll = false
	}
}
