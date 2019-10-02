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
    
    @IBOutlet weak var btnBack: UIButton!
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
        
        tableView.register(QTLearnerDiscoverTopTopicsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscoverTopSubcategoriesTableViewCell")
        tableView.register(QTLearnerDiscoverTutorsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscoverCategoryTopExpertsTableViewCell")
        tableView.register(QTLearnerDiscoverTrendingTopicsTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverTrendingTopicsTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverTutorsTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverTutorsTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverForYouTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverForYouTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverRecentlyActiveTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverRecentlyActiveTableViewCell.reuseIdentifier)
        
        refreshCtrl.tintColor = Colors.purple
        refreshCtrl.addTarget(self, action: #selector(onRefreshDiscover), for: .valueChanged)
        tableView.refreshControl = refreshCtrl
        
        btnBack.setTitle(category.mainPageData.displayName, for: .normal)
        btnBack.superview?.superview?.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.5, offset: CGSize(width: 0, height: 1), radius: 2)
        
        setupParallaxHeader()
        getTrendingTopics()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }

    @IBAction func onClickBtnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
        
        headerView.setData(category: category)
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
                    let rndSubcategoryIndex = Int((Float(arc4random()) / Float(UINT32_MAX)) * Float(subcategories.count))
                    if let subjects = CategoryFactory.shared.getSubjectsFor(subcategoryName: subcategories[rndSubcategoryIndex]) {
                        let rndIndex = Int((Float(arc4random()) / Float(UINT32_MAX)) * Float(subjects.count))
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
}

extension QTLearnerDiscoverCategoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscoverCategoryTopExpertsTableViewCell", for: indexPath) as! QTLearnerDiscoverTutorsTableViewCell
            cell.setView(category: category)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: QTLearnerDiscoverTutorsTableViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverTutorsTableViewCell
            cell.setView(category: category, isRisingTalent: true)
            cell.didClickTutor = { tutor in
                self.openTutorProfileView(tutor)
            }
            cell.didClickViewAllTutors = { subject, subcategory, category, tutors, loadedAllTutors in
                self.openTutorsView(title: "Rising Talents", tutors: tutors, loadedAllTutors: loadedAllTutors)
            }
            
            return cell
        case 4: // For You
            let cell = tableView.dequeueReusableCell(withIdentifier: QTLearnerDiscoverForYouTableViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverForYouTableViewCell
            cell.setView(category: category)
            cell.didClickTutor = { tutor in
                self.openTutorProfileView(tutor)
            }
                        
            return cell
        case 5: // Recently Active
            let cell = tableView.dequeueReusableCell(withIdentifier: QTLearnerDiscoverRecentlyActiveTableViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverRecentlyActiveTableViewCell
            cell.setView(category: category)
            cell.didClickTutor = { tutor in
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

extension QTLearnerDiscoverCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed(String(describing: QTLearnerDiscoverTableSectionHeaderView.self), owner: self, options: nil)?.first as? QTLearnerDiscoverTableSectionHeaderView
        switch section {
        case 0:
            headerView?.title = "Subcategories"
        case 1:
            headerView?.title = "Top Experts"
        case 2:
            headerView?.title = "Trending Topics"
        case 3:
            headerView?.title = "Rising Talent"
        case 4:
            headerView?.title = "For You"
        case 5:
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
