//
//  QTLearnerDiscoverViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTLearnerDiscoverViewController: UIViewController {
    
    @IBOutlet var viewTitle: UIView!
    @IBOutlet weak var constraintTitleViewTop: NSLayoutConstraint!
    @IBOutlet weak var viewNavigationBar: UIView!
    
    @IBOutlet weak var constraintRecentSearchCollectionTop: NSLayoutConstraint!
    @IBOutlet weak var cltRecentSearch: UICollectionView!
        
    @IBOutlet weak var tableView: UITableView!
    
    private var itemSave: UIBarButtonItem!
    private let refreshCtrl = UIRefreshControl()
    
    private var arySubcategories: [String] = []
    private var shouldHideRecentlyActive = false
    
    private var page = 0
    private var _observing = false
    private var shouldLoadMore: Bool = true
        
    private var currentSectionCount: Int {
        return 8 + page * QTLearnerDiscoverService.shared.MAX_API_LIMIT
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.estimatedRowHeight = 500        
        tableView.estimatedSectionHeaderHeight = 100
        
        tableView.register(QTLearnerDiscoverTrendingTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverTrendingTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverCategoriesTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverCategoriesTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverTutorsTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverTutorsTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverForYouTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverForYouTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverRecentlyActiveTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverRecentlyActiveTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverTopTopicsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscoverInPersonTopicsTableViewCell")
        tableView.register(QTLearnerDiscoverTopTopicsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscoverRecommendedTopicsTableViewCell")
        tableView.register(QTLearnerDiscoverTopTopicsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscoverOnlineTopicsTableViewCell")
        for category in Category.categories {
            tableView.register(QTLearnerDiscoverTutorsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscover\(category.mainPageData.name.capitalized)1TableViewCell")
            tableView.register(QTLearnerDiscoverTutorsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscover\(category.mainPageData.name.capitalized)2TableViewCell")
        }
        
        for category in Category.categories {
            arySubcategories.append(contentsOf: category.subcategory.subcategories.map({ $0.title }))
        }
        for subcategory in arySubcategories {
            tableView.register(QTLearnerDiscoverTutorsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscover\(subcategory.replacingOccurrences(of: " ", with: ""))1TableViewCell")
            tableView.register(QTLearnerDiscoverTutorsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscover\(subcategory.replacingOccurrences(of: " ", with: ""))2TableViewCell")
        }
        tableView.register(QTLoadMoreTableViewCell.nib, forCellReuseIdentifier: QTLoadMoreTableViewCell.reuseIdentifier)
        
        viewTitle.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.5, offset: CGSize(width: 0, height: 1), radius: 2)
        viewNavigationBar.superview?.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.2, offset: CGSize(width: 0, height: 2), radius: 2)
        
        constraintTitleViewTop.constant = UIApplication.shared.statusBarFrame.height + 8
        
        refreshCtrl.tintColor = Colors.purple
        refreshCtrl.addTarget(self, action: #selector(onRefreshDiscover), for: .valueChanged)
        tableView.refreshControl = refreshCtrl
        
        cltRecentSearch.register(QTLearnerDiscoverTrendingTopicCollectionViewCell.nib, forCellWithReuseIdentifier: QTLearnerDiscoverTrendingTopicCollectionViewCell.reuseIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdatedRecentSearch), name: NotificationNames.LearnerMainFeed.searchesLoaded, object: nil)
        RecentSearchesManager.shared.fetchSearches()
        addLongPressGestureToRecentSearch()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
        
        QTLearnerDiscoverService.shared.category = nil
        QTLearnerDiscoverService.shared.subcategory = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tableView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if RecentSearchesManager.shared.searches.isEmpty { return }
        
        let changeValues = change! as [NSKeyValueChangeKey: AnyObject]
        
        if let new = changeValues[.newKey]?.cgPointValue,
            let old = changeValues[.oldKey]?.cgPointValue {
            
            let diff = old.y - new.y
            
            if 0 > new.y || new.y + tableView.frame.size.height > tableView.contentSize.height { return }
            
            if 0 < diff {
                if 0 == constraintRecentSearchCollectionTop.constant { return }
                constraintRecentSearchCollectionTop.constant = min(0, constraintRecentSearchCollectionTop.constant + diff)
            } else {
                if -40 == constraintRecentSearchCollectionTop.constant { return }
                constraintRecentSearchCollectionTop.constant = max(-40, constraintRecentSearchCollectionTop.constant + diff)
            }
        }
        
    }
    
    private func getTopTutors() {
        let categoryPageCount = Int(ceil(Float(Category.categories.count) / Float(QTLearnerDiscoverService.shared.MAX_API_LIMIT)))
        let subcategoryPageCount = Int(ceil(Float(arySubcategories.count) / Float(QTLearnerDiscoverService.shared.MAX_API_LIMIT)))
        
        _observing = true
        let tutorsGroup = DispatchGroup()
        if 1 < page {   // 0, 1 pages are categories
            // load subcategories
            let startIndex = (page - categoryPageCount) * QTLearnerDiscoverService.shared.MAX_API_LIMIT
            var lastIndex = startIndex + QTLearnerDiscoverService.shared.MAX_API_LIMIT
            lastIndex = lastIndex > arySubcategories.count ? arySubcategories.count : lastIndex
            for index in startIndex ..< lastIndex {
                let subcategory = arySubcategories[index]
                if QTLearnerDiscoverService.shared.sectionTutors.contains(where: { .subcategory == $0.type && subcategory == $0.key }) { continue }
                
                tutorsGroup.enter()
                TutorSearchService.shared.getTutorIdsBySubcategory(subcategory) { tutorIds in
                    TutorSearchService.shared.getTutorsBySubcategory(subcategory, lastKnownKey: nil, queue: .global(qos: .userInitiated)) { tutors, loadedAllTutors  in
                        let aryTutors = tutors?.sorted() { tutor1, tutor2 in
                            let subcategoryReviews1 = tutor1.reviews?.filter({ subcategory == SubjectStore.shared.findSubCategory(subject: $0.subject) }).count ?? 0
                            let subcategoryReviews2 = tutor2.reviews?.filter({ subcategory == SubjectStore.shared.findSubCategory(subject: $0.subject) }).count ?? 0
                            return subcategoryReviews1 > subcategoryReviews2
                                || (subcategoryReviews1 == subcategoryReviews2 && (tutor1.reviews?.count ?? 0) > (tutor2.reviews?.count ?? 0))
                                || (subcategoryReviews1 == subcategoryReviews2 && tutor1.reviews?.count == tutor2.reviews?.count && (tutor1.rating ?? 0) > (tutor2.rating ?? 0))
                        }
                        QTLearnerDiscoverService.shared.sectionTutors.append(QTLearnerDiscoverTutorSectionInterface(type: .subcategory, key: subcategory, tutors: aryTutors, totalTutorIds: tutorIds))
                        tutorsGroup.leave()
                    }
                }
            }
        } else {
            // load categories
            let startIndex = page * QTLearnerDiscoverService.shared.MAX_API_LIMIT
            var lastIndex = startIndex + QTLearnerDiscoverService.shared.MAX_API_LIMIT
            lastIndex = lastIndex > Category.categories.count ? Category.categories.count : lastIndex
            for index in startIndex ..< lastIndex {
                let category = Category.categories[index]
                if QTLearnerDiscoverService.shared.sectionTutors.contains(where: { .category == $0.type && category.mainPageData.name == $0.key }) { continue }
                
                tutorsGroup.enter()
                TutorSearchService.shared.getTutorIdsByCategory(category.mainPageData.name) { tutorIds in
                    TutorSearchService.shared.getTutorsByCategory(category.mainPageData.name, lastKnownKey: nil, queue: .global(qos: .userInitiated)) { tutors, loadedAllTutors  in
                        
                        let aryTutors = tutors?.sorted() { tutor1, tutor2 in
                            let categoryReviews1 = tutor1.categoryReviews(category.mainPageData.name).count
                            let categoryReviews2 = tutor2.categoryReviews(category.mainPageData.name).count
                            return categoryReviews1 > categoryReviews2
                                || (categoryReviews1 == categoryReviews2 && (tutor1.reviews?.count ?? 0) > (tutor2.reviews?.count ?? 0))
                                || (categoryReviews1 == categoryReviews2 && tutor1.reviews?.count == tutor2.reviews?.count && (tutor1.rating ?? 0) > (tutor2.rating ?? 0))
                        }
                        QTLearnerDiscoverService.shared.sectionTutors.append(QTLearnerDiscoverTutorSectionInterface(type: .category, key: category.mainPageData.name, tutors: aryTutors, totalTutorIds: tutorIds))
                        tutorsGroup.leave()
                    }
                }
            }
        }
        tutorsGroup.notify(queue: .main) {
            self._observing = false
            self.page += 1
            self.shouldLoadMore = (categoryPageCount + subcategoryPageCount) * 2 > self.page
            self.tableView.reloadData()
        }
    }
    
    @IBAction func onClickBtnSearch(_ sender: Any) {
        let controller = QTQuickSearchViewController.controller
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func onClickBtnSave() {
        let savedVC = QTSavedTutorsViewController()
        savedVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(savedVC, animated: true)
    }
    
    @objc
    private func onRefreshDiscover() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshCtrl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    @objc
    private func onUpdatedRecentSearch() {
        constraintRecentSearchCollectionTop.constant = RecentSearchesManager.shared.searches.isEmpty ? -40 : 0
        cltRecentSearch.reloadData()
    }
    
}

extension QTLearnerDiscoverViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if shouldLoadMore {
            return currentSectionCount + 1
        } else {
            return currentSectionCount
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        QTLearnerDiscoverService.shared.category = nil
        QTLearnerDiscoverService.shared.subcategory = nil
        
        if shouldLoadMore,
            indexPath.section == tableView.numberOfSections - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: QTLoadMoreTableViewCell.reuseIdentifier, for: indexPath) as! QTLoadMoreTableViewCell
            cell.activityIndicator.startAnimating()
            
            if !_observing {
                getTopTutors()
            }
            
            return cell
        } else {
            switch indexPath.section {
            case 0: // News
                let cell = tableView.dequeueReusableCell(withIdentifier: QTLearnerDiscoverTrendingTableViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverTrendingTableViewCell
                cell.didClickTrending = { trending in
                    var title = ""
                    if let subject = trending.subject {
                        title = subject
                    } else if let subcategory = trending.subcategoryTitle {
                        title = subcategory
                    } else if let category = trending.categoryTitle {
                        title = category
                    }
                    
                    self.openTutorsView(title: title, subject: trending.subject, subcategory: trending.subcategoryTitle, category: trending.categoryTitle, tutors: [], loadedAllTutors: false)
                }
                
                return cell
            case 1: // Categories
                let cell = tableView.dequeueReusableCell(withIdentifier: QTLearnerDiscoverCategoriesTableViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverCategoriesTableViewCell
                cell.didSelectCategory = { category in
                    let learnerDiscoverCategoryVC = QTLearnerDiscoverCategoryViewController(nibName: String(describing: QTLearnerDiscoverCategoryViewController.self), bundle: nil)
                    learnerDiscoverCategoryVC.category = category
                    learnerDiscoverCategoryVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(learnerDiscoverCategoryVC, animated: true)
                }
                
                return cell
            case 2: // Rising Talent
                QTLearnerDiscoverService.shared.isRisingTalent = true
                QTLearnerDiscoverService.shared.risingTalentLimit = 50
                
                let cell = tableView.dequeueReusableCell(withIdentifier: QTLearnerDiscoverTutorsTableViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverTutorsTableViewCell
                cell.didClickTutor = { tutor in
                    self.openTutorProfileView(tutor)
                }
                cell.didClickViewAllTutors = { subject, subcategory, category, tutors, loadedAllTutors in
                    self.openTutorsView(title: "Rising Talents", tutors: tutors, loadedAllTutors: loadedAllTutors)
                }
                
                return cell
            case 3: // For You
                let cell = tableView.dequeueReusableCell(withIdentifier: QTLearnerDiscoverForYouTableViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverForYouTableViewCell
                cell.didClickTutor = { tutor in
                    self.openTutorProfileView(tutor)
                }
                
                return cell
            case 4: // Recently Active
                let cell = tableView.dequeueReusableCell(withIdentifier: QTLearnerDiscoverRecentlyActiveTableViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverRecentlyActiveTableViewCell
                cell.delegate = self
                cell.didClickTutor = { tutor in
                    self.openTutorProfileView(tutor)
                }
                cell.didClickBtnMessage = { tutor in
                    let vc = ConversationVC()
                    vc.receiverId = tutor.uid
                    vc.chatPartner = tutor
                    vc.connectionRequestAccepted = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                return cell
            case 5: // Top In-Person Topics
                let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscoverInPersonTopicsTableViewCell", for: indexPath) as! QTLearnerDiscoverTopTopicsTableViewCell
                cell.aryTopics = QTLearnerDiscoverTopicType.inperson.topics
                cell.topicSettings = QTLearnerDiscoverTopicType.inperson.settings
                cell.didClickTopic = { topic in
                    self.openTutorsView(title: topic, subject: topic, tutors: [], loadedAllTutors: false)
                }
                
                return cell
            case 6: // Recommended
                let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscoverRecommendedTopicsTableViewCell", for: indexPath) as! QTLearnerDiscoverTopTopicsTableViewCell
                cell.aryTopics = QTLearnerDiscoverTopicType.recommended.topics
                cell.topicSettings = QTLearnerDiscoverTopicType.recommended.settings
                cell.didClickTopic = { topic in
                    self.openTutorsView(title: topic, subject: topic, tutors: [], loadedAllTutors: false)
                }
                
                return cell
            case 7: // Top Online Topics
                let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscoverOnlineTopicsTableViewCell", for: indexPath) as! QTLearnerDiscoverTopTopicsTableViewCell
                cell.aryTopics = QTLearnerDiscoverTopicType.online.topics
                cell.topicSettings = QTLearnerDiscoverTopicType.online.settings
                cell.didClickTopic = { topic in
                    self.openTutorsView(title: topic, subject: topic, tutors: [], loadedAllTutors: false)
                }
                
                return cell
            case 8 ..< 8 + Category.categories.count: // Category Tutors
                QTLearnerDiscoverService.shared.isRisingTalent = false
                QTLearnerDiscoverService.shared.isFirstTop = true
                QTLearnerDiscoverService.shared.topTutorsLimit = nil
                
                let category = Category.categories[indexPath.section - 8]
                QTLearnerDiscoverService.shared.category = category
                let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscover\(category.mainPageData.name.capitalized)1TableViewCell", for: indexPath) as! QTLearnerDiscoverTutorsTableViewCell
                cell.updateDatasource()
                cell.didClickTutor = { tutor in
                    self.openTutorProfileView(tutor)
                }
                
                let categoryDisplayName = category.mainPageData.displayName
                cell.didClickViewAllTutors = { subject, subcategory, category, tutors, loadedAllTutors in
                    self.openTutorsView(title: categoryDisplayName, subject: subject, subcategory: subcategory, category: category, tutors: tutors, loadedAllTutors: loadedAllTutors)
                }
                
                return cell
            case 8 + Category.categories.count ..< 8 + Category.categories.count + arySubcategories.count:
                QTLearnerDiscoverService.shared.isRisingTalent = false
                QTLearnerDiscoverService.shared.isFirstTop = true
                QTLearnerDiscoverService.shared.topTutorsLimit = nil
                
                let subcategory = arySubcategories[indexPath.section - (8 + Category.categories.count)]
                QTLearnerDiscoverService.shared.subcategory = subcategory
                let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscover\(subcategory.replacingOccurrences(of: " ", with: ""))1TableViewCell", for: indexPath) as! QTLearnerDiscoverTutorsTableViewCell
                cell.updateDatasource()
                cell.didClickTutor = { tutor in
                    self.openTutorProfileView(tutor)
                }
                
                cell.didClickViewAllTutors = { subject, subcategory, category, tutors, loadedAllTutors in
                    self.openTutorsView(title: subcategory ?? "", subject: subject, subcategory: subcategory, category: category, tutors: tutors, loadedAllTutors: loadedAllTutors)
                }
                
                return cell
            case 8 + Category.categories.count + arySubcategories.count ..< 8 + Category.categories.count * 2 + arySubcategories.count: // Category Tutors
                QTLearnerDiscoverService.shared.isRisingTalent = false
                QTLearnerDiscoverService.shared.isFirstTop = false
                QTLearnerDiscoverService.shared.topTutorsLimit = nil
                
                let category = Category.categories[indexPath.section - (8 + Category.categories.count + arySubcategories.count)]
                QTLearnerDiscoverService.shared.category = category
                let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscover\(category.mainPageData.name.capitalized)2TableViewCell", for: indexPath) as! QTLearnerDiscoverTutorsTableViewCell
                cell.updateDatasource()
                cell.didClickTutor = { tutor in
                    self.openTutorProfileView(tutor)
                }
                
                let categoryDisplayName = category.mainPageData.displayName
                cell.didClickViewAllTutors = { subject, subcategory, category, tutors, loadedAllTutors in
                    self.openTutorsView(title: categoryDisplayName, subject: subject, subcategory: subcategory, category: category, tutors: tutors, loadedAllTutors: loadedAllTutors)
                }
                
                return cell
            default:
                QTLearnerDiscoverService.shared.isRisingTalent = false
                QTLearnerDiscoverService.shared.isFirstTop = false
                QTLearnerDiscoverService.shared.topTutorsLimit = nil
                
                let subcategory = arySubcategories[indexPath.section - (8 + Category.categories.count * 2 + arySubcategories.count)]
                QTLearnerDiscoverService.shared.subcategory = subcategory
                let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscover\(subcategory.replacingOccurrences(of: " ", with: ""))2TableViewCell", for: indexPath) as! QTLearnerDiscoverTutorsTableViewCell
                cell.updateDatasource()
                cell.didClickTutor = { tutor in
                    self.openTutorProfileView(tutor)
                }
                
                cell.didClickViewAllTutors = { subject, subcategory, category, tutors, loadedAllTutors in
                    self.openTutorsView(title: subcategory ?? "", subject: subject, subcategory: subcategory, category: category, tutors: tutors, loadedAllTutors: loadedAllTutors)
                }
                
                return cell
            }
        }
    }
    
    private func openTutorProfileView(_ tutor: AWTutor) {
        let controller = QTProfileViewController.controller
        controller.subject = tutor.featuredSubject
        controller.profileViewType = .tutor
        controller.user = tutor
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func openTutorsView(title: String, subject: String? = nil, subcategory: String? = nil, category: String? = nil, tutors: [AWTutor], loadedAllTutors: Bool) {
        let categoryVC = CategorySearchVC()
        categoryVC.datasource = tutors
        categoryVC.loadedAllTutors = loadedAllTutors
        categoryVC.navigationItem.title = title
        categoryVC.subject = subject
        categoryVC.subcategory = subcategory
        categoryVC.category = category
        categoryVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(categoryVC, animated: true)
    }
}

extension QTLearnerDiscoverViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if 4 == indexPath.section, shouldHideRecentlyActive {
            return 0.1
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if shouldLoadMore,
            section == tableView.numberOfSections - 1 { return nil }
        
        var headerView = Bundle.main.loadNibNamed(String(describing: QTLearnerDiscoverTableSectionHeaderView.self), owner: self, options: nil)?.first as? QTLearnerDiscoverTableSectionHeaderView
        switch section {
        case 0:
            headerView?.lblTitle.font = .qtBlackFont(size: 24)
            headerView?.title = "Hi \(CurrentUser.shared.learner.firstName ?? ""), what would you like to learn today?"
        case 1:
            headerView?.title = "Categories"
        case 2:
            headerView?.title = "Rising Talent"
        case 3:
            headerView?.title = "For You"
        case 4:
            if shouldHideRecentlyActive {
                headerView = nil
            } else {
                headerView?.title = "Recently Active"
            }
        case 5:
            headerView?.title = "Top In-Person Topics"
        case 6:
            headerView?.title = "Recommended"
        case 7:
            headerView?.title = "Top Online Topics"
        case 8 ..< 8 + Category.categories.count:
            headerView?.title = Category.categories[section - 8].mainPageData.displayName
        case 8 + Category.categories.count ..< 8 + Category.categories.count + arySubcategories.count:
            headerView?.title = arySubcategories[section - (8 + Category.categories.count)]
        case 8 + Category.categories.count + arySubcategories.count ..< 8 + Category.categories.count * 2 + arySubcategories.count:
            headerView?.title = Category.categories[section - (8 + Category.categories.count + arySubcategories.count)].mainPageData.displayName
        default:
            headerView?.title = arySubcategories[section - (8 + Category.categories.count * 2 + arySubcategories.count)]
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if shouldLoadMore, currentSectionCount == section {
            return 0.1
        } else {
            if 4 == section, shouldHideRecentlyActive {
                return 0.1
            } else {
                return UITableView.automaticDimension
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
}

extension QTLearnerDiscoverViewController {
    private func addLongPressGestureToRecentSearch() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressRecentSearchCollectionView(_:)))
        cltRecentSearch.addGestureRecognizer(longPress)
    }
    
    @objc
    private func onLongPressRecentSearchCollectionView(_ gesture: UILongPressGestureRecognizer) {
        guard let view = gesture.view as? UICollectionView else { return }
        
        let point = gesture.location(in: view)
        guard let indexPath = view.indexPathForItem(at: point) else { return }
        if .began == gesture.state {
            let sheet = UIAlertController(title: "Remove recent search?", message: nil, preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
                RecentSearchesManager.shared.removeSearch(item: indexPath.item)
                view.reloadData()
                if RecentSearchesManager.shared.searches.isEmpty {
                    self.constraintRecentSearchCollectionTop.constant = -40
                }
            })
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(sheet, animated: true, completion: nil)
        }
    }
}

extension QTLearnerDiscoverViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RecentSearchesManager.shared.searches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QTLearnerDiscoverTrendingTopicCollectionViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverTrendingTopicCollectionViewCell
        
        cell.lblTopic.textColor = UIColor(white: 1, alpha: 0.5)
        cell.lblTopic.text = RecentSearchesManager.shared.searches[indexPath.item]
        cell.lblTopic.font = .qtBoldFont(size: 12)
        cell.containerView.backgroundColor = .clear
        cell.containerView.borderWidth = 1
        cell.containerView.borderColor = UIColor(white: 1, alpha: 0.5)
        
        return cell
    }
}

extension QTLearnerDiscoverViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let topic = RecentSearchesManager.shared.searches[indexPath.item]
        let estimatedWidth = topic.estimateFrameForFontSize(12, extendedWidth: true).width + 20
        
        return CGSize(width: estimatedWidth > 50 ? estimatedWidth : 50, height: 24)
    }
}

extension QTLearnerDiscoverViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openTutorsView(title: RecentSearchesManager.shared.searches[indexPath.item], subject: RecentSearchesManager.shared.searches[indexPath.item], tutors: [], loadedAllTutors: false)
    }
}

extension QTLearnerDiscoverViewController: QTLearnerDiscoverRecentlyActiveDelegate {
    func onDidUpdateRecentlyActive(_ tutors: [AWTutor]) {
        if tutors.isEmpty {
            shouldHideRecentlyActive = true
            tableView.reloadSections(IndexSet(integer: 4), with: .automatic)
        }
    }
}
