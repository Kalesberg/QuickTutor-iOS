//
//  QTLearnerDiscoverSubcategoryViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 10/2/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import MXParallaxHeader

class QTLearnerDiscoverSubcategoryViewController: UIViewController {

    var category: Category!
    var subcategory: String!
    
    @IBOutlet weak var constraintTitleViewTop: NSLayoutConstraint!
    @IBOutlet var viewTitle: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!    
    @IBOutlet weak var btnTitle: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var aryTrendingTopics: [String] = []
    private let refreshCtrl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 100
        
        tableView.register(QTLearnerDiscoverTrendingTopicsTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverTrendingTopicsTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverTutorsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscover\(category.mainPageData.name.capitalized)TableViewCell")
        tableView.register(QTLearnerDiscoverTutorsTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverTutorsTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverForYouTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverForYouTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverRecentlyActiveTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverRecentlyActiveTableViewCell.reuseIdentifier)
        
        refreshCtrl.tintColor = Colors.purple
        refreshCtrl.addTarget(self, action: #selector(onRefreshDiscover), for: .valueChanged)
        tableView.refreshControl = refreshCtrl
        
        btnTitle.setTitle("\(category.mainPageData.displayName) • \(subcategory!)", for: .normal)
        btnTitle.superview?.superview?.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.5, offset: CGSize(width: 0, height: 1), radius: 2)
        viewNavigationBar.superview?.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.2, offset: CGSize(width: 0, height: 2), radius: 2)
        
        constraintTitleViewTop.constant = UIApplication.shared.statusBarFrame.height + 8
        
        setupParallaxHeader()
        getTrendingTopics()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        updateNavigationBar()
        
        tableView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        
        QTLearnerDiscoverService.shared.category = nil
        QTLearnerDiscoverService.shared.subcategory = subcategory
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tableView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        updateNavigationBar()
    }
    
    private func updateNavigationBar() {
        let imageHeight: CGFloat = 380
        let alpha = (min(0, tableView.contentOffset.y) + imageHeight) / imageHeight
        viewNavigationBar.backgroundColor = Colors.newNavigationBarBackground.withAlphaComponent(alpha)
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
        
        headerView.bannerImageView.image = UIImage(named: subcategory)
        headerView.categoryNameLabel.text = subcategory
    }
    
    private func getTrendingTopics() {
        FirebaseData.manager.getTrendingTopics(subcategory: subcategory) { topics in
            self.aryTrendingTopics = topics
            
            // get user category topics
            if let interests = CurrentUser.shared.learner.interests {
                self.aryTrendingTopics.append(contentsOf: interests.filter({ self.subcategory == SubjectStore.shared.findSubCategory(subject: $0) && !self.aryTrendingTopics.contains($0) }))
            }
            
            if 10 > self.aryTrendingTopics.count,
                let subjects = CategoryFactory.shared.getSubjectsFor(subcategoryName: self.subcategory) {
                while 10 == self.aryTrendingTopics.count {
                    let rndIndex = Int((Float(arc4random()) / Float(UINT32_MAX)) * Float(subjects.count))
                    let rndSubject = subjects[rndIndex]
                    if !self.aryTrendingTopics.contains(rndSubject) {
                        self.aryTrendingTopics.append(rndSubject)
                    }
                }
            }
            
            self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
        }
    }

}

extension QTLearnerDiscoverSubcategoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        QTLearnerDiscoverService.shared.isRisingTalent = false
        
        QTLearnerDiscoverService.shared.topTutorsLimit = 15
        QTLearnerDiscoverService.shared.risingTalentLimit = 15
        
        switch indexPath.section {
        case 0: // Trending Topics
            let cell = tableView.dequeueReusableCell(withIdentifier: QTLearnerDiscoverTrendingTopicsTableViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverTrendingTopicsTableViewCell
            cell.setTopics(aryTrendingTopics)
            cell.didClickTopic = { topic in
                self.openTutorsView(title: topic, subject: topic, tutors: [], loadedAllTutors: false)
            }
            
            return cell
        case 1: // Top Experts
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
        default: // Category Tutors
            return UITableViewCell(style: .default, reuseIdentifier: "EmptyTableViewCell")
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

extension QTLearnerDiscoverSubcategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed(String(describing: QTLearnerDiscoverTableSectionHeaderView.self), owner: self, options: nil)?.first as? QTLearnerDiscoverTableSectionHeaderView
        switch section {
        case 0:
        headerView?.title = "Trending Topics"
        case 1:
            headerView?.title = "Top Experts"
        case 2:
            headerView?.title = "Rising Talent"
        case 3:
            headerView?.title = "For You"
        case 4:
            headerView?.title = "Recently Active"
        default:
            break
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

}