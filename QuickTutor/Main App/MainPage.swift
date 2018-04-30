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
        
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        sidebar.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.72)
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


class MainPage : BaseViewController {
	
    override var contentView: MainPageView {
        return view as! MainPageView
    }
    override func loadView() {
        view = MainPageView()
    }
	
	var hasPaymentMethod : Bool!
	var hasStudentBio : Bool!
	
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
		updateSideBar()
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateSideBar() { }
    
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
