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


class TutorMainPage : MainPage {
    override var contentView: TutorMainPageView {
        return view as! TutorMainPageView
    }
    override func loadView() {
        view = TutorMainPageView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = LocalImageCache.localImageManager.getImage(number: "1") {
            contentView.sidebar.profileView.profilePicView.image = image
        } else {
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.sidebar.applyGradient(firstColor: UIColor(hex:"2c467c").cgColor, secondColor: Colors.tutorBlue.cgColor, angle: 200, frame: contentView.sidebar.bounds)
    }
    override func updateSideBar() {
        contentView.sidebar.profileView.profileNameView.label.text = user.name!
        contentView.sidebar.profileView.profileSchoolView.label.text = user.school
        contentView.sidebar.profileView.profilePicView.image = image.getImage(number: "1")
    }
    override func handleNavigation() {
        super.handleNavigation()
        
        if(touchStartView == contentView.sidebar.paymentItem) {
            navigationController?.pushViewController(hasPaymentMethod ? BankManager() : TutorPayment(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.settingsItem) {
            navigationController?.pushViewController(TutorSettings(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.profileView) {
            navigationController?.pushViewController(TutorMyProfile(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.reportItem) {
            navigationController?.pushViewController(TutorFileReport(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.legalItem) {
            hideSidebar()
            hideBackground()
            //take user to legal on our website
        } else if(touchStartView == contentView.sidebar.helpItem) {
            navigationController?.pushViewController(TutorHelp(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.becomeQTItem) {
            navigationController?.pushViewController(LearnerPageViewController(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.tutorSidebar.taxItem) {
            navigationController?.pushViewController(TutorTaxInfo(), animated: true)
            hideSidebar()
            hideBackground()
        }
    }
}
