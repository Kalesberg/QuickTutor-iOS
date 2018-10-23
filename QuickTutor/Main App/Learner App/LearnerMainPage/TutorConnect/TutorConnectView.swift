//
//  TutorConnectView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class TutorConnectView: MainLayoutTwoButton {
	var backButton = NavbarButtonXLight()
	var applyFiltersButton = NavbarButtonFilters()
	
	let searchBar: UISearchBar = {
		let searchBar = UISearchBar()
		searchBar.sizeToFit()
		searchBar.searchBarStyle = .prominent
		searchBar.backgroundImage = UIImage(color: UIColor.clear)
		searchBar.showsCancelButton = false
		
		let textField = searchBar.value(forKey: "searchField") as? UITextField
		textField?.font = Fonts.createSize(14)
		textField?.textColor = .white
		textField?.tintColor = UIColor.clear
		textField?.adjustsFontSizeToFitWidth = true
		textField?.autocapitalizationType = .words
		textField?.attributedPlaceholder = NSAttributedString(string: "search anything", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
		textField?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		textField?.keyboardAppearance = .dark
		return searchBar
	}()
	
	let collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		
		let layout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 0
		
		collectionView.backgroundColor = Colors.backgroundDark
		collectionView.collectionViewLayout = layout
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.isPagingEnabled = true
		return collectionView
	}()
	
	override var leftButton: NavbarButton {
		get {
			return backButton
		} set {
			backButton = newValue as! NavbarButtonXLight
		}
	}
	
	override var rightButton: NavbarButton {
		get {
			return applyFiltersButton
		} set {
			applyFiltersButton = newValue as! NavbarButtonFilters
		}
	}
	
	let addPaymentModal = AddPaymentModal()
	
	override func configureView() {
		navbar.addSubview(searchBar)
		addSubview(collectionView)
		addSubview(addPaymentModal)
		super.configureView()
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		super.applyConstraints()
		searchBar.snp.makeConstraints { make in
			make.left.equalTo(backButton.snp.right).inset(15)
			make.right.equalTo(applyFiltersButton.snp.left).inset(15)
			make.height.equalTo(leftButton.snp.height)
			make.centerY.equalTo(backButton.image)
		}
		collectionView.snp.makeConstraints { make in
			make.top.equalTo(navbar.snp.bottom)
			make.bottom.width.centerX.equalToSuperview()
		}
		addPaymentModal.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
}
