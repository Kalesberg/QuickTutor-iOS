//
//  MainPage.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import UIKit

class MainPageView: MainLayoutTwoButton {
    var sidebarButton = NavbarButtonLines()
    var messagesButton = NavbarButtonMessages()
    var backgroundView = InteractableObject()

    override var leftButton: NavbarButton {
        get {
            return sidebarButton
        } set {
            sidebarButton = newValue as! NavbarButtonLines
        }
    }

    override var rightButton: NavbarButton {
        get {
            return messagesButton
        } set {
            messagesButton = newValue as! NavbarButtonMessages
        }
    }

    var sidebar = Sidebar()

    override func configureView() {
        addSubview(backgroundView)

        navbar.addSubview(sidebarButton)
        navbar.addSubview(messagesButton)

        insertSubview(sidebar, aboveSubview: navbar)
        super.configureView()

        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0.0

        sidebar.alpha = 0.0
    }

    override func applyConstraints() {
        super.applyConstraints()

        sidebarButton.allignLeft()
        messagesButton.allignRight()

        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        sidebar.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.72)
        }
    }
}

class LearnerMainPage: MainPage {
    override var contentView: LearnerMainPageView {
        return view as! LearnerMainPageView
    }

    override func loadView() {
        view = LearnerMainPageView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = LocalImageCache.localImageManager.getImage(number: "1") {
            contentView.sidebar.profileView.profilePicView.image = image
        } else {}
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        contentView.sidebar.applyGradient(firstColor: Colors.tutorBlue.cgColor, secondColor: Colors.sidebarPurple.cgColor, angle: 200, frame: contentView.sidebar.bounds)
    }

    override func updateSideBar() {
        contentView.sidebar.profileView.profileNameView.label.text = user.name
        contentView.sidebar.profileView.profileSchoolView.label.text = user.school
        contentView.sidebar.profileView.profilePicView.image = image.getImage(number: "1")
    }

    override func handleNavigation() {
        super.handleNavigation()

        if touchStartView == contentView.sidebar.paymentItem {
            navigationController?.pushViewController(hasPaymentMethod ? CardManager() : LearnerPayment(), animated: true)
            hideSidebar()
            hideBackground()
        } else if touchStartView == contentView.sidebar.settingsItem {
            navigationController?.pushViewController(LearnerSettings(), animated: true)
            hideSidebar()
            hideBackground()
        } else if touchStartView == contentView.sidebar.profileView {
            navigationController?.pushViewController(LearnerMyProfile(), animated: true)
            hideSidebar()
            hideBackground()
        } else if touchStartView == contentView.sidebar.reportItem {
            navigationController?.pushViewController(LearnerFileReport(), animated: true)
            hideSidebar()
            hideBackground()
        } else if touchStartView == contentView.sidebar.legalItem {
            hideSidebar()
            hideBackground()
            //take user to legal on our website
        } else if touchStartView == contentView.sidebar.helpItem {
            navigationController?.pushViewController(LearnerHelp(), animated: true)
            hideSidebar()
            hideBackground()
        } else if touchStartView == contentView.sidebar.becomeQTItem {
            navigationController?.pushViewController(BecomeTutor(), animated: true)
            hideSidebar()
            hideBackground()
        }
    }
}

class MainPage: BaseViewController {
    override var contentView: MainPageView {
        return view as! MainPageView
    }

    override func loadView() {
        view = MainPageView()
    }

    var hasPaymentMethod: Bool!
    var hasStudentBio: Bool!

    let user = LearnerData.userData
    let image = LocalImageCache.localImageManager

    var parentPageViewController: PageViewController!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        hasPaymentMethod = UserDefaultData.localDataManager.hasPaymentMethod
        hasStudentBio = UserDefaultData.localDataManager.hasBio
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSideBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateSideBar() {}

    override func handleNavigation() {
        if touchStartView == nil {
            return
        } else if touchStartView == contentView.sidebarButton {
            let startX = contentView.sidebar.center.x
            contentView.sidebar.center.x = (startX * -1)
            contentView.sidebar.alpha = 1.0
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.contentView.sidebar.center.x = startX
            })
            contentView.sidebar.isUserInteractionEnabled = true
            showBackground()
        } else if touchStartView! == contentView.backgroundView {
            contentView.sidebar.isUserInteractionEnabled = false
            let startX = contentView.sidebar.center.x
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                self.contentView.sidebar.center.x *= -1
            }, completion: { (_: Bool) in
                self.contentView.sidebar.alpha = 0
                self.contentView.sidebar.center.x = startX
            })
            hideBackground()
        } else if touchStartView == contentView.messagesButton {
            parentPageViewController.goToNextPage()
        }
    }

    internal func showSidebar() {
        // contentView.sidebar.fadeIn(withDuration: 0.1, alpha: 1.0)
        contentView.sidebar.alpha = 1.0
        contentView.sidebar.isUserInteractionEnabled = true
    }

    internal func showBackground() {
        contentView.backgroundView.fadeIn(withDuration: 0.4, alpha: 0.65)
        contentView.backgroundView.isUserInteractionEnabled = true
    }

    internal func hideSidebar() {
        contentView.sidebar.fadeOut(withDuration: 0.2)
        contentView.sidebar.isUserInteractionEnabled = true
    }

    internal func hideBackground() {
        contentView.backgroundView.fadeOut(withDuration: 0.4)
        contentView.backgroundView.isUserInteractionEnabled = false
    }
}

extension MainPage: PageObservation {
    func getParentPageViewController(parentRef: PageViewController) {
        parentPageViewController = parentRef
    }
}
