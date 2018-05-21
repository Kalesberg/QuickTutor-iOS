//
//  NavbarButtons.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class NavbarButton : InteractableView {
    internal func allignLeft() {
        self.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.175)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
            make.left.equalToSuperview()
        }
    }
    
    internal func allignRight() {
        self.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.175)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
            make.right.equalToSuperview()
        }
    }
}


class NavbarButtonImage : NavbarButton, Interactable {
    
    var image = UIImageView()
    
    override func configureView() {
        addSubview(image)
        
        image.isUserInteractionEnabled = false
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        image.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    func touchStart() {
        image.alpha = 0.5
    }
    func didDragOff() {
        image.alpha = 1.0
    }
    func touchEndOnStart() {
        didDragOff()
    }
}


class NavbarButtonText : NavbarButton, Interactable {
    
    var label = CenterTextLabel()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        label.label.font = Fonts.createSize(16)
        label.applyConstraints()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.75)
            make.centerY.equalToSuperview()
        }
    }
    
    func touchStart() {
        label.label.alpha = 0.7
    }
    func didDragOff() {
        label.label.alpha = 1.0
    }
}

class NavbarButtonBack: NavbarButtonImage {
	
	static var enabled : Bool = true
	
    override func configureView() {
        super.configureView()
        
        image.image = UIImage(named: "back-button")
    }
    
    override func touchEndOnStart() {
        super.touchEndOnStart()
		if NavbarButtonBack.enabled {
			navigationController.popViewController(animated: true)
		}
    }
}


class NavbarButtonFilters: NavbarButtonImage {

    
    override func configureView() {
        super.configureView()
        
        image.image = UIImage(named: "navbar-filters")
    }
}


class NavbarButtonMessages: NavbarButtonImage {
    
    override func configureView() {
        super.configureView()
        
        image.image = UIImage(named: "navbar-messages")
    }
}


class NavbarButtonLines: NavbarButtonImage {
    
    override func configureView() {
        super.configureView()
        
        image.image = UIImage(named: "navbar-lines")
    }
}


class NavbarButtonX: NavbarButtonImage {
    
    override func configureView() {
        super.configureView()
        
        image.image = UIImage(named: "navbar-x")
    }
}

class NavbarButtonXLight: NavbarButtonImage {
    
    override func configureView() {
        super.configureView()
        
        image.image = UIImage(named: "xbuttonlight")
    }
}

class NavbarButtonEdit: NavbarButtonText {
    
    override func configureView() {
        super.configureView()
        
        label.label.text = "Edit"
    }
}


class NavbarButtonSave: NavbarButtonText {
    
    override func configureView() {
        super.configureView()
        
        label.label.text = "Save"
    }
}

class NavbarButtonDone: NavbarButtonText {
    
    override func configureView() {
        super.configureView()
        
        label.label.text = "Done"
    }
}

class NavbarButtonNext: NavbarButtonText {
    
    override func configureView() {
        super.configureView()
        
        label.label.text = "Next"
    }
}

class NavbarButtonSubmit: NavbarButtonText {
    
    override func configureView() {
        super.configureView()
        
        label.label.text = "Submit"
    }
}

class NavbarButtonInvite: NavbarButtonText {
    
    override func configureView() {
        super.configureView()
        
        label.label.text = "Invite"
    }
}

class NavbarButtonApply: NavbarButtonText {
    
    override func configureView() {
        super.configureView()
        
        label.label.text = "Apply"
    }
}
