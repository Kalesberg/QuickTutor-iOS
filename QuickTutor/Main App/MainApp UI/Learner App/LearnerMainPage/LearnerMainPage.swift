//
//  LearnerMainPage.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import Firebase

var category : [Category] = Category.categories

class LearnerMainPageView : MainPageView {
    
    var search  = SearchBar()
    var learnerSidebar = LearnerSideBar()
    
    let tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedSectionHeaderHeight = 50
        tableView.sectionHeaderHeight = 50
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = true
        
        return tableView
    }()
    
    override var sidebar: Sidebar {
        get {
            return learnerSidebar
        } set {
            if newValue is LearnerSideBar {
                learnerSidebar = newValue as! LearnerSideBar
            } else {
                print("incorrect sidebar type for LearnerMainPage")
            }
        }
    }
    
    override func configureView() {
        navbar.addSubview(search)
        addSubview(tableView)
        super.configureView()

        navbar.backgroundColor = Colors.learnerPurple
        statusbarView.backgroundColor = Colors.learnerPurple
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        search.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.width.equalToSuperview().multipliedBy(0.65)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom).inset(-2)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        sidebar.profileView.backgroundColor = UIColor(hex: "6562C9")
        tableView.layoutSubviews()
        tableView.layoutIfNeeded()
    }
}

class LearnerMainPage : MainPage {
    
    override var contentView: LearnerMainPageView {
        return view as! LearnerMainPageView
    }
    override func loadView() {
        view = LearnerMainPageView()
    }
    
    var datasource = [Category : [FeaturedTutor]]()
    var didLoadMore = false
    var learner : AWLearner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AccountService.shared.currentUserType = .learner
        guard let learner = CurrentUser.shared.learner else {
            self.navigationController?.pushViewController(SignIn(), animated: true)
            return
        }
        self.learner = learner
        Stripe.retrieveCustomer(cusID: learner.customer) { (customer, error) in
            if let error = error {
                AlertController.genericErrorAlert(self, title: "Error", message: error.localizedDescription)
                self.learner.hasPayment = false
            } else if let customer = customer {
                self.learner.hasPayment = (customer.sources.count > 0)
            }
        }
        queryFeaturedTutors()
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.bool(forKey: "showMainPageTutorial1.0") {
            UserDefaults.standard.set(false, forKey: "showMainPageTutorial1.0")
            displayMessagesTutorial()
        }
        self.configureSideBarView()
        navigationController?.navigationBar.isHidden = true
    }
    
    private func configureSideBarView() {
        let formattedString = NSMutableAttributedString()
        contentView.sidebar.becomeQTItem.label.label.text = learner.isTutor ? "Start Tutoring" : "Become a QuickTutor"
        
        if let school = learner.school {
            formattedString
                .bold(learner.name + "\n", 17, .white)
                .regular(school, 14, .white)
        } else {
            formattedString
                .bold(learner.name, 17, .white)
        }
        
        contentView.sidebar.ratingView.ratingLabel.text = String(learner.lRating) + "  ★"
        contentView.sidebar.profileView.profileNameView.attributedText = formattedString
        contentView.sidebar.profileView.profileNameView.adjustsFontSizeToFitWidth = true
    
    }
    private func configureView() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(FeaturedTutorTableViewCell.self, forCellReuseIdentifier: "tutorCell")
        contentView.tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "categoryCell")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func displayMessagesTutorial() {
        
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "navbar-messages")
        
        let tutorial = TutorCardTutorial()
        tutorial.label.text = "This is where you'll message your tutors and schedule sessions!"
        tutorial.label.numberOfLines = 2
        tutorial.addSubview(image)
        contentView.addSubview(tutorial)
        
        tutorial.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tutorial.label.snp.remakeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        image.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView.messagesButton.image)
        }
        tutorial.imageView.snp.remakeConstraints { (make) in
            make.top.equalTo(image.snp.bottom).inset(-5)
            make.centerX.equalTo(image)
        }
        UIView.animate(withDuration: 1, animations: {
            tutorial.alpha = 1
        }, completion: { (true) in
            UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
                tutorial.imageView.center.y += 10
            })
        })
    }
    
    func displaySidebarTutorial() {
        
        let tutorial = TutorCardTutorial()
        tutorial.label.text = "This is where you can view and edit your profile information!"
        tutorial.label.numberOfLines = 2
        contentView.addSubview(tutorial)
        
        let profileView = contentView.sidebar.profileView
        
        let view = ProfileView()
        view.isUserInteractionEnabled = false
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold(learner.name, 17, .white)
        view.profileNameView.attributedText = formattedString
        view.profilePicView.sd_setImage(with: storageRef.child("student-info").child(CurrentUser.shared.learner.uid).child("student-profile-pic1"), placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
        contentView.layoutSubviews()
        
        tutorial.addSubview(view)
        
        tutorial.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        tutorial.label.snp.remakeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        
        tutorial.imageView.snp.remakeConstraints { (make) in
            make.top.equalTo(profileView.snp.bottom).inset(-10)
            make.centerX.equalTo(profileView)
        }
        
        view.snp.makeConstraints { (make) in
            make.edges.equalTo(profileView)
        }
        
        UIView.animate(withDuration: 1, animations: {
            tutorial.alpha = 1
        }, completion: { (true) in
            UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
                tutorial.imageView.center.y += 10
            })
        })
        
        view.layoutIfNeeded()
        
        view.profilePicView.layer.cornerRadius = view.profilePicView.bounds.height / 2
    }
    
    private func queryFeaturedTutors() {
        self.displayLoadingOverlay()
        
        QueryData.shared.queryFeaturedTutors(categories: Array(category[self.datasource.count..<self.datasource.count + 4])) { (datasource) in
            guard let datasource = datasource else { return }
            if #available(iOS 11.0, *) {
                self.contentView.tableView.performBatchUpdates({
                    self.datasource.merge(datasource, uniquingKeysWith: { (_, last) in last })
                    self.contentView.tableView.insertSections(IndexSet(integersIn: self.datasource.count - 3..<self.datasource.count + 1), with: .fade )
                }, completion: { (_) in
                    self.didLoadMore = false
                })
            } else {
                self.contentView.tableView.beginUpdates()
                self.datasource.merge(datasource, uniquingKeysWith: { (_, last) in last })
                self.contentView.tableView.insertSections(IndexSet(integersIn: self.datasource.count - 3..<self.datasource.count + 1) , with: .fade)
                self.contentView.tableView.endUpdates()
                self.didLoadMore = false
            }
            self.dismissOverlay()
        }
    }
    
    private func switchToTutorSide(_ completion: @escaping (Bool) -> Void) {
        self.displayLoadingOverlay()
        FirebaseData.manager.fetchTutor(learner.uid, isQuery: false) { (tutor) in
            guard let tutor = tutor else {
                AlertController.genericErrorAlert(self, title: "Oops!", message: "Unable to find your tutor account! Please try again.")
                return completion(false)
            }
            CurrentUser.shared.tutor = tutor
            Stripe.retrieveConnectAccount(acctId: tutor.acctId, { (error, account) in
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
    
    override func handleNavigation() {
        super.handleNavigation()

        if (touchStartView == contentView.sidebarButton) {
            self.contentView.sidebar.center.x -= self.contentView.sidebar.frame.maxX
            self.contentView.sidebar.alpha = 1.0
            self.contentView.sidebar.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
                self.contentView.sidebar.center.x -= self.contentView.sidebar.frame.minX
            })
            showBackground()
            if UserDefaults.standard.bool(forKey: "showLearnerSideBarTutorial1.0") {
                displaySidebarTutorial()
                UserDefaults.standard.set(false, forKey: "showLearnerSideBarTutorial1.0")
            }
        } else if (touchStartView == contentView.backgroundView) {
            self.contentView.sidebar.isUserInteractionEnabled = false
            let startX = self.contentView.sidebar.center.x
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
                self.contentView.sidebar.center.x *= -1
            }, completion: { (value: Bool) in
                self.contentView.sidebar.alpha = 0
                self.contentView.sidebar.center.x = startX
            })
            hideBackground()
        } else if(touchStartView == contentView.sidebar.paymentItem) {
            navigationController?.pushViewController(CardManager(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.settingsItem) {
            navigationController?.pushViewController(LearnerSettings(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.profileView) {
            let next = LearnerMyProfile()
            next.learner = CurrentUser.shared.learner
            navigationController?.pushViewController(next, animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.reportItem) {
            navigationController?.pushViewController(LearnerFileReport(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.legalItem) {
            hideSidebar()
            hideBackground()
            let next = WebViewVC()
            next.contentView.title.label.text = "Terms of Service"
            next.url = "https://www.quicktutor.com/legal/terms-of-service"
            next.loadAgreementPdf()
            navigationController?.pushViewController(next, animated: true)
//            guard let url = URL(string: "https://www.quicktutor.com/legal/terms-of-service") else { return }
//            if #available(iOS 10, *) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            } else {
//                UIApplication.shared.openURL(url)
//            }
        } else if(touchStartView == contentView.sidebar.shopItem) {
            hideSidebar()
            hideBackground()
            let next = WebViewVC()
            next.contentView.title.label.text = "Shop"
            next.url = "https://www.quicktutor.com/shop"
            next.loadAgreementPdf()
            navigationController?.pushViewController(next, animated: true)
        } else if(touchStartView == contentView.sidebar.helpItem) {
            navigationController?.pushViewController(LearnerHelp(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.becomeQTItem) {
            if self.learner.isTutor {
                self.displayLoadingOverlay()
                switchToTutorSide { (success) in
                    if success {
                        AccountService.shared.currentUserType = .tutor
                        self.dismissOverlay()
                        self.navigationController?.pushViewController(TutorPageViewController(), animated: true)
                    }
                    self.dismissOverlay()
                }
            } else {
                AccountService.shared.currentUserType = .tRegistration
                self.navigationController?.pushViewController(BecomeTutor(), animated: true)
            }
            hideSidebar()
            hideBackground()
        } else if (touchStartView is SearchBar) {
            let nav = self.navigationController
            DispatchQueue.main.async {
                nav?.view.layer.add(CATransition().segueFromTop(), forKey: nil)
                nav?.pushViewController(SearchSubjects(), animated: false)
            }
        } else if (touchStartView is InviteButton) {
            navigationController?.pushViewController(InviteOthers(), animated: true)
            hideSidebar()
            hideBackground()
        }
    }
}

extension LearnerMainPage : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
            
            cell.datasource = datasource[category[indexPath.section - 1]]!
            cell.category = category[indexPath.section - 1]
            
            return cell
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count + 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionHeader()
        view.category.text = (section == 0) ? "Categories" : category[section - 1].mainPageData.displayName
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension LearnerMainPage : UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maximumOffset - currentOffset <= 70.0) && (contentView.tableView.numberOfSections > 1) {
            if !didLoadMore && datasource.count < 12 {
                didLoadMore = true
                queryFeaturedTutors()
            }
        }
    }
}