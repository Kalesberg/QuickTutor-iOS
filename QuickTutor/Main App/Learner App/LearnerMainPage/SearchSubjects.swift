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
	
	var backButton = NavbarButtonX()
	
	let headerView = SectionHeader()
	
	override var leftButton : NavbarButton {
		get {
			return backButton
		} set {
			backButton = newValue as! NavbarButtonX
		}
	}
	
	var searchTextField : UITextField!
	
	let searchBar : UISearchBar = {
		let searchBar = UISearchBar()
		
		searchBar.sizeToFit()
		searchBar.searchBarStyle = .minimal
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
	
	let tableView : UITableView = {
		let tblView = UITableView()
		
		tblView.rowHeight = UITableViewAutomaticDimension
		tblView.estimatedRowHeight = 55
		tblView.separatorInset.left = 0
		tblView.separatorStyle = .none
		tblView.showsVerticalScrollIndicator = false
		tblView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		
		tblView.alpha = 0.0
		
		return tblView
	}()
	
	override func configureView() {
		navbar.addSubview(searchBar)
		
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
		
		
		headerView.backgroundColor = Colors.backgroundDark
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		searchBar.snp.makeConstraints { (make) in
			make.left.equalTo(backButton.snp.right)
			make.right.equalToSuperview()
			make.height.equalToSuperview()
			make.centerY.equalTo(backButton.image)
		}
		
		categoryCollectionView.snp.makeConstraints { (make) in
			make.top.equalTo(searchBar.snp.bottom).inset(-20)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
            if UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480 {
                make.height.equalTo(235)
            } else {
                make.height.equalTo(295)
            }
		}
		
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom)
			make.bottom.equalTo(safeAreaLayoutGuide)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
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
	
	var categories : [Category] = [.academics, .arts, .auto, .business, .experiences, .health, .language, .outdoors, .remedial, .sports, .tech, .trades]
	
	var shouldUpdateSearchResults = false
	
	var initialSetup : Bool = false
	
	var automaticScroll : Bool = false
	
	var filteredSubjects : [(String, String)] = []
	var allSubjects : [(String, String)] = []
	
	var tableViewIsActive : Bool = false {
		didSet {
			contentView.backButton.isHidden = tableViewIsActive
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
			print(allSubjects.count)
		}
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let initialIndex : IndexPath! = IndexPath(item: categories.count / 2, section: 0)
		
		if !initialSetup && initialIndex != nil{
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
		
		contentView.searchBar.delegate = self
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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

	override func handleNavigation() {
		if touchStartView is NavbarButtonX {
			if tableViewIsActive {
				tableView(shouldDisplay: false) {
					self.contentView.searchBar.text = ""
				}
			} else {
				let nav = self.navigationController
				let transition = CATransition()
				
				DispatchQueue.main.async {
					nav?.view.layer.add(transition.popFromTop(), forKey: nil)
					nav?.popViewController(animated: false)
				}
			}
		}
	}
}

extension SearchSubjects : SelectedSubcategory {
	
	func didSelectSubcategory(resource: String, subject: String, index: Int) {
		
		let next = TutorConnect()
		let transition = CATransition()
		let nav = self.navigationController
		
		next.subcategory = subject.lowercased()
		next.contentView.searchBar.placeholder = subject
		
		DispatchQueue.main.async {
			nav?.view.layer.add(transition.segueFromBottom(), forKey: nil)
			nav?.pushViewController(next, animated: false)
		}
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
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		guard let cell = collectionView.cellForItem(at: indexPath) as? CategorySelectionCollectionViewCell else { return }
		
		let next = TutorConnect()
		next.subcategory = cell.category.subcategory.subcategories[indexPath.item]
		
	}
	
	internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize(width: UIScreen.main.bounds.width - 20, height: collectionView.frame.height)
	}
	
	internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		
		return 20
	}
}

extension SearchSubjects : UITableViewDelegate, UITableViewDataSource {
	
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
	
	internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		guard let cell = tableView.cellForRow(at: indexPath) as? SubjectTableViewCell else { return }
		
		let next = TutorConnect()
		let nav = self.navigationController
		let transition = CATransition()
		
		next.subject = (cell.subcategory.text!,cell.subject.text!)
		next.contentView.searchBar.placeholder = cell.subject.text!
		
		DispatchQueue.main.async {
			nav?.view.layer.add(transition.segueFromBottom(), forKey: nil)
			nav?.pushViewController(next, animated: false)
		}
	}
	
	internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 0 {
			contentView.headerView.category.text = ""
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
	
	internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 55
	}
	
	internal func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if section != 0{
			return 5
		}
		return 0
	}
}

extension SearchSubjects : UISearchBarDelegate {
	
	internal func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		if searchBar.text!.count > 1 {
			tableView(shouldDisplay: true) {}
		}
	}
	
	internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		automaticScroll = true
		
		if searchText == ""  {
			
			tableView(shouldDisplay: false) {
				self.contentView.searchBar.text = ""
				self.automaticScroll = false
			}
			return
		}
		tableView(shouldDisplay: true) {
			self.filteredSubjects = self.allSubjects.filter({$0.0.contains(searchText)})
			self.contentView.tableView.reloadData()
		}
		
		if filteredSubjects.count > 0 {
			scrollToTop()
		}
	}
}
extension SearchSubjects : UIScrollViewDelegate {
	
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
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//		let x = scrollView.contentOffset.x
//		let w = scrollView.bounds.size.width
//		let currentPage = Int(ceil(x / w))
//
//		if currentPage < 12 {
//			contentView.searchBar.placeholder = categories[currentPage].subcategory.phrase
//		}
	}
}
