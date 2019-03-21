//
//  LearnerMainPage.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import Foundation
import UIKit

var categories: [Category] = Category.categories

class LearnerMainPageVC: UIViewController {
    
    var selectedCellFrame: CGRect?
    var featuredSubjects = [MainPageFeaturedSubject]()

    var contentView: LearnerMainPageVCView {
        return view as! LearnerMainPageVCView
    }

    override func loadView() {
        view = LearnerMainPageVCView()
    }
    
    var datasource = [Category: [AWTutor]]()
    var didLoadMore = false
    var learner: AWLearner!

    override func viewDidLoad() {
        super.viewDidLoad()
        confirmSignedInUser()
        setupStripe()
        queryFeaturedTutors()
        configureView()
        loadFeaturedSubjects()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func confirmSignedInUser() {
        AccountService.shared.currentUserType = .learner
        guard let learner = CurrentUser.shared.learner else {
            navigationController?.pushViewController(SignInVC(), animated: true)
            return
        }
        self.learner = learner
    }
    
    func setupStripe() {
        Stripe.retrieveCustomer(cusID: learner.customer) { customer, error in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                self.learner.hasPayment = false
            } else if let customer = customer {
                self.learner.hasPayment = (customer.sources.count > 0)
            }
        }
    }

    func loadFeaturedSubjects() {
        DataService.shared.featchMainPageFeaturedSubject { (subjects) in
            guard let subjects = subjects else { return }
            self.featuredSubjects = subjects
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "com.qt.fetchedSubjects"), object: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func configureView() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.prefetchDataSource = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSearchTap))
        contentView.searchBar.addGestureRecognizer(tap)
    }

    private func queryFeaturedTutors() {
        displayLoadingOverlay()
        QueryData.shared.queryFeaturedTutors(categories: Array(categories[self.datasource.count..<self.datasource.count + 4])) { datasource in
            guard let datasource = datasource else { return }
            if #available(iOS 11.0, *) {
                self.contentView.tableView.performBatchUpdates({
                    self.datasource.merge(datasource, uniquingKeysWith: { _, last in last })
                    self.contentView.tableView.insertSections(IndexSet(integersIn: self.datasource.count - 3..<self.datasource.count + 1), with: .fade)
                }, completion: { _ in
                    self.didLoadMore = false
                })
            } else {
                self.contentView.tableView.beginUpdates()
                self.datasource.merge(datasource, uniquingKeysWith: { _, last in last })
                self.contentView.tableView.insertSections(IndexSet(integersIn: self.datasource.count - 3..<self.datasource.count + 1), with: .fade)
                self.contentView.tableView.endUpdates()
                self.didLoadMore = false
            }
            self.dismissOverlay()
        }
    }
    
    @objc func handleSearchTap() {
        let nav = navigationController
        DispatchQueue.main.async {
            nav?.pushViewController(QuickSearchVC(), animated: false)
        }
    }
}

extension LearnerMainPageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 250
        } else if indexPath.section == 1 {
            return 162
        } else {
            return 205
            
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "featuredCell", for: indexPath) as! LearnerMainPageFeaturedSubjectTableViewCell
            cell.collectionView.delegate = self
            cell.collectionView.dataSource = self
            return cell
        } else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tutorCell", for: indexPath) as! FeaturedTutorTableViewCell
            
            cell.parentViewController = self
            cell.datasource = datasource[categories[indexPath.section - 2]]!
            let category = CategoryFactory.shared.getCategoryFor(categories[indexPath.section - 2].subcategory.fileToRead)
            cell.category = category
            //TODO: Update to new category models
            cell.delegate = self
            return cell
        }
    }

    func numberOfSections(in _: UITableView) -> Int {
        return datasource.count + 2
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let view = SectionHeader()
        view.category.text = (section == 1) ? "Categories" : categories[section - 2].mainPageData.displayName
        return view
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 20 : 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension LearnerMainPageVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if !didLoadMore && datasource.count < 12 {
            didLoadMore = true
            queryFeaturedTutors()
        }
    }
}

extension LearnerMainPageVC: CategoryTableViewCellDelegate {
    func categoryTableViewCell(_ cell: CategoryTableViewCell, didSelect category: CategoryNew) {
        CategorySelected.title = category.name
        let next = CategorySearchVC()
        next.category = category.name
        next.navigationItem.title = category.name.capitalized
        navigationController?.pushViewController(next, animated: true)
    }
}

extension LearnerMainPageVC: FeaturedTutorTableViewCellDelegate {
    func featuredTutorTableViewCell(_ featuredTutorTableViewCell: FeaturedTutorTableViewCell, didSelect cell: TutorCollectionViewCell) {
        self.selectedCellFrame = CGRect(x: 10, y: 488, width: 137, height: 185)
    }
    
    func featuredTutorTableViewCell(_ featuredTutorTableViewCell: FeaturedTutorTableViewCell, didSelect featuredTutor: AWTutor) {
        let uid = featuredTutor.uid
//        navigationController?.delegate = self
        FirebaseData.manager.fetchTutor(uid!, isQuery: false, { (tutor) in
            guard let tutor = tutor else { return }
            let controller = QTProfileViewController.controller
            controller.subject = featuredTutor.featuredSubject
            controller.profileViewType = .tutor
            controller.user = tutor
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        })
    }
    

}

extension LearnerMainPageVC: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LearnerMainPageAnimationController(originFrame: selectedCellFrame! )
    }
}

extension LearnerMainPageVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! LearnerMainPageFeaturedSubjectCell
        cell.updateUI(featuredSubjects[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return featuredSubjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = CategorySearchVC()
        vc.subject = featuredSubjects[indexPath.item].subject
        vc.navigationItem.title = featuredSubjects[indexPath.item].subject
        navigationController?.pushViewController(vc, animated: true)
    }
}
