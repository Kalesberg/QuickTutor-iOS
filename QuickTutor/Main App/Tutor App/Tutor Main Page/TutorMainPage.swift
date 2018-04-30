//
//  TutorMainPage.swift
//  QuickTutor
//
//  Created by QuickTutor on 12/7/17.
//  Copyright © 2017 QuickTutor. All rights reserved.

import UIKit
import FirebaseAuth
import MessageUI
import FBSDKShareKit

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
    
    var qtText = UIImageView()
    
    let nameLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(18)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    let xButton : NavbarButtonX = {
        let button = NavbarButtonX()
        
        button.isHidden = true
        
        return button
    }()
    
    let viewTrendingButton = ViewTrendingButton()
    let buttonContainer = UIView()
    //let leaderboardButton = TutorMainPageLeaderButton()
    let ratingButton = TutorMainPageRatingButton()
    let earningsButton = TutorMainPageEarningsButton()
    let improveItem = TutorMainPageImproveItem()
    let usernameItem = TutorMainPageUsernameItem()
    let shareUsernameModal = ShareUsernameModal()
    
    override func configureView() {
        navbar.addSubview(qtText)
        addSubview(nameLabel)
        addSubview(viewTrendingButton)
        addSubview(buttonContainer)
        //buttonContainer.addSubview(leaderboardButton)
        buttonContainer.addSubview(ratingButton)
        buttonContainer.addSubview(earningsButton)
        addSubview(improveItem)
        addSubview(usernameItem)
        insertSubview(xButton, aboveSubview: backgroundView)
        insertSubview(shareUsernameModal, aboveSubview: backgroundView)
        super.configureView()
        insertSubview(xButton, aboveSubview: backgroundView)
        insertSubview(shareUsernameModal, aboveSubview: backgroundView)
        backgroundView.isUserInteractionEnabled = false
        AccountService.shared.currentUserType = .tutor
        qtText.image = #imageLiteral(resourceName: "qt-small-text")
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        qtText.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(6)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.left.equalToSuperview().inset(20)
            make.right.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
        
        xButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.175)
            make.top.equalTo(navbar).inset(10)
            make.bottom.equalTo(navbar).inset(10)
            make.left.equalToSuperview()
        }
        
        viewTrendingButton.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).inset(-8)
            make.width.equalTo(140)
            make.centerX.equalToSuperview()
            make.height.equalTo(35)
        }
        
        buttonContainer.snp.makeConstraints { (make) in
            make.height.equalTo(110)
            make.right.equalToSuperview().inset(10)
            make.left.equalToSuperview().inset(10)
            make.top.equalTo(viewTrendingButton.snp.bottom).inset(-50)
        }
        
//        leaderboardButton.snp.makeConstraints { (make) in
//            make.width.equalTo(size)
//            make.left.equalToSuperview()
//            make.height.equalToSuperview()
//            make.centerY.equalToSuperview()
//        }
        
        ratingButton.snp.makeConstraints { (make) in
            make.width.equalTo(110)
            make.centerX.equalToSuperview().inset(-80)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        earningsButton.snp.makeConstraints { (make) in
            make.width.equalTo(110)
            make.centerX.equalToSuperview().inset(80)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        var height : Int
        
        if (UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
            height = 75
        } else {
            height = 100
        }
        
        improveItem.snp.makeConstraints { (make) in
            make.top.equalTo(earningsButton.snp.bottom).inset(-50)
            make.height.equalTo(height)
            make.width.equalToSuperview().inset(-4)
            make.centerX.equalToSuperview()
        }
        
        usernameItem.snp.makeConstraints { (make) in
            make.top.equalTo(improveItem.snp.bottom).inset(1)
            make.height.equalTo(height)
            make.width.equalToSuperview().inset(-4)
            make.centerX.equalToSuperview()
        }
        
        shareUsernameModal.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(-20)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalTo(220)
        }
    }
}

class ViewTrendingButton : InteractableView, Interactable {
    
    let label : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createSize(17)
        label.textAlignment = .center
        label.text = "View Trending"
        label.textColor = Colors.lightBlue
        
        return label
    }()

    override func configureView() {
        addSubview(label)
        super.configureView()
        
        backgroundColor = Colors.registrationDark
        layer.borderColor = Colors.lightBlue.cgColor
        layer.borderWidth = 1.5
        layer.cornerRadius = 5
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func touchStart() {
       alpha = 0.7
    }
    
    func didDragOff() {
        alpha = 1.0
    }
}


class TutorMainPageButton : InteractableView, Interactable {
    
    let imageView = UIImageView()
    
    let label : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createSize(13)
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    override func configureView() {
        addSubview(imageView)
        addSubview(label)
        super.configureView()
        
        layer.borderWidth = 2
        layer.cornerRadius = 6
        applyConstraints()

    }
    
    override func applyConstraints() {
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(-5)
        }
        
        label.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(10)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    func touchStart() {
        alpha = 0.6
    }
    
    func didDragOff() {
        alpha = 1.0
    }
}


class TutorMainPageLeaderButton : TutorMainPageButton {
    
    override func configureView() {
        super.configureView()
        
        label.text = "Leaderboards"
        label.textColor = UIColor(hex: "1FAA96")
        
        layer.borderColor = UIColor(hex: "1FAA96").cgColor
        
        imageView.image = #imageLiteral(resourceName: "leaderboard")
    }
}


class TutorMainPageRatingButton : TutorMainPageButton {
    
    override func configureView() {
        super.configureView()
        
        label.text = "Your Ratings"
        label.textColor = Colors.yellow
        
        layer.borderColor = Colors.yellow.cgColor
        
        imageView.image = #imageLiteral(resourceName: "rating")
    }
}

class TutorMainPageEarningsButton : TutorMainPageButton {
    
    override func configureView() {
        super.configureView()
        
        label.text = "Your Earnings"
        label.textColor = Colors.green
        
        layer.borderColor = Colors.green.cgColor
        
        imageView.image = #imageLiteral(resourceName: "earnings")
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
            make.centerY.equalToSuperview().inset(6)
        }
    }
}


class TutorMainPageItem : InteractableView, Interactable {
    
    let label : UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.sizeToFit()
        
        return label
    }()
    
    override func configureView() {
        addSubview(label)
        super.configureView()

        layer.borderWidth = 1
        layer.borderColor = Colors.divider.cgColor
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.95)
            make.centerX.equalToSuperview()
        }
    }
    
    func touchStart() {
        backgroundColor = Colors.registrationDark
    }
    
    func didDragOff() {
        backgroundColor = .clear
    }
}

class TutorMainPageImproveItem : TutorMainPageItem {
    
    override func configureView() {
        super.configureView()
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("Looking to improve?\n\n", 16, .white)
            .regular("See tips on how to become a better tutor! ", 14, .white)
            .bold("»", 17, .white)
        
        label.attributedText = formattedString
    }
}

class TutorMainPageUsernameItem : TutorMainPageItem {
    
    override func configureView() {
        super.configureView()
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("Share your username!\n\n", 16, .white)
            .regular("Post your username to other platforms! ", 14, .white)
            .bold("»", 17, .white)
        
        label.attributedText = formattedString
    }
}

class ShareUsernameModal : InteractableView {
    
    let shareUsernameLabel : UILabel = {
        let label = UILabel()
        
        label.text = "SHARE USERNAME"
        label.font = Fonts.createBoldSize(18)
        label.textColor = .white
        label.backgroundColor = UIColor(hex: "4C5E8D")
        label.textAlignment = .center
        
        return label
    }()
    
    let nameLabel : CenterTextLabel = {
        let label = CenterTextLabel()
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("AlexZolt3", 22, Colors.tutorBlue)
            .regular("\nYOUR USERNAME", 15, .white)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
        
        label.label.attributedText = formattedString
        label.label.textAlignment = .center
        
        return label
    }()
    
    let twitterImage : ModalImage = {
        let image = ModalImage()
        
        image.imageView.image = #imageLiteral(resourceName: "social-twitter")
        
        return image
    }()
    let facebookImage : ModalImage = {
        let image = ModalImage()
        
        image.imageView.image = #imageLiteral(resourceName: "social-facebook")
        
        return image
    }()
    let messagesImage : ModalImage = {
        let image = ModalImage()
        
        image.imageView.image = #imageLiteral(resourceName: "social-imessages")
        
        return image
    }()
    let emailImage : ModalImage = {
        let image = ModalImage()
        
        image.imageView.image = #imageLiteral(resourceName: "social-email")
        
        return image
    }()
    
    override func configureView () {
        addSubview(shareUsernameLabel)
        addSubview(nameLabel)
        addSubview(twitterImage)
        addSubview(facebookImage)
        addSubview(messagesImage)
        addSubview(emailImage)
        super.configureView()
        
        layer.cornerRadius = 8
        backgroundColor = Colors.backgroundDark
        isHidden = true
        clipsToBounds = true
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        shareUsernameLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(45)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.5)
            make.top.equalTo(shareUsernameLabel.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        twitterImage.snp.makeConstraints { (make) in
            make.width.equalTo(55)
            make.height.equalTo(55)
            make.bottom.equalToSuperview().inset(20)
            make.centerX.equalToSuperview().inset(30)
        }
        
        facebookImage.snp.makeConstraints { (make) in
            make.width.equalTo(55)
            make.height.equalTo(55)
            make.bottom.equalToSuperview().inset(20)
            make.centerX.equalToSuperview().inset(-30)
        }
        
        messagesImage.snp.makeConstraints { (make) in
            make.width.equalTo(55)
            make.height.equalTo(55)
            make.bottom.equalToSuperview().inset(20)
            make.centerX.equalTo(facebookImage).inset(-60)
        }

        emailImage.snp.makeConstraints { (make) in
            make.width.equalTo(55)
            make.height.equalTo(55)
            make.bottom.equalToSuperview().inset(20)
            make.centerX.equalTo(twitterImage).inset(60)
        }
    }
}


class ModalImage : InteractableView, Interactable {
    
    let imageView : UIImageView = {
        let image = UIImageView()

        image.scaleImage()
        
        return image
    }()
    
    override func configureView() {
        addSubview(imageView)
        super.configureView()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(35)
        }
    }
    
    func touchStart() {
        imageView.alpha = 0.7
    }
    
    func didDragOff() {
        imageView.alpha = 1.0
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseData.manager.getTutor(Auth.auth().currentUser!.uid) { (tutor) in
            if let tutor = tutor {
                AccountService.shared.currentUserType = .tutor
                CurrentUser.shared.tutor = tutor
                self.tutor = tutor

                Stripe.stripeManager.retrieveConnectAccount(acctId: tutor.acctId, { (account)  in
                    if let account = account {
                    }
                    self.configureSideBarView()
                })

            } else {
                try! Auth.auth().signOut()
                self.navigationController?.pushViewController(SignIn(), animated: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.sidebar.applyGradient(firstColor: UIColor(hex:"2c467c").cgColor, secondColor: Colors.tutorBlue.cgColor, angle: 200, frame: contentView.sidebar.bounds)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func configureSideBarView() {
        let formattedString = NSMutableAttributedString()
        
        let name = tutor.name.split(separator: " ")
        contentView.nameLabel.text = "Welcome back, \(name[0])"
		
		if let school = tutor.school {
			formattedString
				.bold(tutor.name + "\n", 17, .white)
				.regular(school, 14, Colors.grayText)
		} else {
			formattedString
				.bold(tutor.name, 17, .white)
		}
		
        contentView.sidebar.ratingView.ratingLabel.text = String(tutor.tRating)
        contentView.sidebar.profileView.profileNameView.attributedText = formattedString
        contentView.sidebar.profileView.profilePicView.loadUserImages(by: tutor.images["image1"]!)
    }
    override func handleNavigation() {
        super.handleNavigation()
        
        if(touchStartView == contentView.sidebar.paymentItem) {
            
            let transition = CATransition()
            let nav = self.navigationController
            
            let next = BankManager()
            next.acctId = tutor.acctId
            
            DispatchQueue.main.async {
                nav?.view.layer.add(transition.segueFromBottom(), forKey: nil)
                nav?.pushViewController(next, animated: false)
            }
            
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.settingsItem) {
            
            let next = TutorSettings()
            next.tutor = self.tutor
            
            let transition = CATransition()
            let nav = self.navigationController
            DispatchQueue.main.async {
                nav?.view.layer.add(transition.segueFromLeft(), forKey: nil)
                nav?.pushViewController(next, animated: false)
            }
            
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.profileView) {
            let next = TutorMyProfile()
            next.tutor = CurrentUser.shared.tutor
            let transition = CATransition()
            let nav = self.navigationController
            DispatchQueue.main.async {
                nav?.view.layer.add(transition.segueFromBottom(), forKey: nil)
                nav?.pushViewController(next, animated: false)
            }
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.reportItem) {
            
            let transition = CATransition()
            let nav = self.navigationController
            DispatchQueue.main.async {
                nav?.view.layer.add(transition.segueFromBottom(), forKey: nil)
                nav?.pushViewController(TutorFileReport(), animated: false)
            }
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.legalItem) {
            guard let url = URL(string: "https://www.quicktutor.com") else {
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
            let transition = CATransition()
            let nav = self.navigationController
            DispatchQueue.main.async {
                nav?.view.layer.add(transition.segueFromBottom(), forKey: nil)
                nav?.pushViewController(TutorHelp(), animated: false)
            }
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.becomeQTItem) {
            navigationController?.pushViewController(LearnerPageViewController(), animated: true)
            AccountService.shared.currentUserType = .learner
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.tutorSidebar.taxItem) {
            navigationController?.pushViewController(TutorTaxInfo(), animated: true)
            hideSidebar()
            hideBackground()
        } else if (touchStartView == contentView.ratingButton) {
            let next = TutorRatings()
            next.tutor = self.tutor
            navigationController?.pushViewController(next, animated: true)
        } else if (touchStartView == contentView.earningsButton) {
            navigationController?.pushViewController(TutorEarnings(), animated: true)
        } else if (touchStartView == contentView.improveItem) {
            navigationController?.pushViewController(TutorMainTips(), animated: true)
        } else if (touchStartView == contentView.viewTrendingButton) {
            navigationController?.pushViewController(TrendingCategories(), animated: true)
        } else if (touchStartView == contentView.usernameItem) {
            contentView.backgroundView.alpha = 0.65
            contentView.xButton.isHidden = false
            contentView.leftButton.isHidden = true
            for view in contentView.subviews {
                if !(view is NavbarButtonX || view is ShareUsernameModal) {
                    view.isUserInteractionEnabled = false
                }
            }
            contentView.shareUsernameModal.isHidden = false
        } else if (touchStartView == contentView.xButton) {
            contentView.backgroundView.alpha = 0
            contentView.xButton.isHidden = true
            contentView.leftButton.isHidden = false
            for view in contentView.subviews {
                if !(view is NavbarButtonX || view is ShareUsernameModal) {
                    view.isUserInteractionEnabled = true
                }
            }
            contentView.shareUsernameModal.isHidden = true
        } else if (touchStartView == contentView.shareUsernameModal.twitterImage) {
            
            let tweetText = "Follow me on Quicktutor!"
            let usernameURL = "http://QuickTutor.com/"
            let shareString = "https://twitter.com/intent/tweet?text=\(tweetText)&url=\(usernameURL)"
            
            let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

            guard let url = URL(string: escapedShareString) else {
                return
            }
        
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else if (touchStartView == contentView.shareUsernameModal.facebookImage) {
            //TODO - - need to integrate FBSDK
        } else if (touchStartView == contentView.shareUsernameModal.messagesImage) {
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = "Follow me on QuickTutor! "
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
        } else if (touchStartView == contentView.shareUsernameModal.emailImage) {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setMessageBody("<p>Hey!, Check me out on QuickTutor! http://QuickTutor.com/</p>", isHTML: true)
                
                present(mail, animated: true)
            } else {
                print("oops!")
            }
        }
    }
}
extension TutorMainPage : MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
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
