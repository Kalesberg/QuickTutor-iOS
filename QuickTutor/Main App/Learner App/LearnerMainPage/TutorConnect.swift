//
//  TutorConnect.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

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
		
		layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0)
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

class TutorConnect : BaseViewController {
	
	override var contentView: TutorConnectView {
		return view as! TutorConnectView
	}
	
	override func loadView() {
		view = TutorConnectView()
	}
	
	var tutorReviews : [TutorReview]! {
		didSet {
			//reload a view or sumthin
		}
	}
	var tutorSubjects : [TutorSubcategory]! {
		didSet {
			//reload or sumthin
		}
	}
	
	var featuredTutor : FeaturedTutor! {
		
		didSet {
			self.datasource.append(featuredTutor)
			QueryData.shared.loadReviews(uid: featuredTutor.uid) { (review) in
				if let reviews = review {
					self.tutorReviews = reviews
				}
			}
			
			QueryData.shared.loadSubjects(uid: featuredTutor.uid) { (subjects) in
				if let subjects = subjects {
					self.tutorSubjects = subjects
				}
			}
		}
	}
	
	var datasource = [FeaturedTutor]() {
		didSet {
			contentView.collectionView.reloadData()
		}
	}
	
	var subcategory : String! {
		didSet {
			QueryData.shared.queryBySubcategory(subcategory: subcategory) { (tutors) in
				if let tutors = tutors {
					self.datasource = tutors
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
		// Dispose of any resources that can be recreated.
	}
	
	override func handleNavigation() {
		if touchStartView is NavbarButtonX{
			dismiss(animated: true, completion: nil)
		} else if touchStartView is NavbarButtonLines {
			self.present(LearnerFilters(), animated: true, completion: nil)
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
    
		cell.header.imageView.loadUserImages(by: data.imageUrls["image1"]!)
        
        let name = data.name.components(separatedBy: " ")
        let index = name[1].index(name[1].startIndex, offsetBy: 0)
    
        cell.header.name.text = "\(name[0]) \(String(name[1][index]).uppercased())."
//        cell.header.locationItem.label.text = data.region!
//        cell.header.tutorItem.label.text = "\(data.hours!) hours taught, \(data.numSessions!) sessions"
//        cell.header.speakItem.label.text = "Speaks: \(data.language.compactMap({$0}).joined(separator: ", "))"
//        cell.header.studysItem.label.text = data.school
        cell.reviewLabel.text = "\(data.numSessions!) Reviews ★ \(data.rating!)"
        cell.rateLabel.text = "$\(data.price!) / hour"
        
        //(cell.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! AboutMeTableViewCell).aboutMeLabel.label.text = "About " + data.name.components(separatedBy: " ")[0]
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("12", 17, Colors.lightBlue)
            .regular("\n", 0, .clear)
            .bold("miles", 12, Colors.lightBlue)
        
        let paragraphStyle = NSMutableParagraphStyle()
		
		paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = -2
        formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
        
        cell.distanceLabel.attributedText = formattedString
        cell.distanceLabel.numberOfLines = 0
        
        //(cell.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! AboutMeTableViewCell).bioLabel.text = "This is the bio" //datasource[indexPath.item].bio - this fails for some reason... bio or not
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
