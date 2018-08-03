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
		searchBar.searchBarStyle = .prominent
		searchBar.backgroundImage = UIImage(color: UIColor.clear)
		
		let textField = searchBar.value(forKey: "searchField") as? UITextField
		
		textField?.font = Fonts.createSize(18)
		textField?.textColor = .white
		textField?.adjustsFontSizeToFitWidth = true
		textField?.autocapitalizationType = .words
		textField?.attributedPlaceholder = NSAttributedString(string: CategorySelected.title, attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		textField?.backgroundColor = UIColor.black.withAlphaComponent(0.5)

		textField?.keyboardAppearance = .dark
		
		return searchBar
	}()

	let collectionView : UICollectionView = {
		
		let collectionView  = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		
		let customLayout = CategorySearchCollectionViewLayout(cellsPerRow: 3, minimumInteritemSpacing: 5, minimumLineSpacing: 50, sectionInset: UIEdgeInsets(top: 15, left: 10, bottom: 0, right: 10))
		
		collectionView.collectionViewLayout = customLayout
		collectionView.backgroundColor = .clear
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.alwaysBounceVertical = true
		
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
	let itemsPerBatch : UInt = 6
	
	var datasource = [FeaturedTutor]()
	var didLoadMore : Bool = false
	var allTutorsQueried: Bool = false
	
	var category : Category! {
		didSet {
			queryTutorsByCategory(lastKnownKey: nil)
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
	
	private func queryTutorsByCategory(lastKnownKey: String?) {
		self.displayLoadingOverlay()
		QueryData.shared.queryAWTutorByCategory(category: category, lastKnownKey: lastKnownKey, limit: itemsPerBatch, { (tutors) in
			if let tutors = tutors {
				self.allTutorsQueried = tutors.count != self.itemsPerBatch
				
				let startIndex = self.datasource.count
				self.datasource.append(contentsOf: tutors)
				let endIndex = self.datasource.count
				
				self.contentView.collectionView.performBatchUpdates({
					let insertPaths = Array(startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
					self.contentView.collectionView.insertItems(at: insertPaths)
				}, completion: { (finished) in
					self.didLoadMore = false
					self.dismissOverlay()
				})
			}
		})
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
			.bold("\(datasource[indexPath.item].rating) ", 14, Colors.yellow)
			.regular("(\(datasource[indexPath.item].reviews) ratings)", 12, Colors.yellow)
		cell.featuredTutor.ratingLabel.attributedText = formattedString
        
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
        let screen = UIScreen.main.bounds
        
        if screen.height == 568 || screen.height == 480 {
            return CGSize(width: (screen.width / 2.5) - 13, height: 190)
        } else {
            return CGSize(width: (screen.width / 3) - 13, height: 190)
        }
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
		navigationController?.pushViewController(SearchSubjects(), animated: true)
	}
}

extension CategorySearch : UIScrollViewDelegate {
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if allTutorsQueried { return }
		
		let currentOffset = scrollView.contentOffset.y
		let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
		
		if maximumOffset - currentOffset <= 100.0 {
			queryTutorsByCategory(lastKnownKey: datasource[datasource.endIndex - 1].uid)
		}
	}
}
