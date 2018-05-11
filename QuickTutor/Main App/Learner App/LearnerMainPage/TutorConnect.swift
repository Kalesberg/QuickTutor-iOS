//
//  TutorConnect.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol ApplyLearnerFilters {
	var filters : (Int,Int,Bool)! { get set }
	var location : CLLocation? { get set}
	func applyFilters()
}

protocol ConnectButtonPress {
	var connectedTutor : AWTutor! { get set }
	func connectButtonPressed(uid: String)
}

class TutorConnectView : MainLayoutTwoButton {
	
	var back = NavbarButtonX()
	var filters = NavbarButtonFilters()
	
	let searchBar : UISearchBar = {
		let searchBar = UISearchBar()
		
		searchBar.sizeToFit()
		searchBar.searchBarStyle = .minimal
		searchBar.backgroundImage = UIImage(color: UIColor.clear)
		
		let textField = searchBar.value(forKey: "searchField") as? UITextField
		textField?.font = Fonts.createSize(14)
		textField?.textColor = .white
		textField?.adjustsFontSizeToFitWidth = true
		textField?.autocapitalizationType = .words
		textField?.attributedPlaceholder = NSAttributedString(string: "search anything", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		textField?.keyboardAppearance = .dark
		
		return searchBar
	}()
	
	let collectionView : UICollectionView = {
		
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
		
		let layout = UICollectionViewFlowLayout()
		
		layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = 0
		
		collectionView.backgroundColor = Colors.backgroundDark
		collectionView.collectionViewLayout = layout
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
			filters = newValue as! NavbarButtonFilters
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
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().inset(3)
		}
		collectionView.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom)
			make.bottom.equalToSuperview()
			make.width.equalToSuperview()
			make.centerX.equalToSuperview()
		}
	}
}

class TutorConnect : BaseViewController, ApplyLearnerFilters {
	
	override var contentView: TutorConnectView {
		return view as! TutorConnectView
	}
	
	override func loadView() {
		view = TutorConnectView()
	}
	
	var filters: (Int, Int, Bool)!
	var location : CLLocation?
	var shouldFilterDatasource = false
	var hasAppliedFilters = false
	
	var datasource = [AWTutor]() {
		didSet {
			if datasource.count == 0 {
				let view = NoResultsView()
				view.label.text = "No tutors currently available 👨🏽‍🏫"
				contentView.collectionView.backgroundView = view
			}
			contentView.collectionView.reloadData()
		}
	}
	
	var filteredDatasource = [AWTutor]() {
		didSet {
			print(filteredDatasource)
			if filteredDatasource.count == 0 {
				let view = NoResultsView()
				view.label.text = "0 results 😭 \nAdjust your filters to get better results"
				contentView.collectionView.backgroundView = view
			}

			contentView.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: true)
			
			contentView.collectionView.reloadData()

		}
	}
	
	var featuredTutor : AWTutor! {
		didSet {
			self.datasource.append(featuredTutor)
		}
	}
	
	var subcategory : String! {
		didSet {
			QueryData.shared.queryAWTutorBySubcategory(subcategory: subcategory!) { (tutors) in
				if let tutors = tutors {
					self.datasource = tutors.sortWithoutDistance()
				}
			}
		}
	}
	
	var subject : (String, String)! {
		didSet {
			QueryData.shared.queryAWTutorBySubject(subcategory: subject.0, subject: subject.1) { (tutors) in
				if let tutors = tutors {
					self.datasource = tutors.sortWithoutDistance()
				}
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		hideKeyboardWhenTappedAround()
		
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
	
	func sortWithDistance(_ tutors: [AWTutor] ) {
		if tutors.count == 0 {
			filteredDatasource = []
			return
		}
		
		guard let currentUserLocation = location else {
			print("unable to find your location.")
			filteredDatasource = tutors.sortWithoutDistance()
			return
		}
		
		var d0 : Double = 150
		var d1 : Double = 150
		
		filteredDatasource = tutors.sorted {
			if let location1 = $0.location?.location {
				d0 = location1.distance(from: currentUserLocation)
			}
			
			if let location2 = $1.location?.location {
				d1 = location2.distance(from: currentUserLocation)
			}
			
			if $0.tRating != $1.tRating {
				return $0.tRating > $1.tRating
			} else if $0.price != $1.price {
				return $0.price < $1.price
			} else if d0 != d1 {
				return d0 < d1
			} else if $0.hours != $1.hours {
				return $0.hours < $1.hours
			} else if $0.numSessions != $1.numSessions {
				return $0.numSessions < $0.numSessions
			} else {
				return $0.name < $1.name
			}
		}
	}
	
	func applyFilters() {
		
		if filters.2 == false && filters.1 == -1 && filters.0 == -1 {
			hasAppliedFilters = false
			shouldFilterDatasource = false
			contentView.collectionView.reloadData()
			return
		}
		
		var distance : Double = 0.0
		var tutors =  [AWTutor]()
		
		shouldFilterDatasource = true
		hasAppliedFilters = true
		
		if filters.2 {
			tutors = (filters.1 != -1) ? datasource.filter { ($0.price <= filters.1) } : datasource
			filteredDatasource = tutors.sortWithoutDistance()
		} else {
			tutors = (filters.1 != -1) ? datasource.filter { ($0.price <= filters.1) } : datasource
			if filters.0 != -1 {
				tutors = tutors.filter {
					if let currentUserLocation = location {
						if let tutorLocation = $0.location?.location {
							distance = currentUserLocation.distance(from: tutorLocation) * 0.00062137
							return (distance <= Double(filters.0))
						} else {
							return (false)
						}
					} else {
						print("No location for tutor.")
						filteredDatasource = tutors.sortWithoutDistance()
						return (false)
					}
				}
				sortWithDistance(tutors)
			} else {
				if tutors.count == 0 {
					filteredDatasource = []
					return
				}
				filteredDatasource = tutors.sortWithoutDistance()
			}
		}
	}
	
	override func handleNavigation() {
		if touchStartView is NavbarButtonFilters {
			
			let next = LearnerFilters()
			
			if hasAppliedFilters {
				
				next.distance = (filters.0 - 10 >= 0) ? filters.0 - 10 : 0
				next.price = (filters.1 - 10 >= 0) ? filters.1 - 10 : 0
				next.video = filters.2
			}
			
			next.delegate = self
			self.present(next, animated: true, completion: nil)
			
		} else if touchStartView is NavbarButtonX {
			let transition = CATransition()
			navigationController?.view.layer.add(transition.popFromTop(), forKey: nil)
			navigationController?.popViewController(animated: false)
		}
	}
}

extension TutorConnect : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
	
	internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if shouldFilterDatasource {
			return filteredDatasource.count
		}
		return datasource.count
	}
	
	internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let data = (shouldFilterDatasource) ? filteredDatasource : datasource
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tutorCardCell", for: indexPath) as! TutorCardCollectionViewCell

		cell.header.imageView.loadUserImages(by: data[indexPath.row].images["image1"]!)
		cell.header.name.text = data[indexPath.row].name.formatName()
		cell.reviewLabel.text = data[indexPath.row].reviews?.count.formatReviewLabel(rating: data[indexPath.row].tRating)
		cell.rateLabel.text = data[indexPath.row].price.formatPrice()
		cell.datasource = data[indexPath.row]
		
		if let location = location {
			if let tutorLocation = data[indexPath.row].location?.location {
				let distance = location.distance(from: tutorLocation) / 1609.343
				cell.distanceLabelContainer.isHidden = false
				cell.distanceLabel.attributedText = distance.formatDistance()
			}
		}
		
		cell.connectButton.connect.text = (CurrentUser.shared.learner.connectedTutors.contains(data[indexPath.row].uid)) ? "Message" : "Connect"

		return cell
	}
	
	internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let width = UIScreen.main.bounds.width - 20
		
		return CGSize(width: width, height: collectionView.frame.height)
	}
	
	internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 20
	}
}

extension Array where Element: AWTutor {
	func sortWithoutDistance() -> [AWTutor] {
		return sorted {
			if $0.tRating != $1.tRating {
				return $0.tRating > $1.tRating
			} else if $0.price != $1.price {
				return $0.price < $1.price
			} else if $0.hours != $1.hours {
				return $0.hours < $1.hours
			} else if $0.numSessions != $1.numSessions {
				return $0.numSessions < $0.numSessions
			}  else {
				return $0.name < $1.name
			}
		}
	}
}
