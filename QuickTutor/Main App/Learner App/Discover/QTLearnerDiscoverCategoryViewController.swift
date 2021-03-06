//
//  QTLearnerDiscoverCategoryViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 10/2/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import MXParallaxHeader

class QTLearnerDiscoverCategoryViewController: UIViewController {
    
    var category: Category!
    
    @IBOutlet weak var constraintTitleViewTop: NSLayoutConstraint!
    @IBOutlet var viewTitle: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!    
    @IBOutlet weak var btnTitle: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var aryTrendingTopics: [String] = []
    private var arySubcategories: [String] = []
    private var shouldHideRecentlyActive = false
    
    private var page = 0
    private var _observing = false
    private var shouldLoadMore: Bool = true
    
    private var popRecognizer: QTInteractivePopRecognizer?
    
    private let refreshCtrl = UIRefreshControl()
    
    private var currentSectionCount: Int {
        return 6 + page * QTLearnerDiscoverService.shared.MAX_API_LIMIT
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.estimatedRowHeight = 500
        tableView.estimatedSectionHeaderHeight = 100
        
        tableView.register(QTLearnerDiscoverTopTopicsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscoverTopSubcategoriesTableViewCell")
        tableView.register(QTLearnerDiscoverTutorsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscover\(category.mainPageData.name.capitalized)TableViewCell")
        tableView.register(QTLearnerDiscoverTrendingTopicsTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverTrendingTopicsTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverTutorsTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverTutorsTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverForYouTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverForYouTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverRecentlyActiveTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverRecentlyActiveTableViewCell.reuseIdentifier)
        
        arySubcategories = category.subcategory.subcategories.map({ $0.title })
        for subcategory in arySubcategories {
            tableView.register(QTLearnerDiscoverTutorsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscover\(subcategory.replacingOccurrences(of: " ", with: ""))1TableViewCell")
            tableView.register(QTLearnerDiscoverTutorsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscover\(subcategory.replacingOccurrences(of: " ", with: ""))2TableViewCell")
        }
        tableView.register(QTLoadMoreTableViewCell.nib, forCellReuseIdentifier: QTLoadMoreTableViewCell.reuseIdentifier)
        
        refreshCtrl.tintColor = Colors.purple
        refreshCtrl.addTarget(self, action: #selector(onRefreshDiscover), for: .valueChanged)
        tableView.refreshControl = refreshCtrl
        
        btnTitle.setTitle(category.mainPageData.displayName, for: .normal)
        btnTitle.superview?.superview?.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.5, offset: CGSize(width: 0, height: 1), radius: 2)
        viewNavigationBar.superview?.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.2, offset: CGSize(width: 0, height: 2), radius: 2)
        
        constraintTitleViewTop.constant = UIApplication.shared.statusBarFrame.height + 8
        
        setupParallaxHeader()
        
        getTopExperts()
        getTrendingTopics()
        setInteractiveRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        updateNavigationBar()
        
        tableView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        
        QTLearnerDiscoverService.shared.category = category
        QTLearnerDiscoverService.shared.subcategory = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tableView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        updateNavigationBar()
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = QTInteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipe(sender:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    private func updateNavigationBar() {
        let imageHeight: CGFloat = 380
        let alpha = (min(0, tableView.contentOffset.y) + imageHeight) / imageHeight
        viewNavigationBar.backgroundColor = Colors.newNavigationBarBackground.withAlphaComponent(alpha)
    }
    
    private func getTopExperts() {
        if QTLearnerDiscoverService.shared.sectionTutors.contains(where: { .category == $0.type && category.mainPageData.name == $0.key }) { return }
        
        TutorSearchService.shared.getTutorsByCategory(self.category.mainPageData.name, lastKnownKey: nil) { tutors, loadedAllTutors  in
            let aryTutors = TutorSearchService.shared.sortTutors(tutors: tutors ?? [], category: self.category.mainPageData.name, subcategory: nil)
            QTLearnerDiscoverService.shared.sectionTutors.append(QTLearnerDiscoverTutorSectionInterface(type: .category, key: self.category.mainPageData.name, tutors: aryTutors, loadedAllTutors: loadedAllTutors))
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }
        }
    }
    
    private func getTrendingTopics() {
        FirebaseData.manager.getTrendingTopics(category: category) { topics in
            self.aryTrendingTopics = topics
            
            // get user category topics
            if let interests = CurrentUser.shared.learner.interests {
                self.aryTrendingTopics.append(contentsOf: interests.filter({ self.category.mainPageData.name == SubjectStore.shared.findCategoryBy(subject: $0) && !self.aryTrendingTopics.contains($0) }))
            }
            
            if 10 > self.aryTrendingTopics.count {
                let subcategories = self.category.subcategory.subcategories.map({ $0.title })
                while 10 == self.aryTrendingTopics.count {
                    var rndSubcategoryIndex = Int((Float(arc4random()) / Float(UINT32_MAX)) * Float(subcategories.count))
                    if rndSubcategoryIndex >= subcategories.count {
                        rndSubcategoryIndex = subcategories.count - 1
                    }
                    if let subjects = CategoryFactory.shared.getSubjectsFor(subcategoryName: subcategories[rndSubcategoryIndex]) {
                        var rndIndex = Int((Float(arc4random()) / Float(UINT32_MAX)) * Float(subjects.count))
                        if rndIndex >= subjects.count {
                            rndIndex = subjects.count - 1
                        }
                        let rndSubject = subjects[rndIndex]
                        if !self.aryTrendingTopics.contains(rndSubject) {
                            self.aryTrendingTopics.append(rndSubject)
                        }
                    }
                }
            }
            
            self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
        }
    }
    
    private func getTopTutors() {
        let subcategoryPageCount = Int(ceil(Float(arySubcategories.count) / Float(QTLearnerDiscoverService.shared.MAX_API_LIMIT)))
        
        _observing = true
        let tutorsGroup = DispatchGroup()
        // load subcategories
        let startIndex = page * QTLearnerDiscoverService.shared.MAX_API_LIMIT
        var lastIndex = startIndex + QTLearnerDiscoverService.shared.MAX_API_LIMIT
        lastIndex = lastIndex > arySubcategories.count ? arySubcategories.count : lastIndex
        for index in startIndex ..< lastIndex {
            let subcategory = arySubcategories[index]
            if QTLearnerDiscoverService.shared.sectionTutors.contains(where: { .subcategory == $0.type && subcategory == $0.key }) { continue }
            
            tutorsGroup.enter()
            TutorSearchService.shared.getTutorsBySubcategory(subcategory, lastKnownKey: nil) { tutors, loadedAllTutors  in
                let aryTutors = TutorSearchService.shared.sortTutors(tutors: tutors ?? [], category: nil, subcategory: subcategory)
                QTLearnerDiscoverService.shared.sectionTutors.append(QTLearnerDiscoverTutorSectionInterface(type: .subcategory, key: subcategory, tutors: aryTutors, loadedAllTutors: loadedAllTutors))
                tutorsGroup.leave()
            }
        }
        tutorsGroup.notify(queue: .main) {
            self._observing = false
            self.page += 1
            self.shouldLoadMore = subcategoryPageCount * 2 > self.page
            self.tableView.reloadData()
        }
    }
    
    @objc func swipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.right:
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    @IBAction func onClickBtnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickBtnTitle(_ sender: Any) {
        let controller = QTQuickSearchViewController.controller
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: false)
    }
    
    @objc
    private func onRefreshDiscover() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshCtrl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    private func setupParallaxHeader() {
        let headerView = QTTutorDiscoverCategoryParallaxHeaderView.view
        tableView.parallaxHeader.view = headerView
        tableView.parallaxHeader.height = 380
        tableView.parallaxHeader.mode = .fill
        tableView.parallaxHeader.minimumHeight = 0
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.widthAnchor.constraint(equalTo: tableView.widthAnchor, multiplier: 1.0).isActive = true
        
        headerView.setData(category: category)
    }
}

extension QTLearnerDiscoverCategoryViewController: UITableViewDataSource {
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
            case 0: // Subcategories
                let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscoverTopSubcategoriesTableViewCell", for: indexPath) as! QTLearnerDiscoverTopTopicsTableViewCell
                cell.aryTopics = category.subcategory.subcategories.map({ QTLearnerDiscoverTopicInterface(topic: $0.title) })
                cell.topicSettings = QTLearnerDiscoverTopicSettings(font: .qtHeavyFont(size: 14),
                                                                    size: CGSize(width: ceil((UIScreen.main.bounds.width - 50) / 2.5), height: 90))
                cell.constraintCollectionHeight.constant = 90
                cell.didClickTopic = { subcategory in
                    let learnerDiscoverSubcategoryVC = QTLearnerDiscoverSubcategoryViewController(nibName: String(describing: QTLearnerDiscoverSubcategoryViewController.self), bundle: nil)
                    learnerDiscoverSubcategoryVC.category = self.category
                    learnerDiscoverSubcategoryVC.subcategory = subcategory
                    learnerDiscoverSubcategoryVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(learnerDiscoverSubcategoryVC, animated: true)
                }
                
                return cell
            case 1: // Top Experts
                QTLearnerDiscoverService.shared.isRisingTalent = false
                QTLearnerDiscoverService.shared.topTutorsLimit = 25
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscover\(category.mainPageData.name.capitalized)TableViewCell", for: indexPath) as! QTLearnerDiscoverTutorsTableViewCell
                cell.updateDatasource()
                cell.didClickTutor = { tutor in
                    self.openTutorProfileView(tutor)
                }
                let categoryDisplayName = category.mainPageData.displayName
                cell.didClickViewAllTutors = { subject, subcategory, category, tutors, loadedAllTutors in
                    self.openTutorsView(title: categoryDisplayName, category: category, tutors: tutors, loadedAllTutors: loadedAllTutors)
                }
                
                return cell
            case 2: // Trending Topics
                let cell = tableView.dequeueReusableCell(withIdentifier: QTLearnerDiscoverTrendingTopicsTableViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverTrendingTopicsTableViewCell
                cell.setTopics(aryTrendingTopics)
                cell.didClickTopic = { topic in
                    self.openTutorsView(title: topic, subject: topic, tutors: [], loadedAllTutors: false)
                }
                
                return cell
            case 3: // Rising Talent
                QTLearnerDiscoverService.shared.isRisingTalent = true
                QTLearnerDiscoverService.shared.risingTalentLimit = 25
                
                let cell = tableView.dequeueReusableCell(withIdentifier: QTLearnerDiscoverTutorsTableViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverTutorsTableViewCell
                cell.didClickTutor = { tutor in
                    self.openTutorProfileView(tutor)
                }
                cell.didClickViewAllTutors = { subject, subcategory, category, tutors, loadedAllTutors in
                    self.openTutorsView(title: "Rising Talents", tutors: tutors, loadedAllTutors: loadedAllTutors)
                }
                
                return cell
            case 4: // For You
                let cell = tableView.dequeueReusableCell(withIdentifier: QTLearnerDiscoverForYouTableViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverForYouTableViewCell
                cell.didClickTutor = { tutor in
                    self.openTutorProfileView(tutor)
                }
                
                return cell
            case 5: // Recently Active
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
            case 6 ..< 6 + arySubcategories.count: // Subcategories
                QTLearnerDiscoverService.shared.isFirstTop = true
                QTLearnerDiscoverService.shared.isRisingTalent = false
                QTLearnerDiscoverService.shared.topTutorsLimit = nil
                
                let subcategory = arySubcategories[indexPath.section - 6]
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
            default:
                QTLearnerDiscoverService.shared.isFirstTop = false
                QTLearnerDiscoverService.shared.isRisingTalent = false
                QTLearnerDiscoverService.shared.topTutorsLimit = nil
                
                let subcategory = arySubcategories[indexPath.section - (6 + arySubcategories.count)]
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

extension QTLearnerDiscoverCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if 5 == indexPath.section, shouldHideRecentlyActive {
            return 0.1
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if shouldLoadMore,
            section == tableView.numberOfSections - 1 { return nil }
        
        var headerView = Bundle.main.loadNibNamed(String(describing: QTLearnerDiscoverTableSectionHeaderView.self), owner: self, options: nil)?.first as? QTLearnerDiscoverTableSectionHeaderView
        headerView?.iconRisingTalent.superview?.isHidden = true
        switch section {
        case 0:
            headerView?.title = "Subcategories"
        case 1:
            headerView?.title = "Top Experts"
        case 2:
            headerView?.title = "Trending Topics"
        case 3:
            headerView?.title = "Rising Talent"
            headerView?.iconRisingTalent.superview?.isHidden = false
        case 4:
            headerView?.title = "For You"
        case 5:
            if shouldHideRecentlyActive {
                headerView = nil
            } else {
                headerView?.title = "Recently Active"
            }
        case 6 ..< 6 + arySubcategories.count:
            headerView?.title = arySubcategories[section - 6]
        default:
            headerView?.title = arySubcategories[section - (6 + arySubcategories.count)]
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if shouldLoadMore, currentSectionCount == section {
            return 0.1
        } else {
            if 5 == section, shouldHideRecentlyActive {
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

extension QTLearnerDiscoverCategoryViewController: QTLearnerDiscoverRecentlyActiveDelegate {
    func onDidUpdateRecentlyActive(_ tutors: [AWTutor]) {
        if tutors.isEmpty {
            shouldHideRecentlyActive = true
            tableView.reloadSections(IndexSet(integer: 5), with: .automatic)
        }
    }
}
