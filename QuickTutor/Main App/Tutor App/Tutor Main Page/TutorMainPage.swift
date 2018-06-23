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
    
    let xButton : NavbarButtonX = {
        let button = NavbarButtonX()
        
        button.isHidden = true
        
        return button
    }()
    
    let viewTrendingButton = ViewTrendingButton()
    let buttonContainer = UIView()
    let trendingButton = TutorMainPageTrendingButton()
    let ratingButton = TutorMainPageRatingButton()
    let earningsButton = TutorMainPageEarningsButton()
    let improveItem = TutorMainPageImproveItem()
    let usernameItem = TutorMainPageUsernameItem()
    let listingsItem = TutorMainPageListingsItem()
    let shareUsernameModal = ShareUsernameModal()
    
    override func configureView() {
        navbar.addSubview(titleLabel)
        addSubview(menuLabel)
        addSubview(viewTrendingButton)
        addSubview(buttonContainer)
        buttonContainer.addSubview(trendingButton)
        buttonContainer.addSubview(ratingButton)
        buttonContainer.addSubview(earningsButton)
        addSubview(listingsItem)
        addSubview(improveItem)
        addSubview(usernameItem)
        insertSubview(xButton, aboveSubview: backgroundView)
        insertSubview(shareUsernameModal, aboveSubview: backgroundView)
        super.configureView()
        insertSubview(xButton, aboveSubview: backgroundView)
        insertSubview(shareUsernameModal, aboveSubview: backgroundView)
        backgroundView.isUserInteractionEnabled = false
        
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
        
        xButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.175)
            make.top.equalTo(navbar).inset(10)
            make.bottom.equalTo(navbar).inset(10)
            make.left.equalToSuperview()
        }
        
        buttonContainer.snp.makeConstraints { (make) in
            if(UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480) {
                make.height.equalToSuperview().multipliedBy(0.25)
            } else {
                make.height.equalToSuperview().multipliedBy(0.22)
            }
            make.width.equalToSuperview().multipliedBy(0.93)
            make.top.equalTo(menuLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        trendingButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        ratingButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalToSuperview()
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        earningsButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.3)
            make.right.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        listingsItem.snp.makeConstraints { (make) in
            make.top.equalTo(buttonContainer.snp.bottom).inset(-25)
            make.height.equalTo(70)
            make.width.equalToSuperview().multipliedBy(0.93)
            make.centerX.equalToSuperview()
        }
        
        improveItem.snp.makeConstraints { (make) in
            make.top.equalTo(listingsItem.snp.bottom).inset(-8)
            make.height.equalTo(70)
            make.width.equalToSuperview().multipliedBy(0.93)
            make.centerX.equalToSuperview()
        }
        
        usernameItem.snp.makeConstraints { (make) in
            make.top.equalTo(improveItem.snp.bottom).inset(-8)
            make.height.equalTo(70)
            make.width.equalToSuperview().multipliedBy(0.93)
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
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = Colors.navBarColor
        
        return label
    }()
    
    override func configureView() {
        addSubview(imageView)
        addSubview(label)
        super.configureView()
        
        clipsToBounds = true
        layer.cornerRadius = 4
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(-15)
        }
        
        label.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    
    func touchStart() {
        alpha = 0.6
    }
    
    func didDragOff() {
        alpha = 1.0
    }
}


class TutorMainPageTrendingButton : TutorMainPageButton {
    override func configureView() {
        super.configureView()
        
        backgroundColor = UIColor(hex: "5785D4")
        label.text = "View Trending"
        label.textColor = UIColor(hex: "5785D4")
        imageView.image = #imageLiteral(resourceName: "trending")
    }
}


class TutorMainPageRatingButton : TutorMainPageButton {
    override func configureView() {
        super.configureView()
        
        backgroundColor = Colors.gold
        label.text = "Your Ratings"
        label.textColor = Colors.gold
        imageView.image = #imageLiteral(resourceName: "ratings")
    }
}

class TutorMainPageEarningsButton : TutorMainPageButton {
    
    override func configureView() {
        super.configureView()
        
        backgroundColor = Colors.green
        label.text = "Your Earnings"
        label.textColor = Colors.green
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
            make.centerY.equalToSuperview()
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
    
    let blueView : UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor(hex: "5785D4")
        view.clipsToBounds = true
        
        return view
    }()
    
    let arrow : UILabel = {
        let label = UILabel()
        
        label.text = "»"
        label.font = Fonts.createSize(40)
        label.textColor = UIColor(hex: "5785D4")
        
        return label
    }()
    
    override func configureView() {
        addSubview(label)
        addSubview(blueView)
        addSubview(arrow)
        super.configureView()

        backgroundColor = Colors.navBarColor
        layer.cornerRadius = 4
        clipsToBounds = true
        applyDefaultShadow()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        blueView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(3)
            make.height.centerY.equalToSuperview()
        }
        arrow.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().inset(-4)
            make.right.equalToSuperview().inset(10)
        }
        label.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(15)
            make.right.equalTo(arrow.snp.left)
        }
    }
    
    func touchStart() {
        alpha = 0.7
    }
    
    func didDragOff() {
        alpha = 1.0
    }
}

class TutorMainPageImproveItem : TutorMainPageItem {
    
    override func configureView() {
        super.configureView()
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("Looking to improve?\n", 18, UIColor(hex: "5785D4"))
            .regular("\n", 5, .white)
            .regular("See tips on how to become a better tutor! ", 13, Colors.grayText)
        
        label.attributedText = formattedString
    }
}

class TutorMainPageUsernameItem : TutorMainPageItem {
    
    override func configureView() {
        super.configureView()
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("Share your username!\n", 18, UIColor(hex: "5785D4"))
            .regular("\n", 5, .white)
            .regular("Post your username to other platforms! ", 13, Colors.grayText)
        
        label.attributedText = formattedString
    }
}

class TutorMainPageListingsItem : TutorMainPageItem {
    
    override func configureView() {
        super.configureView()
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("Want to get featured?\n", 18, UIColor(hex: "5785D4"))
            .regular("\n", 5, .white)
            .regular("Learn more about hitting the front page.", 13, Colors.grayText)
        
        label.attributedText = formattedString
    }
}

/*
	MARK: (Depreciated) Replaced with UIActivityController
*/
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
    var account : ConnectAccount!
    
    override func viewDidLoad() {
        super.viewDidLoad()

		FirebaseData.manager.addUpdateFeaturedTutor(tutor: CurrentUser.shared.tutor) { (_) in
			
		}
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.sidebar.applyGradient(firstColor: UIColor(hex:"2c467c").cgColor, secondColor: Colors.tutorBlue.cgColor, angle: 200, frame: contentView.sidebar.bounds)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let tutor = CurrentUser.shared.tutor, let account = CurrentUser.shared.connectAccount  else {
            self.navigationController?.popBackToMain()
            AccountService.shared.currentUserType = .learner
            return
        }
        self.tutor = tutor
        self.account = account
        self.configureSideBarView()
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
            print("sdfsfd")
        }
        
        contentView.sidebar.ratingView.ratingLabel.text = String(tutor.tRating)
        contentView.sidebar.profileView.profileNameView.attributedText = formattedString
        contentView.sidebar.profileView.profilePicView.loadUserImages(by: tutor.images["image1"]!)
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
        } else if (touchStartView == contentView.trendingButton) {
            navigationController?.pushViewController(TrendingCategories(), animated: true)
        } else if (touchStartView == contentView.usernameItem) {
            
            DispatchQueue.main.async {
                let text = "Go checkout QuickTutor!"
                guard let webUrl = URL(string:"https://QuickTutor.com") else { return }
                let shareAll : [Any] = [text, webUrl]
                let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }
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
        }
		/*
			MARK: // Depreciated
		*/
		else if (touchStartView == contentView.shareUsernameModal.twitterImage) {
            
            let tweetText = "Follow me on Quicktutor! \(CurrentUser.shared.tutor.username)"
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
        }
		/*
			MARK: // Depreciated
		*/
		else if (touchStartView == contentView.shareUsernameModal.facebookImage) {
            let content = FBSDKShareLinkContent()
            
            content.contentURL =  URL(string: "https://quicktutor.com")
            content.quote = "AZolt23"
            
            let dialog : FBSDKShareDialog = FBSDKShareDialog()
            dialog.fromViewController = self
            dialog.shareContent = content
            dialog.mode = FBSDKShareDialogMode.automatic
            dialog.show()
            
        }
		/*
			MARK: // Depreciated
		*/
		else if (touchStartView == contentView.shareUsernameModal.messagesImage) {
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = "Follow me on QuickTutor! "
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }
		/*
			MARK: // Depreciated
		*/
		else if (touchStartView == contentView.shareUsernameModal.emailImage) {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setMessageBody("<p>Hey!, Check me out on QuickTutor! http://QuickTutor.com/</p>", isHTML: true)
                
                present(mail, animated: true)
            } else {
                print("oops!")
            }
        } else if (touchStartView is InviteButton) {
            navigationController?.pushViewController(InviteOthers(), animated: true)
            hideSidebar()
            hideBackground()
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
