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
        let cirlce = UIView()
        cirlce.backgroundColor = Colors.tutorBlue
        cirlce.layer.cornerRadius = 7
        cirlce.layer.zPosition = .greatestFiniteMagnitude
        navbar.addSubview(cirlce)
        cirlce.anchor(top: messagesButton.topAnchor, left: nil, bottom: nil, right: messagesButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 14, height: 14)
        bringSubview(toFront: cirlce)
        
        insertSubview(sidebar, aboveSubview: navbar)
        super.configureView()

        backgroundView.alpha = 0.0

		sidebar.alpha = 0.0
    
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.isUserInteractionEnabled = false
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.addSubview(blurEffectView)
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
        
        searchLabel.label.text = "Search for Tutors"
        searchLabel.label.font = Fonts.createSize(17)
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
	func touchStart() {
	}
	func didDragOff() {
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

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        contentView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSideBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if (gestureRecognizer.state == .began || gestureRecognizer.state == .changed) && contentView.sidebar.isUserInteractionEnabled == true {
            
            let translation = gestureRecognizer.translation(in: self.view)
            
            let sidebar = contentView.sidebar
            
            //restrict moving past the boundaries of left side of screen
            if (sidebar.frame.minX == 0 && translation.x >= 0.0) {
                return
            }
            
            //snap the left side of sidebar to left side of screen when the translation would cause the sidebar to move past the left side of the screen
            if (sidebar.frame.minX + translation.x > 0.0) {
                sidebar.center.x -= sidebar.frame.minX
                return
            }
            
            //move sidebar
            sidebar.center.x = sidebar.center.x + translation.x
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            
        } else if gestureRecognizer.state == .ended {
            if contentView.sidebar.frame.maxX < UIScreen.main.bounds.width / 1.7 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.contentView.sidebar.center.x -= self.contentView.sidebar.frame.maxX
                    self.hideBackground()
                }) { (true) in
                    self.contentView.sidebar.isUserInteractionEnabled = false
                    self.contentView.sidebar.alpha = 0
                }
            } else {
                UIView.animate(withDuration: 0.25, animations: {
                    self.contentView.sidebar.center.x -= self.contentView.sidebar.frame.minX
                })
            }
        }
    }
    
    func updateSideBar() { }
    
    override func handleNavigation() {
        if (touchStartView == contentView.messagesButton) {
            let vc = MessagesVC()
            vc.parentPageViewController = parentPageViewController
            parentPageViewController.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        }
    }
    
    internal func showSidebar() {
        contentView.sidebar.alpha = 1.0
        contentView.sidebar.isUserInteractionEnabled = true
    }
    
    internal func showBackground() {
        contentView.backgroundView.fadeIn(withDuration: 0.4, alpha: 0.75)
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
