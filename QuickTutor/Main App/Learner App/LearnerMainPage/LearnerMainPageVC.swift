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

var category: [Category] = Category.categories

class LearnerMainPageVC: UIViewController {
    
    var contentView: LearnerMainPageVCView {
        return view as! LearnerMainPageVCView
    }

    override func loadView() {
        view = LearnerMainPageVCView()
    }
    
    var datasource = [Category: [FeaturedTutor]]()
    var didLoadMore = false
    var learner: AWLearner!

    override func viewDidLoad() {
        super.viewDidLoad()
        confirmSignedInUser()
        setupStripe()
        queryFeaturedTutors()
        configureView()
        navigationController?.navigationBar.isHidden = true
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    private func configureView() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.prefetchDataSource = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSearchTap))
//        contentView.searchBar.addGestureRecognizer(tap)
    }

    private func queryFeaturedTutors() {
        displayLoadingOverlay()
        QueryData.shared.queryFeaturedTutors(categories: Array(category[self.datasource.count..<self.datasource.count + 4])) { datasource in
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

    private func switchToTutorSide(_ completion: @escaping (Bool) -> Void) {
        displayLoadingOverlay()
        FirebaseData.manager.fetchTutor(learner.uid!, isQuery: false) { tutor in
            guard let tutor = tutor else {
                AlertController.genericErrorAlert(self, title: "Oops!", message: "Unable to find your tutor account! Please try again.")
                return completion(false)
            }
            CurrentUser.shared.tutor = tutor
            Stripe.retrieveConnectAccount(acctId: tutor.acctId, { error, account in
                if let error = error {
                    AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                    return completion(false)
                } else if let account = account {
                    CurrentUser.shared.connectAccount = account
                    return completion(true)
                }
            })
        }
    }
	
    @objc func handleSearchTap() {
        let nav = navigationController
        DispatchQueue.main.async {
            nav?.view.layer.add(CATransition().segueFromTop(), forKey: nil)
            nav?.pushViewController(SearchSubjectsVC(), animated: false)
        }
    }
}

extension LearnerMainPageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return (UIScreen.main.bounds.height < 570) ? 180 : 200
        }
        return 205
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tutorCell", for: indexPath) as! FeaturedTutorTableViewCell

			cell.parentViewController = self
            cell.datasource = datasource[category[indexPath.section - 1]]!
            cell.category = category[indexPath.section - 1]
			
            return cell
        }
    }

    func numberOfSections(in _: UITableView) -> Int {
        return datasource.count + 1
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionHeader()
        view.category.text = (section == 0) ? "Categories" : category[section - 1].mainPageData.displayName
        return view
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 50
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
