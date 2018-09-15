//
//  CategorySearch.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class CategorySearchView : MainLayoutTwoButton {
	
	var back =  NavbarButtonBack()
	var filters = NavbarButtonLines()
	
	let subtitle = SectionHeader()
	
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
		textField?.attributedPlaceholder = NSAttributedString(string: CategorySelected.title, attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		textField?.keyboardAppearance = .dark
		
		return searchBar
	}()

	let collectionView : UICollectionView = {
		
		let collectionView  = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		
		let customLayout = CategorySearchCollectionViewLayout(cellsPerRow: 2, minimumInteritemSpacing: 5, minimumLineSpacing: 40, sectionInset: UIEdgeInsets(top: 10, left: 5, bottom: 1, right: 5))
		
		collectionView.collectionViewLayout = customLayout
		collectionView.backgroundColor = .clear
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		
		return collectionView
	}()

	override var leftButton : NavbarButton {
		get {
			return back
		} set {
			back = newValue as! NavbarButtonBack
		}
	}
	
	override var rightButton: NavbarButton {
		get {
			return filters
		} set {
			filters = newValue as! NavbarButtonLines
		}
	}
	
	override func configureView() {
		navbar.addSubview(searchBar)
		addSubview(subtitle)
		addSubview(collectionView)
		super.configureView()
		
		applyConstraints()
	}

	override func applyConstraints() {
		super.applyConstraints()
		
		searchBar.snp.makeConstraints { (make) in
			make.left.equalTo(back.snp.right)
			make.right.equalTo(rightButton.snp.left)
			make.height.equalToSuperview()
			make.center.equalToSuperview()
		}
		subtitle.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom)
			make.centerX.equalToSuperview()
			make.height.equalTo(44)
			make.width.equalToSuperview()
		}
		collectionView.snp.makeConstraints { (make) in
			make.top.equalTo(subtitle.snp.bottom).inset(-20)
			make.bottom.equalTo(safeAreaLayoutGuide)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
		}
	}
}

class CategorySearch: BaseViewController {
	
	override var contentView: CategorySearchView {
		return view as! CategorySearchView
	}
	
	override func loadView() {
		view = CategorySearchView()
	}
	
	var dataSource : [SpotlightTutor] = [] {
		didSet {
			contentView.collectionView.reloadData()
		}
	}
	
	var category : Category! {
		didSet {
			SpotlightTutor.shared.queryByCategory(category:  category) { (tutors) in
				if let tutors = tutors {
					self.dataSource = tutors
				} else {
					print("Error querying tutors")
				}
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		contentView.subtitle.category.text = CategorySelected.title
		
		contentView.collectionView.delegate = self
		contentView.collectionView.dataSource = self
		contentView.collectionView.register(FeaturedTutorCollectionViewCell.self, forCellWithReuseIdentifier: "featuredCell")

		contentView.searchBar.delegate = self
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		contentView.searchBar.resignFirstResponder()
	}
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		contentView.collectionView.reloadData()
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	override func handleNavigation() {
		if touchStartView is NavbarButtonBack {
			self.dismiss(animated: true, completion: nil)
		}
	}
}

extension CategorySearch : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return dataSource.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! FeaturedTutorCollectionViewCell
		
		cell.price.text = dataSource[indexPath.item].price
		cell.featuredTutor.namePrice.text = dataSource[indexPath.item].name
		cell.featuredTutor.region.text = dataSource[indexPath.item].region
		cell.featuredTutor.subject.text = dataSource[indexPath.item].topic
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let current = UIApplication.getPresentedViewController() {
			current.present(TutorConnect(), animated: true, completion: nil)
		}
	}
}
extension CategorySearch : UISearchBarDelegate {
	internal func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		navigationController?.pushViewController(SearchSubjects(), animated: true)
	}
}

struct CategorySelected {
	static var title : String!
}
