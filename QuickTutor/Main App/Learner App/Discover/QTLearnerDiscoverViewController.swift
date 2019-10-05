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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.sectionHeaderHeight = UITableView.automaticDimension
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
            tableView.register(QTLearnerDiscoverTutorsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscover\(category.mainPageData.name.capitalized)TableViewCell")
        }
        
        for category in Category.categories {
            arySubcategories.append(contentsOf: category.subcategory.subcategories.map({ $0.title }))
        }
        for subcategory in arySubcategories {
            tableView.register(QTLearnerDiscoverTutorsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscover\(subcategory.replacingOccurrences(of: " ", with: ""))TableViewCell")
        }
        
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
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.isUserInteractionEnabled = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        
        tableView.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
        
        QTLearnerDiscoverService.shared.category = nil
        QTLearnerDiscoverService.shared.subcategory = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        navigationController?.isNavigationBarHidden = true
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
            
            if 0 > new.y { return }
            
            let diff = old.y - new.y
            
            if 0 < diff {
                constraintRecentSearchCollectionTop.constant = min(0, constraintRecentSearchCollectionTop.constant + diff)
            } else {
                constraintRecentSearchCollectionTop.constant = max(-40, constraintRecentSearchCollectionTop.constant + diff)
            }
        }
        
    }
    
    @IBAction func onClickBtnSearch(_ sender: Any) {
        let controller = QTQuickSearchViewController.controller
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func onClickBtnSave() {
        let savedVC = SavedTutorsVC()
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
        return 8 + Category.categories.count + arySubcategories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        QTLearnerDiscoverService.shared.category = nil
        QTLearnerDiscoverService.shared.subcategory = nil
        QTLearnerDiscoverService.shared.isRisingTalent = false
        
        QTLearnerDiscoverService.shared.topTutorsLimit = nil
        QTLearnerDiscoverService.shared.risingTalentLimit = 50
        
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
            let category = Category.categories[indexPath.section - 8]
            QTLearnerDiscoverService.shared.category = category
            let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscover\(category.mainPageData.name.capitalized)TableViewCell", for: indexPath) as! QTLearnerDiscoverTutorsTableViewCell
            cell.didClickTutor = { tutor in
                self.openTutorProfileView(tutor)
            }
            
            let categoryDisplayName = category.mainPageData.displayName
            cell.didClickViewAllTutors = { subject, subcategory, category, tutors, loadedAllTutors in
                self.openTutorsView(title: categoryDisplayName, subject: subject, subcategory: subcategory, category: category, tutors: tutors, loadedAllTutors: loadedAllTutors)
            }
            
            return cell
        default:
            let subcategory = arySubcategories[indexPath.section - (8 + Category.categories.count)]
            QTLearnerDiscoverService.shared.subcategory = subcategory
            let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscover\(subcategory.replacingOccurrences(of: " ", with: ""))TableViewCell", for: indexPath) as! QTLearnerDiscoverTutorsTableViewCell
            cell.didClickTutor = { tutor in
                self.openTutorProfileView(tutor)
            }
            
            cell.didClickViewAllTutors = { subject, subcategory, category, tutors, loadedAllTutors in
                self.openTutorsView(title: subcategory ?? "", subject: subject, subcategory: subcategory, category: category, tutors: tutors, loadedAllTutors: loadedAllTutors)
            }
            
            return cell
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
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed(String(describing: QTLearnerDiscoverTableSectionHeaderView.self), owner: self, options: nil)?.first as? QTLearnerDiscoverTableSectionHeaderView
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
            headerView?.title = "Recently Active"
        case 5:
            headerView?.title = "Top In-Person Topics"
        case 6:
            headerView?.title = "Recommended"
        case 7:
            headerView?.title = "Top Online Topics"
        case 8 ..< 8 + Category.categories.count:
            headerView?.title = Category.categories[section - 8].mainPageData.displayName
        default:
            headerView?.title = arySubcategories[section - (8 + Category.categories.count)]
        }
        
        return headerView
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
