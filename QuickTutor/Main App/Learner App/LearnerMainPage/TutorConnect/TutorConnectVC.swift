//
//  TutorConnect.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import CoreLocation
import UIKit
import FirebaseUI

protocol ApplyLearnerFilters {
    var filters: (Int, Int, Bool)! { get set }
    var location: CLLocation? { get set }
    func postFilterTutors()
}

class TutorConnectVC: BaseViewController {
    override var contentView: TutorConnectView {
        return view as! TutorConnectView
    }

    override func loadView() {
        view = TutorConnectView()
    }

	let storageRef: StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)

    var shouldFilterDatasource = false
    var hasAppliedFilters = false
    var shouldShowTutorial = false

    var filters: Filters?
    var delegate: UpdatedFiltersCallback?

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
	
	let itemsPerBatch: UInt = 8
	
	var startIndex : IndexPath!
	var allTutorsQueried: Bool = false
	var didLoadMore: Bool = false
	var category: Category!
	
	var featuredTutors = [FeaturedTutor]() {
		didSet {
			displayLoadingOverlay()
			fetchFeaturedTutorCards(featuredTutors: featuredTutors) { (tutors) in
				if let tutors = tutors {
					self.datasource = tutors
					self.contentView.collectionView.scrollToItem(at: self.startIndex, at: .centeredHorizontally, animated: false)
				}
				self.dismissOverlay()
			}
		}
	}
    var subcategory: String! {
        didSet {
            displayLoadingOverlay()
            QueryData.shared.queryAWTutorBySubcategory(subcategory: subcategory!) { tutors in
                if let tutors = tutors {
                    self.datasource = self.sortTutorsWithWeightedList(tutors: tutors)
                }
                self.dismissOverlay()
            }
        }
    }

	var subject: (subcategory: String, subject: String)! {
        didSet {
            self.displayLoadingOverlay()
            QueryData.shared.queryAWTutorBySubject(subcategory: subject.subcategory, subject: subject.subject) { tutors in
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

    func displayTutorial() {
        let tutorial = TutorCardTutorial()
        contentView.addSubview(tutorial)

        tutorial.snp.makeConstraints { make in
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
        let avg = tutors.map({ $0.tRating / 5 }).average
        return tutors.sorted {
            bayesianEstimate(C: avg, r: $0.tRating / 5, v: Double($0.tNumSessions), m: 1) > bayesianEstimate(C: avg, r: $1.tRating / 5, v: Double($1.tNumSessions), m: 1)
        }
    }

    private func filterByPrice(priceFilter: Int?, tutors: [AWTutor]) -> [AWTutor] {
        guard let price = priceFilter, priceFilter != -1, !tutors.isEmpty else { return tutors }
        return tutors.filter { $0.price <= price }
    }

    private func filterByDistance(location: CLLocation?, distanceFilter: Int?, tutors: [AWTutor]) -> [AWTutor] {
        guard let distance = distanceFilter, distanceFilter != -1, !tutors.isEmpty else { return tutors }
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
	
	private func fetchFeaturedTutorCards(featuredTutors: [FeaturedTutor],_ completion: @escaping ([AWTutor]?) -> Void) {
		QueryData.shared.queryAWFeaturedTutorsCard(featuredTutors: featuredTutors) { (tutors) in
			if let tutors = tutors {
				completion(tutors)
			}
			completion(nil)
		}
	}
	private func queryTutorsUidsByCategory(lastKnownKey: String?) {
		QueryData.shared.queryAWTutorUidsByCategory(category: category, lastKnownKey: lastKnownKey, limit: itemsPerBatch) { (featuredTutors) in
			if let featuredTutors = featuredTutors {
				self.allTutorsQueried = featuredTutors.count != self.itemsPerBatch
				let startIndex = self.datasource.count
				self.fetchFeaturedTutorCards(featuredTutors: featuredTutors, { (tutors) in
					if let tutors = tutors {
						self.contentView.collectionView.performBatchUpdates({
							self.datasource.append(contentsOf: tutors)
							let endIndex = self.datasource.count
							
							let insertPaths = Array(startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
							self.contentView.collectionView.insertItems(at: insertPaths)
						}, completion: { _ in
							self.didLoadMore = false
						})
					}
				})
			}
		}
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
            let next = LearnerFiltersVC()
            next.delegate = self
            next.filters = filters
            present(next, animated: true, completion: nil)

        } else if touchStartView is NavbarButtonXLight {
            let nav = navigationController
            DispatchQueue.main.async {
                nav?.view.layer.add(CATransition().popFromTop(), forKey: nil)
                nav?.popViewController(animated: false)
            }
        }
    }
}

extension TutorConnectVC: UpdatedFiltersCallback {
    func filtersUpdated(filters: Filters) {
        self.filters = filters
        filterTutors()
        delegate?.filtersUpdated(filters: filters)
    }
}

extension TutorConnectVC: ProfileImageViewerDelegate {
    func dismiss() {
        dismissProfileImageViewer()
    }
}

extension TutorConnectVC: AddPaymentButtonPress {
    func dismissPaymentModal() {
        dismissAddPaymentMethod()
    }
}

extension TutorConnectVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return shouldFilterDatasource ? filteredDatasource.count : datasource.count
    }

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tutorCardCell", for: indexPath) as! TutorCardCollectionViewCell
		let data = shouldFilterDatasource ? filteredDatasource : datasource
		let reference : StorageReference
		
		//set up and initializer for this... very brittle.
		cell.parentViewController = self
		cell.tutor = data[indexPath.item]
		
		if let featuredDetails = data[indexPath.item].featuredDetails {
			reference = storageRef.child("featured").child(data[indexPath.item].uid).child("featuredImage")
			cell.tutorCardHeader.featuredSubject.text = featuredDetails.subject
			cell.tutorCardHeader.featuredSubject.isHidden = false
			cell.tutorCardHeader.price.text = "$\(featuredDetails.price)/hr"
		} else {
			reference = storageRef.child("student-info").child(data[indexPath.item].uid).child("student-profile-pic1")
			cell.tutorCardHeader.price.text = "$\(data[indexPath.item].price ?? 0)/hr"
		}
		cell.tutorCardHeader.profileImageView.sd_setImage(with: reference, placeholderImage: #imageLiteral(resourceName: "placeholder-square"))
		cell.tutorCardHeader.profileImageView.roundCorners(.allCorners, radius: 8)
		cell.tutorCardHeader.name.text = data[indexPath.item].name.formatName()
		cell.tutorCardHeader.reviewLabel.text = data[indexPath.item].reviews?.count.formatReviewLabel(rating: data[indexPath.item].tRating)

		let title = (CurrentUser.shared.learner.connectedTutors.contains(data[indexPath.item].uid)) ? "Message" : "Connect"
		cell.connectButton.setTitle(title, for: .normal)
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if featuredTutors.count > 0 {
			guard !allTutorsQueried else { return }
			if indexPath.item == self.datasource.count - 2 && !didLoadMore {
				self.didLoadMore = true
				pageMoreTutors()
			}
		}
	}
	
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 20
        return CGSize(width: width, height: collectionView.frame.height * 0.98)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 20
    }
	func pageMoreTutors() {
		queryTutorsUidsByCategory(lastKnownKey: datasource[datasource.endIndex - 1].uid)
		self.didLoadMore = false
	}
}

extension TutorConnectVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        navigationController?.popOrPushSearchSubjects()
    }
}
