//
//  SearchSubjects.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class SearchSubjectsView : MainLayoutTwoButton, Keyboardable {
	
	var keyboardComponent = ViewComponent()
	var filters = NavbarButtonLines()
	var textField : UITextField!
	
	override var rightButton: NavbarButton {
		get {
			return filters
		} set {
			filters = newValue as! NavbarButtonLines
		}
	}
	
	let searchBar : UISearchBar = {
		let searchBar = UISearchBar()
		searchBar.sizeToFit()
		searchBar.searchBarStyle = .minimal
		searchBar.backgroundImage = UIImage(color: UIColor.clear)
		
		let textField = searchBar.value(forKey: "searchField") as? UITextField
		textField?.font = Fonts.createSize(18)
		textField?.textColor = .white
		textField?.adjustsFontSizeToFitWidth = true
		textField?.autocapitalizationType = .words
		textField?.attributedPlaceholder = NSAttributedString(string: "Enter Any 'Academic' Subject", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		textField?.keyboardAppearance = .dark
		
		return searchBar
	}()
	
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
		navbar.addSubview(searchBar)
		addSubview(collectionView)
		addSubview(categoryCollectionView)
		addSubview(tableView)
		addSubview(keyboardView)
		super.configureView()
		
		textField = self.searchBar.value(forKey: "searchField") as! UITextField
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		
		searchBar.snp.makeConstraints { (make) in
			make.left.equalToSuperview()
			make.right.equalTo(rightButton.snp.left)
			make.height.equalToSuperview()
			make.centerY.equalToSuperview()
		}
		collectionView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom).inset(-50)
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
			make.height.equalToSuperview()
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
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
	var initialIndex : IndexPath! = IndexPath(item: 0, section: 0)
	
	var subjects : NSArray = []
	var filteredSubjects : NSArray = []
	var shouldUpdateSearchResults = false
	
	var selectedCategory : Int = 0 {
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
		
		// Do any additional setup after loading the view.
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if !initialSetup && initialIndex != nil{
			contentView.categoryCollectionView.selectItem(at: initialIndex, animated: false, scrollPosition: .centeredHorizontally)
			contentView.textField.attributedPlaceholder = NSAttributedString(string: self.categories[self.selectedCategory].subcategory.phrase, attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
			loadListOfSubjects()
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
		
		contentView.searchBar.delegate   = self
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	private func loadListOfSubjects() {
		let pathToFile = Bundle.main.path(forResource: categories[selectedCategory].subcategory.fileToRead, ofType: "txt")
		if let path = pathToFile {
			do {
				let school = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
				subjects = school.components(separatedBy: ",") as NSArray
			} catch {
				subjects = []
				print("Try-catch error")
			}
		}
		print("1", subjects.count)
	}
	
	override func handleNavigation() {
		if touchStartView is NavbarButtonLines {
			self.dismiss(animated: true, completion: nil)
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
		if collectionView.tag == 1 && (collectionView.cellForItem(at: indexPath)?.isSelected)! {
			print("YO")
			UIView.animate(withDuration: 0.5, animations: {
				self.contentView.collectionView.alpha = 0.0
				return
			})
			selectedCategory = indexPath.item
			UIView.animate(withDuration: 0.5, animations: {
				self.contentView.collectionView.alpha = 1.0
				self.contentView.textField.attributedPlaceholder =  NSAttributedString(string: self.categories[self.selectedCategory].subcategory.phrase, attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
				return
			})
			loadListOfSubjects()
		} else {
			print("Oops")
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
		} else {
			return 0
			
		}
	}
	
	internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "subjectTableViewCell", for: indexPath) as! SubjectTableViewCell
		if shouldUpdateSearchResults {
			cell.subject.text = (filteredSubjects[indexPath.row] as! String)
		}
		return cell
	}
	
	internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
	}
}

extension SearchSubjects : UISearchBarDelegate {
	
	private func scrollToTop() {
		contentView.tableView.reloadData()
		let indexPath = IndexPath(row: 0, section: 0)
		contentView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
	}
	
	internal func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		UIView.animate(withDuration: 0.5, animations: {
			self.contentView.collectionView.alpha = 0.0
			return
		})
		UIView.animate(withDuration: 0.5, animations: {
			self.contentView.tableView.alpha = 1.0
		})
	}
	
	internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		shouldUpdateSearchResults = true
		if contentView.searchBar.text == "" {
			scrollToTop()
		}
		
		if let searchString = contentView.searchBar.text {
			let predicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchString)
			filteredSubjects = subjects.filtered(using: predicate) as NSArray
			print("3", filteredSubjects.count)
			
			if filteredSubjects.count > 0 {
				scrollToTop()
			}
		}
		contentView.tableView.reloadData()
	}
}
