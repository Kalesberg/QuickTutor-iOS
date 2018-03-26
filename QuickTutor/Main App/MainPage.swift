//
//  MainPage.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Firebase
import UIKit

class MainPageView : MainLayoutTwoButton {
    
    var sidebarButton  = NavbarButtonLines()
    var messagesButton = NavbarButtonMessages()
    var backgroundView = InteractableObject()
	
	var label = UILabel()
	
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
        
		addSubview(label)
        super.configureView()
        
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0.0
        
        sidebar.alpha = 0.0
        
//        messagesSessionsControl.insertSegment(withTitle: "Messages", at: 0, animated: true)
//        messagesSessionsControl.insertSegment(withTitle: "Sessions", at: 1, animated: true)
//
//        let rightView = messagesSessionsControl.subviews[0]
//        let leftView = messagesSessionsControl.subviews[1]
//
//        messagesSessionsControl.layer.cornerRadius = 6
//        let font = Fonts.createLightSize(18)
//        messagesSessionsControl.setTitleTextAttributes([NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: UIColor.white],
//                                                for: .selected)
//        messagesSessionsControl.setTitleTextAttributes([NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: UIColor.white],
//                                                    for: .normal)
//        messagesSessionsControl.layer.borderWidth = 1.5
//        messagesSessionsControl.layer.borderColor = UIColor.white.cgColor
//        messagesSessionsControl.setDividerImage(UIImage(color: .white, size: CGSize(width: 0.75, height: messagesSessionsControl.frame.height)), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
//        messagesSessionsControl.selectedSegmentIndex = 0
//        messagesSessionsControl.tintColor = .clear
//
//        rightView.layer.cornerRadius = 6
//        leftView.layer.cornerRadius = 6
        
        
		label.text = ""
		label.font = Fonts.createSize(20)
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.textColor = .white
		
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        sidebarButton.allignLeft()
        
        messagesButton.allignRight()
        
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        sidebar.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.72)
        }
        
		label.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.width.equalToSuperview()
			make.height.equalToSuperview().dividedBy(2)
		}
    }
}

class SearchBar: BaseView, Interactable {
    
    var searchIcon  = UIImageView()
    var searchLabel = CenterTextLabel()

    override func configureView() {
        addSubview(searchIcon)
        addSubview(searchLabel)
        
        backgroundColor = .white
        layer.cornerRadius = 12
        
        searchIcon.image = UIImage(named: "navbar-search")
        searchIcon.scaleImage()
        
        searchLabel.label.text = "Search"
        searchLabel.label.font = Fonts.createSize(18)
        searchLabel.label.textColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0)
        searchLabel.applyConstraints()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        searchIcon.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.18)
            make.height.equalToSuperview().multipliedBy(0.6)
            make.centerY.equalToSuperview()
        }
        searchLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

}

class LearnerMainPage : MainPage {
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
        } else {
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
 
        contentView.sidebar.applyGradient(firstColor: Colors.tutorBlue.cgColor, secondColor: Colors.sidebarPurple.cgColor, angle: 200, frame: contentView.sidebar.bounds)
    }
    override func updateSideBar() {
        contentView.sidebar.profileView.profileNameView.label.text = "\(user.firstName!) \(user.lastName!)"
        contentView.sidebar.profileView.profileSchoolView.label.text = user.school
        contentView.sidebar.profileView.profilePicView.image = image.getImage(number: "1")
    }
    override func handleNavigation() {
        super.handleNavigation()
        
        if(touchStartView == contentView.sidebar.paymentItem) {
            navigationController?.pushViewController(hasPaymentMethod ? CardManager() : LearnerPayment(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.settingsItem) {
            navigationController?.pushViewController(LearnerSettings(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.profileView) {
            navigationController?.pushViewController(LearnerMyProfile(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.reportItem) {
            navigationController?.pushViewController(LearnerFileReport(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.legalItem) {
            hideSidebar()
            hideBackground()
            //take user to legal on our website
        } else if(touchStartView == contentView.sidebar.helpItem) {
            navigationController?.pushViewController(LearnerHelp(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.becomeQTItem) {
            navigationController?.pushViewController(BecomeTutor(), animated: true)
            hideSidebar()
            hideBackground()
        }
    }
}



class MainPage : BaseViewController {
	
    override var contentView: MainPageView {
        return view as! MainPageView
    }
    override func loadView() {
        view = MainPageView()
    }
	
	var hasPaymentMethod : Bool!
	var hasStudentBio : Bool!
	
	let user = LearnerData.userData
	let image = LocalImageCache.localImageManager
	
	var parentPageViewController : PageViewController!

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
		print("view will appear")
		updateSideBar()
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateSideBar() { }
	
//    @objc internal func controlChanged() {
//        let _ = contentView.messagesSessionsControl.subviews[0]
//        let _ = contentView.messagesSessionsControl.subviews[1]
//
//        switch contentView.messagesSessionsControl.selectedSegmentIndex
//        {
//        case 0:
//            contentView.messagesSessionsControl.layer.sublayers![0].frame = CGRect(x: leftView.frame.minX + 1.5, y: leftView.frame.minY + 1.5, width: leftView.frame.width - 7, height: leftView.frame.height - 3)
//        case 1:
//            contentView.messagesSessionsControl.layer.sublayers![0].frame = CGRect(x: rightView.frame.minX + 1.5, y: rightView.frame.minY + 1.5, width: rightView.frame.width - 7, height: rightView.frame.height - 3)
//        default:
//            break
//        }
//    }
    
    override func handleNavigation() {
        if (touchStartView == nil) {
            return
        } else if(touchStartView == contentView.sidebarButton) {
            let startX = self.contentView.sidebar.center.x
            self.contentView.sidebar.center.x = (startX * -1)
            self.contentView.sidebar.alpha = 1.0
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.contentView.sidebar.center.x = startX
            })
            self.contentView.sidebar.isUserInteractionEnabled = true
            showBackground()
        } else if(touchStartView! == contentView.backgroundView) {
            self.contentView.sidebar.isUserInteractionEnabled = false
            let startX = self.contentView.sidebar.center.x
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
               self.contentView.sidebar.center.x *= -1
            }, completion: { (value: Bool) in
                self.contentView.sidebar.alpha = 0
                self.contentView.sidebar.center.x = startX
            })
            hideBackground()
        } else if(touchStartView == contentView.messagesButton) {
			parentPageViewController.goToNextPage()
        }
    }
    
    internal func showSidebar() {
        //contentView.sidebar.fadeIn(withDuration: 0.1, alpha: 1.0)
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

extension MainPage : PageObservation {
	func getParentPageViewController(parentRef: PageViewController) {
		parentPageViewController = parentRef
	}
}
