//
//  CategorySearch.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import CoreLocation
import SkeletonView

struct CategorySelected {
    static var title: String!
}

class CategorySearchVC: UIViewController {
    
    let itemsPerBatch: UInt = 10
    var datasource: [AWTutor] = []
    var filteredDatasource: [AWTutor] = []
    var didLoadMore: Bool = false
    var loadedAllTutors = false
    var category: String!
    var subcategory: String!
    var subject: String!
    var lastKey: String?
    
    private var _observing = false
    
    var searchFilter: SearchFilter? {
        didSet {
            updateFiltersIcon()
        }
    }
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation? {
        didSet {
            if let filter = searchFilter {
                applySearchFilterToDataSource(filter)
            }
        }
    }

    let menuBtn = UIButton(type: .custom)
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Colors.newScreenBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        collectionView.isSkeletonable = true
        return collectionView
    }()

    let emptyBackground: EmptySearchBackground = {
        let view = EmptySearchBackground()
        view.isHidden = true
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.newScreenBackground
        setupObservers()
        setupLocationManager()
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.bottom.equalTo(view.snp.bottomMargin)
            make.left.equalTo(view.snp.leftMargin)
            make.right.equalTo(view.snp.rightMargin)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TutorCollectionViewCell.self, forCellWithReuseIdentifier: TutorCollectionViewCell.reuseIdentifier)
        collectionView.register(TutorLoadMoreCollectionViewCell.self, forCellWithReuseIdentifier: TutorLoadMoreCollectionViewCell.reuseIdentifier)
        
        navigationController?.navigationBar.isHidden = false
        setUpFiltersButton()
        
        print("=== Prepare Skeleton Start === ")
        print(Date().description)
        if 0 == datasource.count {
            collectionView.prepareSkeleton { _ in
                self.view.showAnimatedSkeleton(usingColor: Colors.gray)
                print("=== Prepare Skeleton End === ")
                print(Date().description)
                self.queryNeededTutors(lastKnownKey: nil)
            }
        } else {
            filteredDatasource = datasource
            queryNeededTutors(lastKnownKey: nil)
        }

        setupEmptyBackgroundView()
    }
    
    func setupEmptyBackgroundView() {
        view.addSubview(emptyBackground)
        emptyBackground.anchor(top: collectionView.topAnchor, left: collectionView.leftAnchor, bottom: collectionView.bottomAnchor, right: collectionView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        view.bringSubviewToFront(emptyBackground)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        hideTabBar(hidden: true)
        guard let filter = self.searchFilter, self.datasource.count > 0 else {
            return
        }
        self.applySearchFilterToDataSource(filter)
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideTabBar(hidden: false)
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.reloadData()
    }
    
    func setUpFiltersButton(){
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 18, height: 18)
        updateFiltersIcon()
        menuBtn.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 18)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 18)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
    }

    private func updateFiltersIcon() {
        if searchFilter != nil {
            menuBtn.setImage(UIImage(named:"filtersAppliedIcon"), for: .normal)
        } else {
            menuBtn.setImage(UIImage(named:"filterIcon"), for: .normal)
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateFilters(_:)), name: NotificationNames.QuickSearch.updatedFilters, object: nil)
    }
    
    @objc func updateFilters(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let filter = userInfo["filter"] as? SearchFilter else { return }
        self.searchFilter = filter
    }
    
    @objc func showFilters() {
        let vc = FiltersVC()
        vc.searchFilter = searchFilter
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func queryNeededTutors(lastKnownKey: String?) {
        guard !loadedAllTutors else { return }
        print(subject)
        if category != nil {
            queryTutorsByCategory(lastKnownKey: lastKnownKey)
        } else if subcategory != nil {
            print("=== Search start ====")
            print(Date().description)
            queryTutorsBySubcategory(lastKnownKey: lastKnownKey)
        } else if subject != nil {
            queryTutorsBySubject(lastKnownKey: lastKnownKey)
        }
    }
    
    private func queryTutorsByCategory(lastKnownKey: String?) {
        _observing = true
        TutorSearchService.shared.getTutorsByCategory(category, lastKnownKey: lastKnownKey) { (tutors, loadedAllTutors) in
            self._observing = false
            self.view.hideSkeleton()
            
            guard let tutors = tutors else {
                self.emptyBackground.isHidden = false
                return
            }
            
            self.emptyBackground.isHidden = true
            
            self.lastKey = tutors.last?.uid
            self.loadedAllTutors = loadedAllTutors
            self.datasource.append(contentsOf: tutors)
            self.datasource = self.datasource.sorted() { tutor1, tutor2 -> Bool in
                let categoryReviews1 = tutor1.categoryReviews(self.category).count
                let categoryReviews2 = tutor2.categoryReviews(self.category).count
                return categoryReviews1 > categoryReviews2
                    || (categoryReviews1 == categoryReviews2 && (tutor1.reviews?.count ?? 0) > (tutor2.reviews?.count ?? 0))
                    || (categoryReviews1 == categoryReviews2 && tutor1.reviews?.count == tutor2.reviews?.count && (tutor1.rating ?? 0) > (tutor2.rating ?? 0))
            }
            self.filteredDatasource = self.datasource
            if let filter = self.searchFilter, self.datasource.count > 0 {
                self.applySearchFilterToDataSource(filter)
            }
            self.collectionView.reloadData()
        }
    }
    
    private func queryTutorsBySubcategory(lastKnownKey: String?) {
        _observing = true        
        TutorSearchService.shared.getTutorsBySubcategory(subcategory, lastKnownKey: lastKnownKey) { (tutors, loadedAllTutors) in
            self._observing = false
            self.view.hideSkeleton()
            
            guard let tutors = tutors else {
                self.emptyBackground.isHidden = false
                return
            }
            
            self.emptyBackground.isHidden = true
            
            self.lastKey = tutors.last?.uid
            self.loadedAllTutors = loadedAllTutors
            self.datasource.append(contentsOf: tutors)
            
            self.datasource = self.datasource.sorted() { tutor1, tutor2 -> Bool in
                let subcategoryReviews1 = tutor1.reviews?.filter({ self.subcategory == SubjectStore.shared.findSubCategory(subject: $0.subject) }).count ?? 0
                let subcategoryReviews2 = tutor2.reviews?.filter({ self.subcategory == SubjectStore.shared.findSubCategory(subject: $0.subject) }).count ?? 0
                return subcategoryReviews1 > subcategoryReviews2
                    || (subcategoryReviews1 == subcategoryReviews2 && (tutor1.reviews?.count ?? 0) > (tutor2.reviews?.count ?? 0))
                    || (subcategoryReviews1 == subcategoryReviews2 && tutor1.reviews?.count == tutor2.reviews?.count && (tutor1.rating ?? 0) > (tutor2.rating ?? 0))
            }
            self.filteredDatasource = self.datasource
            if let filter = self.searchFilter, self.datasource.count > 0 {
                self.applySearchFilterToDataSource(filter)
            }
            self.collectionView.reloadData()
            
        }
    }
    
    private func queryTutorsBySubject(lastKnownKey: String?) {
        _observing = true
        TutorSearchService.shared.getTutorsBySubject(subject, lastKnownKey: lastKnownKey) { (tutors, loadedAllTutors) in
            self._observing = false
            self.view.hideSkeleton()
            
            guard let tutors = tutors else {
                self.emptyBackground.isHidden = false
                return
            }
            
            self.emptyBackground.isHidden = true
            self.lastKey = tutors.last?.uid
            self.loadedAllTutors = loadedAllTutors
            
            self.datasource.append(contentsOf: tutors)
            self.datasource = self.datasource.sorted() { tutor1, tutor2 -> Bool in
                let subjectReviews1 = tutor1.reviews?.filter({ $0.subject == self.subject }).count ?? 0
                let subjectReviews2 = tutor2.reviews?.filter({ $0.subject == self.subject }).count ?? 0
                return subjectReviews1 > subjectReviews2
                    || (subjectReviews1 == subjectReviews2 && (tutor1.reviews?.count ?? 0) > (tutor2.reviews?.count ?? 0))
                    || (subjectReviews1 == subjectReviews2 && tutor1.reviews?.count == tutor1.reviews?.count && (tutor1.rating ?? 0) > (tutor2.rating ?? 0))
            }
            self.filteredDatasource = self.datasource
            if let filter = self.searchFilter, self.datasource.count > 0 {
                self.applySearchFilterToDataSource(filter)
            }
            self.collectionView.reloadData()
        }
    }
    
    private func applySearchFilterToDataSource(_ filter: SearchFilter) {
        filteredDatasource = datasource.filter({ (tutor) -> Bool in
            var shouldBeIncluded = true
            if let minHourlyRate = filter.minHourlyRate {
                shouldBeIncluded = tutor.price >= minHourlyRate
            }
            guard shouldBeIncluded else { return shouldBeIncluded }
            if let maxHourlyRate = filter.maxHourlyRate {
                shouldBeIncluded = tutor.price <= maxHourlyRate
            }
            guard shouldBeIncluded else { return shouldBeIncluded }
            if let ratingType = filter.ratingType {
                if ratingType == 0 {
                    shouldBeIncluded = tutor.tRating >= 5.0
                } else if ratingType == 1 {
                    shouldBeIncluded = tutor.tRating >= 4.0
                }
            }
            guard shouldBeIncluded else { return shouldBeIncluded }
            guard filter.sessionType == 1 else { return shouldBeIncluded }
            
            if let minDistance = filter.minDistance {
                let distance = findDistance(location: tutor.location)
                shouldBeIncluded = distance >= Double(minDistance)
            }
            guard shouldBeIncluded else { return shouldBeIncluded }
            if let maxDistance = filter.maxDistance {
                let distance = findDistance(location: tutor.location)
                shouldBeIncluded = distance <= Double(maxDistance)
            }
            return shouldBeIncluded
        })
    }

}

extension CategorySearchVC: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return TutorCollectionViewCell.reuseIdentifier
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return filteredDatasource.count + (self.loadedAllTutors ? 0 : 1)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if filteredDatasource.count == indexPath.row {
            if !_observing {
                queryNeededTutors(lastKnownKey: lastKey)
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TutorLoadMoreCollectionViewCell.reuseIdentifier, for: indexPath)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TutorCollectionViewCell.reuseIdentifier, for: indexPath) as! TutorCollectionViewCell
            cell.updateUI(filteredDatasource[indexPath.item])
            cell.profileImageViewHeightAnchor?.constant = 160
            cell.layoutIfNeeded()
            return cell
        }
    }
}

extension CategorySearchVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screen = UIScreen.main.bounds
        return CGSize(width: (screen.width - 60) / 2, height: 225)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

extension CategorySearchVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TutorCollectionViewCell else {
            return
        }
        
        cell.shrink()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TutorCollectionViewCell else {
            return
        }
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform.identity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TutorCollectionViewCell else {
            return
        }
        cell.growSemiShrink {
            guard self.filteredDatasource.count > indexPath.item else { return }
            
            let featuredTutor = self.filteredDatasource[indexPath.item]
            let uid = featuredTutor.uid
            FirebaseData.manager.fetchTutor(uid!, isQuery: false, { (tutor) in
                guard let tutor = tutor else { return }
                let controller = QTProfileViewController.controller//TutorCardVC()
                controller.subject = featuredTutor.featuredSubject
                controller.profileViewType = .tutor
                controller.user = tutor
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            })
        }
    }
}

extension CategorySearchVC: UISearchBarDelegate {
    internal func searchBarTextDidBeginEditing(_: UISearchBar) {
        navigationController?.pushViewController(QuickSearchVC(), animated: true)
    }
}

extension CategorySearchVC: CLLocationManagerDelegate {
    
    func findDistance(location: TutorLocation?) -> Double {
        guard let tutorLocation = location?.location else {
            return 0
        }
        
        let currentDistance = currentLocation?.distance(from: tutorLocation) ?? 0
        return currentDistance * 0.00062137
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.currentLocation = location
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
