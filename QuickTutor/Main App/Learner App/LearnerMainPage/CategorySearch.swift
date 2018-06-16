//
//  CategorySearch.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

struct CategorySelected {
	static var title : String!
}


class CategorySearchView : MainLayoutTwoButton {
	
	var back =  NavbarButtonBack()
	
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
		
		let customLayout = CategorySearchCollectionViewLayout(cellsPerRow: 2, minimumInteritemSpacing: 5, minimumLineSpacing: 40, sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
		
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
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
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
	
	var datasource = [FeaturedTutor]()
	var didLoadMore : Bool = false

	var category : Category! {
		didSet {
			queryTutorsByCategory()
		}
	}
	
	private func queryTutorsByCategory() {
		QueryData.shared.queryAWTutorByCategory(category: category, { (tutors) in
			if let tutors = tutors {
				let startIndex = self.datasource.count
				self.datasource.append(contentsOf: tutors)
				let endIndex = self.datasource.count
				
				self.contentView.collectionView.performBatchUpdates({
					let insertPaths = Array(startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
					self.contentView.collectionView.insertItems(at: insertPaths)
				}, completion: { (finished) in
					self.didLoadMore = false
				})
			}
		})
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
	}
	
	override func handleNavigation() {
	}
}

extension CategorySearch : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return datasource.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredCell", for: indexPath) as! FeaturedTutorCollectionViewCell
		
		cell.featuredTutor.imageView.loadUserImagesWithoutMask(by: datasource[indexPath.item].imageUrl)
		cell.price.text = datasource[indexPath.item].price.priceFormat()
		cell.featuredTutor.namePrice.text = datasource[indexPath.item].name
		cell.featuredTutor.region.text = datasource[indexPath.item].region
		cell.featuredTutor.subject.text = datasource[indexPath.item].subject
		
		let formattedString = NSMutableAttributedString()
		
		formattedString
			.bold("\(datasource[indexPath.item].rating)  ", 14, Colors.yellow)
			.regular("(\(datasource[indexPath.item].reviews) ratings)", 12, Colors.yellow)
		cell.featuredTutor.ratingLabel.attributedText = formattedString
        
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! FeaturedTutorCollectionViewCell
		cell.shrink()
	}
	func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! FeaturedTutorCollectionViewCell
		UIView.animate(withDuration: 0.2) {
			cell.transform = CGAffineTransform.identity
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! FeaturedTutorCollectionViewCell
		cell.growSemiShrink {
			let next = TutorConnect()
			next.featuredTutorUid = self.datasource[indexPath.item].uid
			
			let nav = self.navigationController
			let transition = CATransition()
			
			DispatchQueue.main.async {
				nav?.view.layer.add(transition.segueFromBottom(), forKey: nil)
				nav?.pushViewController(next, animated: false)
			}
		}
	}
}

extension CategorySearch : UISearchBarDelegate {
	internal func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		let next = SearchSubjects()
		if let index = Category.categories.index(of: category) {
			next.initialIndex = IndexPath(item: index, section: 0)
			navigationController?.pushViewController(next, animated: true)
		} else{
			navigationController?.pushViewController(next, animated: true)
		}
	}
}
