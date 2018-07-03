//
//  TutorMainPage.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/7/17.
//  Copyright © 2017 QuickTutor. All rights reserved.

import UIKit

class TutorMainPageView : MainPageView {
    var tutorSidebar = TutorSideBar()
    
    override var sidebar: Sidebar {
        get {
            return tutorSidebar
        } set {
            if newValue is TutorSideBar {
                tutorSidebar = newValue as! TutorSideBar
            } else {
                print("incorrect sidebar type for TutorMainPage")
            }
        }
    }
    
    let titleLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.text = "Home"
        label.font = Fonts.createBoldSize(22)
        
        return label
    }()
    
    let menuLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(22)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Your Menu"
        
        return label
    }()

    let tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionHeaderHeight = 1
		tableView.sectionFooterHeight = 7
        tableView.backgroundColor = .clear
        tableView.rowHeight = 60
		
        return tableView
    }()
    
    let collectionView : UICollectionView =  {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0.0
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        
        return collectionView
    }()
    
    override func configureView() {
        navbar.addSubview(titleLabel)
        addSubview(menuLabel)
        addSubview(tableView)
        addSubview(collectionView)
        super.configureView()
        
        backgroundView.isUserInteractionEnabled = false
        applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        menuLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.left.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(0.1)
        }

        collectionView.snp.makeConstraints { (make) in
            if(UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
                make.height.equalToSuperview().multipliedBy(0.27)
            } else {
                make.height.equalToSuperview().multipliedBy(0.24)
            }
            make.width.equalToSuperview().multipliedBy(0.93)
            make.top.equalTo(menuLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(collectionView.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.93)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(layoutMargins.bottom)
            }
            make.centerX.equalToSuperview()
        }
    }
}

class TutorLayoutView : MainLayoutTitleBackButton {
    
    var qtText = UIImageView()
    
    override func configureView() {
        navbar.addSubview(qtText)
        super.configureView()
        
        qtText.image = #imageLiteral(resourceName: "qt-small-text")
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        qtText.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

class TutorMainPage : MainPage {
    
    override var contentView: TutorMainPageView {
        return view as! TutorMainPageView
    }
    
    override func loadView() {
        view = TutorMainPageView()
    }
    
    var tutor : AWTutor!
    var account : ConnectAccount!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDelegates()
		
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.sidebar.applyGradient(firstColor: UIColor(hex:"2c467c").cgColor, secondColor: Colors.tutorBlue.cgColor, angle: 200, frame: contentView.sidebar.bounds)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let tutor = CurrentUser.shared.tutor, let account = CurrentUser.shared.connectAccount else {
            self.navigationController?.popBackToMain()
            AccountService.shared.currentUserType = .learner
            return
        }
        self.tutor = tutor
        self.account = account
        self.configureSideBarView()
		FirebaseData.manager.addUpdateFeaturedTutor(tutor: CurrentUser.shared.tutor) { (_) in }
		
        navigationController?.navigationBar.isHidden = true
    }
    
    private func configureSideBarView() {
        let formattedString = NSMutableAttributedString()
        
        if tutor.school != "" {
            formattedString
                .bold(tutor.name + "\n", 17, .white)
                .regular(tutor.school!, 14, Colors.grayText)
        } else {
            formattedString
                .bold(tutor.name, 17, .white)
        }
        
        contentView.sidebar.ratingView.ratingLabel.text = String(tutor.tRating)
        contentView.sidebar.profileView.profileNameView.attributedText = formattedString
        contentView.sidebar.profileView.profilePicView.loadUserImages(by: tutor.images["image1"]!)
    }
    private func configureDelegates() {
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(TutorMainPageTableViewCell.self, forCellReuseIdentifier: "mainPageTableViewCell")
        
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        contentView.collectionView.register(TutorMainPageCollectionViewCell.self, forCellWithReuseIdentifier: "mainPageCollectionViewCell")
    }
    
    func displaySidebarTutorial() {
        Constants.showMainPageTutorial = false
        let item = BecomeQTSidebarItem()
        item.label.label.text = "Start Learning"
        item.isUserInteractionEnabled = false
        item.icon.isHidden = true
        
        let tutorial = TutorCardTutorial()
        tutorial.label.text = "Press this button to go back to the learner app!"
        tutorial.label.numberOfLines = 2
        tutorial.addSubview(item)
        contentView.addSubview(tutorial)
        
        tutorial.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        tutorial.imageView.snp.remakeConstraints { (make) in
            make.top.equalTo(item.snp.bottom)
            make.centerX.equalTo(item)
        }
        
        tutorial.label.snp.remakeConstraints { (make) in
            make.top.equalTo(tutorial.imageView.snp.bottom).inset(-15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        
        item.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView.sidebar.becomeQTItem)
        }
        
        UIView.animate(withDuration: 1, animations: {
            tutorial.alpha = 1
        }, completion: { (true) in
            UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
                tutorial.imageView.center.y += 10
            })
        })
    }
    
    func displayMessagesTutorial() {
        
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "navbar-messages")
        
        let tutorial = TutorCardTutorial()
        tutorial.label.text = "This is where you'll message your learners and manage sessions!"
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
    
    override func handleNavigation() {
        super.handleNavigation()
        
        if(touchStartView == contentView.sidebarButton) {
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
        } else if(touchStartView == contentView.backgroundView) {
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
            
            navigationController?.pushViewController(BankManager(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.settingsItem) {
            
            navigationController?.pushViewController(TutorSettings(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.profileView) {
            let next = TutorMyProfile()
            next.tutor = CurrentUser.shared.tutor
            navigationController?.pushViewController(next, animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.reportItem) {
            navigationController?.pushViewController(TutorFileReport(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.legalItem) {
            guard let url = URL(string: "https://www.quicktutor.com/legal/terms-of-service") else {
                return
            }
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.helpItem) {
            navigationController?.pushViewController(TutorHelp(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.becomeQTItem) {
            navigationController?.pushViewController(LearnerPageViewController(), animated: true)
            AccountService.shared.currentUserType = .learner
            hideSidebar()
            hideBackground()
//        } else if(touchStartView == contentView.tutorSidebar.taxItem) {
//            navigationController?.pushViewController(TutorTaxInfo(), animated: true)
//            hideSidebar()
//            hideBackground()
        } else if (touchStartView is InviteButton) {
            navigationController?.pushViewController(InviteOthers(), animated: true)
            hideSidebar()
            hideBackground()
        }
    }
}

extension TutorMainPage : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TutorMainPageCellFactory.cells.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TutorMainPageTableViewCell
        cell.growSemiShrink {
            let viewController = TutorMainPageCellFactory.cells[indexPath.section].viewController
            if viewController.isModalInPopover {
                self.present(viewController, animated: true, completion: nil)
            } else {
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TutorMainPageTableViewCell
        cell.shrink()
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TutorMainPageTableViewCell
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform.identity
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "mainPageTableViewCell", for: indexPath) as! TutorMainPageTableViewCell
		cell.title.text = TutorMainPageCellFactory.cells[indexPath.section].mainPageCell.title
		cell.subtitle.text = TutorMainPageCellFactory.cells[indexPath.section].mainPageCell.subtitle
		
		return cell
    }
}
extension TutorMainPage : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TutorMainPageButtonFactory.buttons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainPageCollectionViewCell", for: indexPath) as! TutorMainPageCollectionViewCell
        
        cell.imageView.image = TutorMainPageButtonFactory.buttons[indexPath.item].mainPageButton.icon
        cell.backgroundColor = TutorMainPageButtonFactory.buttons[indexPath.item].mainPageButton.color
        cell.label.text = TutorMainPageButtonFactory.buttons[indexPath.item].mainPageButton.label
        cell.label.textColor = TutorMainPageButtonFactory.buttons[indexPath.item].mainPageButton.color
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorMainPageCollectionViewCell
        cell.growSemiShrink {
            let viewController = TutorMainPageButtonFactory.buttons[indexPath.item].viewController
			self.navigationController?.pushViewController(viewController, animated: true)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorMainPageCollectionViewCell
        cell.shrink()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TutorMainPageCollectionViewCell
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform.identity
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width
        let width = (screenWidth / 3) - 15
        return CGSize(width: width, height: collectionView.frame.height - 10 )
    }
}

class TutorHeaderLayoutView : TutorLayoutView {
    
    let headerLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createBoldSize(38)
        
        return label
    }()
    
    let subHeaderLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createSize(14)
        
        return label
    }()
    
    let imageView = UIImageView()
    let headerContainer = UIView()
    let infoContainer : UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.registrationDark
        view.layer.borderWidth = 1
        view.layer.borderColor = Colors.divider.cgColor
        
        return view
    }()
    
    override func configureView() {
        addSubview(headerContainer)
        headerContainer.addSubview(headerLabel)
        headerContainer.addSubview(imageView)
        addSubview(subHeaderLabel)
        addSubview(infoContainer)
        super.configureView()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        headerContainer.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom).inset(-40)
            make.height.equalTo(50)
            make.left.equalTo(imageView)
            make.right.equalTo(headerLabel)
            make.centerX.equalToSuperview()
        }
        
        headerLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { (make) in
            make.right.equalTo(headerLabel.snp.left).inset(-15)
            make.centerY.equalToSuperview()
        }
        
        subHeaderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerContainer.snp.bottom).inset(-15)
            make.centerX.equalToSuperview()
        }
    }
}
