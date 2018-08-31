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
    var location : CLLocation? { get set }
    func postFilterTutors()
}

protocol ConnectButtonPress {
    var connectedTutor : AWTutor! { get set }
    func connectButtonPressed(uid: String)
}

class TutorConnectView : MainLayoutTwoButton {
    
    var backButton = NavbarButtonXLight()
    var applyFiltersButton = NavbarButtonFilters()

    let searchBar : UISearchBar = {
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
        textField?.attributedPlaceholder = NSAttributedString(string: "search anything", attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
		textField?.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        textField?.keyboardAppearance = .dark
        
        return searchBar
    }()
    
    let collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
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
        
        searchBar.snp.makeConstraints { (make) in
			make.left.equalTo(backButton.snp.right).inset(15)
			make.right.equalTo(applyFiltersButton.snp.left).inset(15)
			make.height.equalTo(leftButton.snp.height)
			make.centerY.equalTo(backButton.image)
        }
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.bottom.width.centerX.equalToSuperview()
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
            .regular("\n\nSorry! We couldn't find anything, try adjusting your filters in the top right of the screen to improve your search results.", 17, .white)
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
            make.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6)
            make.bottom.equalTo(label.snp.top).inset(-25)
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

class TutorConnect : BaseViewController {
    
    override var contentView: TutorConnectView {
        return view as! TutorConnectView
    }
    
    override func loadView() {
        view = TutorConnectView()
    }
	
    var shouldFilterDatasource = false
    var hasAppliedFilters = false
    var shouldShowTutorial = false
	
	var filters : Filters?
	var delegate : UpdatedFiltersCallback?
	
    var datasource = [AWTutor]() {
        didSet {
            contentView.collectionView.backgroundView = (datasource.count == 0) ? TutorCardCollectionViewBackground() : nil
			if filters != nil {
				filterTutors()
			}
			contentView.collectionView.reloadData()
		}
    }
    
    var filteredDatasource = [AWTutor]() {
        didSet {
            contentView.collectionView.backgroundView = (filteredDatasource.count == 0) ? TutorCardCollectionViewBackground() : nil
			setupCollectionViewAfterUpdate()
        }
    }
    
    var featuredTutorUid : String! {
        didSet {
			displayLoadingOverlay()
			FirebaseData.manager.fetchTutor(featuredTutorUid, isQuery: false) { (tutor) in
				if let tutor = tutor {
					self.datasource.append(tutor)
					self.contentView.rightButton.isHidden = true
				} else {
					AlertController.genericErrorAlert(self, title: "Error", message: "Unable to load tutor.")
					self.navigationController?.popViewController(animated: true)
				}
				self.dismissOverlay()
			}
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
	
		contentView.searchBar.delegate = self
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
        contentView.collectionView.reloadData()
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
        return (v / (v + m)) * ((r + Double((m / (v + m)))) * C)
    }
    
    private func sortTutorsWithWeightedList(tutors: [AWTutor]) -> [AWTutor] {
        guard tutors.count > 1 else { return tutors }
        let avg = tutors.map({$0.tRating / 5}).average
        return tutors.sorted {
            return bayesianEstimate(C: avg, r: $0.tRating / 5, v: Double($0.tNumSessions), m: 1) > bayesianEstimate(C: avg, r: $1.tRating / 5, v: Double($1.tNumSessions), m: 1)
        }
    }

    private func filterByPrice(priceFilter: Int?, tutors: [AWTutor]) -> [AWTutor] {
		guard let price = priceFilter, priceFilter != -1, !tutors.isEmpty else { return tutors }
        return tutors.filter { $0.price <= price }
    }
	
	private func filterByDistance(location: CLLocation?, distanceFilter: Int?, tutors: [AWTutor]) -> [AWTutor] {
		guard let distance = distanceFilter, distanceFilter != -1, !tutors.isEmpty else { return tutors}
        guard let location = location else { return tutors }
        
        return tutors.filter {
            if let tutorLocation = $0.location?.location {
                return (location.distance(from: tutorLocation) * 0.00062137) <= Double(distance)
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
	
	private func setupCollectionViewAfterUpdate() {
		guard filteredDatasource.count > 0 else { return }
		contentView.collectionView.reloadData()
		contentView.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
	}
    private func filterTutors() {
		if filters?.price == -1 && filters?.distance == -1 && filters?.sessionType == false {
			hasAppliedFilters = false
			shouldFilterDatasource = false
		} else {
			hasAppliedFilters = true
			shouldFilterDatasource = true
			let filtered = filterBySessionType(searchTheWorld: filters?.sessionType ?? false, tutors: filterByDistance(location: filters?.location, distanceFilter: filters?.distance ?? -1, tutors: filterByPrice(priceFilter: filters?.price ?? -1, tutors: datasource)))
			filteredDatasource = sortTutorsWithWeightedList(tutors: filtered)
		}
    }
    
    override func handleNavigation() {
        if touchStartView is NavbarButtonFilters {
            let next = LearnerFilters()
            next.delegate = self
			next.filters = self.filters
            self.present(next, animated: true, completion: nil)
            
        } else if touchStartView is NavbarButtonXLight {
			let nav = self.navigationController
			DispatchQueue.main.async {
				nav?.view.layer.add(CATransition().popFromTop(), forKey: nil)
				nav?.popViewController(animated: false)
			}
        } else if touchStartView is AddBankButton {
			self.dismissPaymentModal()
            let next = CardManager()
            next.popToMain = false
            navigationController?.pushViewController(next, animated: true)
        }
    }
}

extension TutorConnect : UpdatedFiltersCallback {
	func filtersUpdated(filters: Filters) {
		self.filters = filters
		filterTutors()
		delegate?.filtersUpdated(filters: filters)
	}
}

extension TutorConnect : ProfileImageViewerDelegate {
	func dismiss() {
		self.dismissProfileImageViewer()
	}
}

extension TutorConnect : AddPaymentButtonPress {
	func dismissPaymentModal() {
		self.dismissAddPaymentMethod()
	}
}

extension TutorConnect : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return shouldFilterDatasource ? filteredDatasource.count : datasource.count
    }
    
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = (shouldFilterDatasource) ? filteredDatasource : datasource
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tutorCardCell", for: indexPath) as! TutorCardCollectionViewCell

        cell.header.profilePics.loadUserImagesWithoutMask(by: data[indexPath.row].images["image1"]!)
        cell.header.profilePics.roundCorners(.allCorners, radius: 8)
        cell.header.name.text = data[indexPath.row].name.formatName()
        cell.reviewLabel.text = data[indexPath.row].reviews?.count.formatReviewLabel(rating: data[indexPath.row].tRating)
        cell.rateLabel.text = data[indexPath.row].price.formatPrice()
        cell.datasource = data[indexPath.row]
		
		if let location = filters?.location {
            if let tutorLocation = data[indexPath.row].location?.location {
                let distance = location.distance(from: tutorLocation) / 1609.343
                cell.distanceLabelContainer.isHidden = false
                cell.distanceLabel.attributedText = distance.formatDistance()
            }
        }
        cell.connectButton.connect.text = (CurrentUser.shared.learner.connectedTutors.contains(data[indexPath.row].uid)) ? "Message" : "Connect"
        return cell
    }
    
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 20
        return CGSize(width: width, height: collectionView.frame.height - 20)
    }
    
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

extension TutorConnect : UISearchBarDelegate {
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		self.navigationController?.popOrPushSearchSubjects()
	}
}
