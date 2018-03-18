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
	
    var messagesView = BaseView()
    var messagesSessionsControl = UISegmentedControl()
	
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
    
    var search         = SearchBar()
    var sidebar        = Sidebar()
    
    override func configureView() {
        addSubview(backgroundView)
  
        navbar.addSubview(sidebarButton)
        navbar.addSubview(messagesButton)
        navbar.addSubview(search)
        
        insertSubview(sidebar, aboveSubview: navbar)
        
        messagesView.addSubview(messagesSessionsControl)
        addSubview(messagesView)
		addSubview(label)
        super.configureView()
        
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0.0
        
        messagesView.alpha = 0.0
        
        messagesSessionsControl.insertSegment(withTitle: "Messages", at: 0, animated: true)
        messagesSessionsControl.insertSegment(withTitle: "Sessions", at: 1, animated: true)
        
        let rightView = messagesSessionsControl.subviews[0]
        let leftView = messagesSessionsControl.subviews[1]
        
        messagesSessionsControl.layer.cornerRadius = 6
        let font = Fonts.createLightSize(18)
        messagesSessionsControl.setTitleTextAttributes([NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: UIColor.white],
                                                for: .selected)
        messagesSessionsControl.setTitleTextAttributes([NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: UIColor.white],
                                                    for: .normal)
        messagesSessionsControl.layer.borderWidth = 1.5
        messagesSessionsControl.layer.borderColor = UIColor.white.cgColor
        messagesSessionsControl.setDividerImage(UIImage(color: .white, size: CGSize(width: 0.75, height: messagesSessionsControl.frame.height)), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        messagesSessionsControl.selectedSegmentIndex = 0
        messagesSessionsControl.tintColor = .clear
        
        rightView.layer.cornerRadius = 6
        leftView.layer.cornerRadius = 6
        
        let firstColor = Colors.tutorBlue.cgColor
        let secondColor = Colors.learnerPurple.cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: leftView.frame.minX + 1.5, y: leftView.frame.minY + 1.5, width: leftView.frame.width - 7, height: leftView.frame.height - 3)
        gradientLayer.cornerRadius = 1
        gradientLayer.colors = [ firstColor, secondColor ]
        
        let x: Double! = 90 / 360.0
        let a = pow(sinf(Float(2.0 * .pi * ((x + 0.75) / 2.0))),2.0);
        let b = pow(sinf(Float(2 * .pi * ((x+0.0)/2))),2);
        let c = pow(sinf(Float(2 * .pi * ((x+0.25)/2))),2);
        let d = pow(sinf(Float(2 * .pi * ((x+0.5)/2))),2);
        
        gradientLayer.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
        gradientLayer.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
        
        gradientLayer.locations = [0, 0.7, 0.9, 1]
        
        messagesSessionsControl.layer.insertSublayer(gradientLayer, at: 0)
        
        sidebar.alpha = 0.0
		
		label.text = "Here is MainPage"
		label.font = Fonts.createSize(40)
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.textColor = .white
		
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        search.snp.makeConstraints { (make) in
            make.height.equalTo(35) //(1 - (DeviceInfo.multiplier - 1)) *
            make.width.equalToSuperview().multipliedBy(0.65)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(5)
        }
        
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
        
        messagesView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.left.equalTo(layoutMarginsGuide.snp.left)
            make.right.equalTo(layoutMarginsGuide.snp.right)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        
        messagesSessionsControl.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalToSuperview().multipliedBy(0.75)
            make.centerX.equalToSuperview()
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

class MainPage : BaseViewController {
	
    override var contentView: MainPageView {
        return view as! MainPageView
    }
    override func loadView() {
        view = MainPageView()
    }
	
	private var hasPaymentMethod : Bool!
	private var hasStudentBio : Bool!
	
	let user = UserData.userData
	let image = LocalImageCache.localImageManager
	
	var parentPageViewController : PageViewController!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		contentView.messagesSessionsControl.addTarget(self, action: #selector(controlChanged), for: .valueChanged)
		if let image = LocalImageCache.localImageManager.getImage(number: "1") {
			contentView.sidebar.purpleView.profilePicView.image = image
		} else {
			//set to some arbitrary image.
		}
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		//temporary
        hasPaymentMethod = UserDefaultData.localDataManager.hasPaymentMethod
        hasStudentBio = UserDefaultData.localDataManager.hasBio
		
	}
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.sidebar.applyGradient(firstColor: Colors.tutorBlue.cgColor, secondColor: Colors.sidebarPurple.cgColor, angle: 200, frame: contentView.sidebar.bounds)
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
	private func updateSideBar() {
		contentView.sidebar.purpleView.profileNameView.label.text = "\(user.firstName!) \(user.lastName!)"
		contentView.sidebar.purpleView.profileSchoolView.label.text = user.school
		contentView.sidebar.purpleView.profilePicView.image = image.getImage(number: "1")
	}
	
    @objc internal func controlChanged() {
        let _ = contentView.messagesSessionsControl.subviews[0]
        let _ = contentView.messagesSessionsControl.subviews[1]

//        switch contentView.messagesSessionsControl.selectedSegmentIndex
//        {
//        case 0:
//            contentView.messagesSessionsControl.layer.sublayers![0].frame = CGRect(x: leftView.frame.minX + 1.5, y: leftView.frame.minY + 1.5, width: leftView.frame.width - 7, height: leftView.frame.height - 3)
//        case 1:
//            contentView.messagesSessionsControl.layer.sublayers![0].frame = CGRect(x: rightView.frame.minX + 1.5, y: rightView.frame.minY + 1.5, width: rightView.frame.width - 7, height: rightView.frame.height - 3)
//        default:
//            break
//        }
    }
    
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
			
//            let startX = self.contentView.messagesView.center.x
//            self.contentView.messagesView.center.x = (startX * 3)
//            contentView.messagesView.fadeIn(withDuration: 0.5, alpha: 1.0)
//            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
//                self.contentView.messagesView.center.x = startX
//            })
//            contentView.messagesView.isUserInteractionEnabled = true
        } else if(touchStartView == contentView.sidebar.paymentItem) {
			navigationController?.pushViewController(hasPaymentMethod ? CardManager() : Payment(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.settingsItem) {
            navigationController?.pushViewController(Settings(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.purpleView) {
            navigationController?.pushViewController(MyProfile(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.reportItem) {
            navigationController?.pushViewController(FileReport(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.legalItem) {
            hideSidebar()
            hideBackground()
            //take user to legal on our website
        } else if(touchStartView == contentView.sidebar.helpItem) {
            navigationController?.pushViewController(Help(), animated: true)
            hideSidebar()
            hideBackground()
        } else if(touchStartView == contentView.sidebar.becomeQTItem) {
            navigationController?.pushViewController(BecomeTutor(), animated: true)
            hideSidebar()
            hideBackground()
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
