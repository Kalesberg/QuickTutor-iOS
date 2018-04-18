//
//  TutorConnect.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

protocol ApplyLearnerFilters {
	var filters : (Int,Int,Bool)! { get set }
	func applyFilters()
}

class TutorConnectView : MainLayoutTwoButton {
	
	var back = NavbarButtonX()
	var filters = NavbarButtonLines()
	
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
		textField?.attributedPlaceholder = NSAttributedString(string: "Experiences", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		textField?.keyboardAppearance = .dark
		
		return searchBar
	}()
	
	let collectionView : UICollectionView = {
		
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		
		let layout = UICollectionViewFlowLayout()
		
		layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 0
		
		collectionView.backgroundColor = Colors.backgroundDark
		collectionView.collectionViewLayout = layout
		collectionView.backgroundColor = .clear
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.isPagingEnabled = true
		collectionView.decelerationRate = UIScrollViewDecelerationRateFast
		
		return collectionView
	}()
	
	override var leftButton : NavbarButton {
		get {
			return back
		} set {
			back = newValue as! NavbarButtonX
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
		collectionView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom)
			make.bottom.equalTo(safeAreaLayoutGuide)
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
	}
}

class TutorConnect : BaseViewController, ApplyLearnerFilters {
	
	var filters: (Int, Int, Bool)!
	
	func applyFilters() {
		//sort here... reset the database
		let sortedTutors = datasource.sorted { (tutor1 : FeaturedTutor, tutor2 : FeaturedTutor) -> Bool in
			
			let ratio1 = Double(tutor1.price) / Double(filters.1) / (tutor1.rating / 5.0)
			let ratio2 = Double(tutor2.price) / Double(filters.1) / (tutor2.rating / 5.0)

			return ratio1 < ratio2
		}
		self.datasource = sortedTutors
	}
	
	override var contentView: TutorConnectView {
		return view as! TutorConnectView
	}
	
	override func loadView() {
		view = TutorConnectView()
	}
	
	var featuredTutor : FeaturedTutor! {
		didSet {
			self.datasource.append(featuredTutor)
		}
	}
	
	var datasource = [FeaturedTutor]() {
		didSet {
			print("1")
			contentView.collectionView.reloadData()
		}
	}

	var subcategory : String! {
		didSet {
			QueryData.shared.queryBySubcategory(subcategory: subcategory) { (tutors) in
				if let tutor = tutors {
					self.datasource = tutor
				}
			}
		}
	}
	
	var subject : (String, String)! {
		didSet {
			QueryData.shared.queryBySubject(subcategory: subject.0, subject: subject.1) { (tutors) in
				if let tutors = tutors {
					self.datasource = tutors
				}
			}
		}
	}

	private var startingScrollingOffset = CGPoint.zero
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		contentView.collectionView.dataSource = self
		contentView.collectionView.delegate = self
		
		contentView.collectionView.register(TutorCardCollectionViewCell.self, forCellWithReuseIdentifier: "tutorCardCell")
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		contentView.collectionView.reloadData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func handleNavigation() {
		if touchStartView is NavbarButtonX{
			dismiss(animated: true, completion: nil)
		} else if touchStartView is NavbarButtonLines {
			let next = LearnerFilters()
			next.delegate = self
			self.present(next, animated: true, completion: nil)
		}
	}
}

extension TutorConnect : UIPopoverPresentationControllerDelegate {
	func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
		return .none
	}
}

extension TutorConnect : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
	internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return datasource.count
	}
	
	internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tutorCardCell", for: indexPath) as! TutorCardCollectionViewCell
		
		let data = datasource[indexPath.item]
		
		if let languages = data.language {
			cell.header.speakItem.label.text = "Speaks: \(languages.compactMap({$0}).joined(separator: ", "))"
		}
		cell.header.imageView.loadUserImages(by: (data.imageUrls["image1"])!)
		cell.header.name.text = data.name.components(separatedBy: " ")[0]
		cell.header.locationItem.label.text = data.region!
		cell.header.tutorItem.label.text = "\(data.hours!) hours taught, \(data.numSessions!) sessions"
		cell.header.studysItem.label.text = data.school
		cell.reviewLabel.text = "\(data.reviews?.count ?? 0) Reviews ★ \(data.rating!)"
		cell.rateLabel.text = "$\(data.price!) / hour"
		
		cell.datasource = datasource[indexPath.row]
		
		let formattedString = NSMutableAttributedString()
		formattedString
			.bold("126", 17, Colors.lightBlue)
			.regular("\n", 0, .clear)
			.bold("miles", 12, Colors.lightBlue)
			.regular("\n", 0, .clear)
			.bold("away", 12, Colors.lightBlue)
		
		let paragraphStyle = NSMutableParagraphStyle()
		
		paragraphStyle.alignment = .center
		paragraphStyle.lineSpacing = -2
		formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
		
		cell.distanceLabel.attributedText = formattedString
		cell.distanceLabel.numberOfLines = 0

		return cell
	}
	
	internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let width = UIScreen.main.bounds.width - 20
		
		return CGSize(width: width, height: collectionView.frame.height - 50)
		
	}
	
	internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 20
	}
}
