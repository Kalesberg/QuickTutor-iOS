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
    func filterTutors()
}

protocol ConnectButtonPress {
    var connectedTutor : AWTutor! { get set }
    func connectButtonPressed(uid: String)
}

class TutorConnectView : MainLayoutTwoButton {
    
    var back = NavbarButtonXLight()
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
            back = newValue as! NavbarButtonXLight
        }
    }
    
    override var rightButton: NavbarButton {
        get {
            return filters
        } set {
            filters = newValue as! NavbarButtonFilters
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
        
        searchBar.snp.makeConstraints { (make) in
            make.left.equalTo(back.snp.right)
            make.right.equalTo(rightButton.snp.left)
            make.height.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        addPaymentModal.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}


class TutorCardCollectionViewBackground : BaseView {
    
    let imageView : UIImageView = {
        let view = UIImageView()
        
        view.image = #imageLiteral(resourceName: "sad-face")
        
        return view
    }()
    
    let label : UILabel = {
        let label = UILabel()
        
        let formattedString = NSMutableAttributedString()
        
        formattedString
            .bold("No Tutors Found", 22, .white)
            .regular("\n\nSorry! We couldn't find anything, try adjusting your filters to improve your search results.", 17, .white)
        
        label.attributedText = formattedString
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    override func configureView() {
        addSubview(imageView)
        addSubview(label)
        super.configureView()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.75)
            make.center.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.bottom.equalTo(label.snp.top)
        }
    }
}


class TutorCardTutorial : InteractableView, Interactable {
    
    let imageView : UIImageView = {
        let view = UIImageView()
        
        view.image = #imageLiteral(resourceName: "finger")
        
        return view
    }()
    
    let label : UILabel = {
        let label = UILabel()
        
        label.text = "Swipe left to see more tutors!"
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createBoldSize(20)
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    override func configureView() {
        addSubview(imageView)
        addSubview(label)
        super.configureView()
        
        backgroundColor = UIColor.black.withAlphaComponent(0.85)
        alpha = 0
        clipsToBounds = true
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.2)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.9)
        }
    }
    
    func touchEndOnStart() {
        UIView.animate(withDuration: 0.6, animations: {
            self.alpha = 0.0
        }) { (true) in
            self.isHidden = true
            self.removeFromSuperview()
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
    var shouldShowTutorial = false
    
    var datasource = [AWTutor]() {
        didSet {
            if datasource.count == 0 {
                let view = NoResultsView()
                view.label.text = "No tutors currently available 👨🏽‍🏫"
                contentView.collectionView.backgroundView = view
			} else {
				contentView.collectionView.backgroundView = nil
			}
            contentView.collectionView.reloadData()
        }
    }
    
    var filteredDatasource = [AWTutor]() {
        didSet {
            if filteredDatasource.count == 0 {
                let view = NoResultsView()
                view.label.text = "0 results 😭 \nAdjust your filters to get better results"
                contentView.collectionView.backgroundView = view
			} else {
				contentView.collectionView.backgroundView = nil
			}
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
			self.displayLoadingOverlay()
            QueryData.shared.queryAWTutorBySubcategory(subcategory: subcategory!) { (tutors) in
                if let tutors = tutors {
					self.datasource = self.sortTutorsWithWeightedList(tutors: tutors)
                }
				self.dismissOverlay()
            }
        }
    }
    
    var subject : (String, String)! {
        didSet {
			self.displayLoadingOverlay()
            QueryData.shared.queryAWTutorBySubject(subcategory: subject.0, subject: subject.1) { (tutors) in
                if let tutors = tutors {
					self.datasource = self.sortTutorsWithWeightedList(tutors: tutors)
                }
				self.dismissOverlay()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
		
		let defaults = UserDefaults.standard
		if defaults.bool(forKey: "showTutorCardTutorial1.0") {
			displayTutorial()
			defaults.set(false, forKey: "showTutorCardTutorial1.0")
		}  
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func displayTutorial() {
        
        let tutorial = TutorCardTutorial()
        contentView.addSubview(tutorial)
        
        tutorial.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        contentView.leftButton.isUserInteractionEnabled = false
        contentView.rightButton.isUserInteractionEnabled = false
        contentView.collectionView.isUserInteractionEnabled = false
        contentView.searchBar.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 1, animations: {
            tutorial.alpha = 1
        }, completion: { (true) in
            UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse], animations: {
                tutorial.imageView.center.x -= 30
            }, completion: { (true) in
                self.contentView.leftButton.isUserInteractionEnabled = true
                self.contentView.rightButton.isUserInteractionEnabled = true
                self.contentView.collectionView.isUserInteractionEnabled = true
                self.contentView.searchBar.isUserInteractionEnabled = true
            })
        })
    }

	private func bayesianEstimate(C: Double, r: Double, v: Double, m: Double) -> Double {
		return (v / (v+m)) * ((r + Double((m / (v+m)))) * C)
	}
	
	private func sortTutorsWithWeightedList(tutors: [AWTutor]) -> [AWTutor] {
		guard tutors.count > 1 else { return tutors }
		let avg = tutors.map({$0.tRating / 5}).average
		return tutors.sorted {
			return bayesianEstimate(C: avg, r: $0.tRating / 5, v: Double($0.numSessions), m: 1) > bayesianEstimate(C: avg, r: $1.tRating / 5, v: Double($1.numSessions), m: 1)
		}
	}

	private func filterByPrice(priceFilter: Int, tutors: [AWTutor]) -> [AWTutor] {
		if priceFilter == -1 || tutors.isEmpty {
			return tutors
		}
		return tutors.filter { $0.price <= priceFilter }
	}
	private func filterByDistance(distanceFilter: Int, tutors: [AWTutor]) -> [AWTutor] {
		if distanceFilter == -1 || tutors.isEmpty {
			return tutors
		}
		guard let userLocation = location else { return tutors }
		
		return tutors.filter {
			if let tutorLocation = $0.location?.location {
				return (userLocation.distance(from: tutorLocation) * 0.00062137) <= Double(distanceFilter)
			}
			return false
		}
	}
	private func filterBySessionType(searchTheWorld: Bool, tutors: [AWTutor]) -> [AWTutor] {
		if searchTheWorld {
			return tutors.filter { $0.preference == 1 || $0.preference == 3 }
		}
		return tutors.filter { $0.preference == 2 || $0.preference == 3 }
	}
	
    func filterTutors() {
		if filters.0 == -1 && filters.1 == -1 && filters.2 == false {
			hasAppliedFilters = false
			shouldFilterDatasource = false
			return
		}
		hasAppliedFilters = true
		shouldFilterDatasource = true

		let filtered = filterBySessionType(searchTheWorld: filters.2, tutors: filterByDistance(distanceFilter: filters.0, tutors: filterByPrice(priceFilter: filters.1, tutors: datasource)))
		
		filteredDatasource = sortTutorsWithWeightedList(tutors: filtered)
    }
    
    override func handleNavigation() {
        if touchStartView is NavbarButtonFilters {
            
            let next = LearnerFilters()
			next.delegate = self
            if hasAppliedFilters {
                next.distance = (filters.0 - 10 >= 0) ? filters.0 - 10 : 0
                next.price = (filters.1 - 10 >= 0) ? filters.1 - 10 : 0
                next.video = filters.2
            }
            self.present(next, animated: true, completion: nil)
            
        } else if touchStartView is NavbarButtonXLight {
            let transition = CATransition()
            navigationController?.view.layer.add(transition.popFromTop(), forKey: nil)
            navigationController?.popViewController(animated: false)
        } else if touchStartView is AddBankButton {
            contentView.addPaymentModal.isHidden = true
            navigationController?.pushViewController(CardManager(), animated: true)
        }
    }
}

extension Array where Element: Numeric {
	/// Returns the total sum of all elements in the array
	var total: Element { return reduce(0, +) }
}

extension Array where Element: FloatingPoint {
	/// Returns the average of all elements in the array
	var average: Element {
		return isEmpty ? 0 : total / Element(count)
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
