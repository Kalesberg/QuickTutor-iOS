//
//  QTLearnerDiscoverViewController.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTLearnerDiscoverViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var itemSave: UIBarButtonItem!
    private let refreshCtrl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 100
        
        tableView.register(QTLearnerDiscoverTrendingTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverTrendingTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverCategoriesTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverCategoriesTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverRisingTalentTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverRisingTalentTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverForYouTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverForYouTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverRecentlyActiveTableViewCell.nib, forCellReuseIdentifier: QTLearnerDiscoverRecentlyActiveTableViewCell.reuseIdentifier)
        tableView.register(QTLearnerDiscoverTopTopicsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscoverInPersonTopicsTableViewCell")
        tableView.register(QTLearnerDiscoverTopTopicsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscoverRecommendedTopicsTableViewCell")
        tableView.register(QTLearnerDiscoverTopTopicsTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscoverOnlineTopicsTableViewCell")
        for category in Category.categories {
            tableView.register(QTLearnerDiscoverRisingTalentTableViewCell.nib, forCellReuseIdentifier: "QTLearnerDiscover\(category.mainPageData.name.capitalized)TableViewCell")
        }
        
        itemSave = UIBarButtonItem(image: UIImage(named: "heartIcon"), style: .done, target: self, action: #selector(onTapItemSave))
        navigationItem.rightBarButtonItem = itemSave
        
        refreshCtrl.tintColor = Colors.purple
        refreshCtrl.addTarget(self, action: #selector(onRefreshDiscover), for: .valueChanged)
        tableView.refreshControl = refreshCtrl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: Colors.newNavigationBarBackground), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc
    private func onTapItemSave() {
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

}

extension QTLearnerDiscoverViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8 + Category.categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: // News
            let cell = tableView.dequeueReusableCell(withIdentifier: QTLearnerDiscoverTrendingTableViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverTrendingTableViewCell
            cell.didClickTrending = { trending in
                let categoryVC = CategorySearchVC()
                if let subject = trending.subject {
                    categoryVC.subject = subject
                    categoryVC.title = subject.capitalized
                } else if let subcategoryTitle = trending.subcategoryTitle {
                    categoryVC.subcategory = subcategoryTitle
                    categoryVC.title = subcategoryTitle.capitalized
                } else if let cateogryTitle = trending.categoryTitle {
                    categoryVC.category = cateogryTitle
                    categoryVC.title = cateogryTitle
                }
                categoryVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(categoryVC, animated: true)
            }
            
            return cell
        case 1: // Categories
            let cell = tableView.dequeueReusableCell(withIdentifier: QTLearnerDiscoverCategoriesTableViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverCategoriesTableViewCell
            cell.didSelectCategory = { category in
                
            }
            
            return cell
        case 2: // Rising Talent
            let cell = tableView.dequeueReusableCell(withIdentifier: QTLearnerDiscoverRisingTalentTableViewCell.reuseIdentifier, for: indexPath) as! QTLearnerDiscoverRisingTalentTableViewCell
            cell.setObject(nil)
            cell.didClickTutor = { tutor in
                self.openTutorProfileView(tutor)
            }
            cell.didClickViewAllTutors = { tutors, loadedAllTutors in
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
                let vc = ConversationVC()
                vc.receiverId = tutor.uid
                vc.chatPartner = tutor
                vc.connectionRequestAccepted = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
                        
            return cell
        case 5: // Top In-Person Topics
            let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscoverInPersonTopicsTableViewCell", for: indexPath) as! QTLearnerDiscoverTopTopicsTableViewCell
            cell.type = .inperson
            cell.didClickTopic = { topic in
                
            }
                        
            return cell
        case 6: // Recommended
            let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscoverRecommendedTopicsTableViewCell", for: indexPath) as! QTLearnerDiscoverTopTopicsTableViewCell
            cell.type = .recommended
            cell.didClickTopic = { topic in
                
            }
                    
        return cell
        case 7: // Top Online Topics
            let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscoverOnlineTopicsTableViewCell", for: indexPath) as! QTLearnerDiscoverTopTopicsTableViewCell
            cell.type = .online
            cell.didClickTopic = { topic in
                
            }
                        
            return cell
        default: // Category Tutors
            let category = Category.categories[indexPath.section - 8]
            let cell = tableView.dequeueReusableCell(withIdentifier: "QTLearnerDiscover\(category.mainPageData.name.capitalized)TableViewCell", for: indexPath) as! QTLearnerDiscoverRisingTalentTableViewCell
            cell.setObject(category)
            cell.didClickTutor = { tutor in
                self.openTutorProfileView(tutor)
            }
            cell.didClickViewAllTutors = { tutors, loadedAllTutors in
                self.openTutorsView(title: "Rising Talents", tutors: tutors, loadedAllTutors: loadedAllTutors)
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
    
    private func openTutorsView(title: String, tutors: [AWTutor], loadedAllTutors: Bool) {
        let categoryVC = CategorySearchVC()
        categoryVC.datasource = tutors
        categoryVC.navigationItem.title = title
        categoryVC.loadedAllTutors = loadedAllTutors
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
        default:
            headerView?.title = Category.categories[section - 8].mainPageData.displayName
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

}
