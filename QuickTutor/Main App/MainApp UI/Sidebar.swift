//
//  Sidebar.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import FirebaseUI
import SDWebImage

class TutorSideBar : Sidebar {
    
    override func configureView() {
        super.configureView()
        
        becomeQTItem.label.label.text = "Start Learning"
        ratingView.titleLabel.text = "Your Tutor Rating"
        
        let blueTextColor = UIColor(hex: "5E90E6")
        
        moreLabel.textColor = blueTextColor
        ratingView.titleLabel.textColor = blueTextColor
        optionsLabel.textColor = blueTextColor
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        paymentItem.snp.makeConstraints { (make) in
            make.top.equalTo(optionsLabel.snp.bottom).inset(-10)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.065)
        }
        
        settingsItem.snp.makeConstraints { (make) in
            make.top.equalTo(paymentItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.065)
        }
        
        reportItem.snp.makeConstraints { (make) in
            make.top.equalTo(settingsItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.065)
        }
        
        becomeQTItem.snp.makeConstraints { (make) in
            make.top.equalTo(reportItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.065)
        }
        
        legalItem.snp.makeConstraints { (make) in
            make.top.equalTo(moreLabel.snp.bottom).inset(-10)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.055)
        }
        
        helpItem.snp.makeConstraints { (make) in
            make.top.equalTo(legalItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.055)
        }
        
        shopItem.snp.makeConstraints { (make) in
            make.top.equalTo(helpItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.055)
        }
    }
}

class LearnerSideBar : Sidebar {
    
    override func configureView() {
        super.configureView()
    
        ratingView.titleLabel.text = "Your Learner Rating"
        
        let purpleTextColor = UIColor(hex: "7A75FF")
        
        moreLabel.textColor = purpleTextColor
        ratingView.titleLabel.textColor = purpleTextColor
        optionsLabel.textColor = purpleTextColor
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        paymentItem.snp.makeConstraints { (make) in
            make.top.equalTo(optionsLabel.snp.bottom).inset(-10)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.065)
        }
        
        settingsItem.snp.makeConstraints { (make) in
            make.top.equalTo(paymentItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.065)
        }
        
        reportItem.snp.makeConstraints { (make) in
            make.top.equalTo(settingsItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.065)
        }
        
        becomeQTItem.snp.makeConstraints { (make) in
            make.top.equalTo(reportItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.065)
        }
        
        legalItem.snp.makeConstraints { (make) in
            make.top.equalTo(moreLabel.snp.bottom).inset(-10)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.055)
        }

        helpItem.snp.makeConstraints { (make) in
            make.top.equalTo(legalItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.055)
        }
        
        shopItem.snp.makeConstraints { (make) in
            make.top.equalTo(helpItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.055)
        }
    }
}

class Sidebar : BaseView {
	
	let storageRef = Storage.storage().reference(forURL: Constants.STORAGE_URL)
	
    var profileView       = ProfileView()
    var ratingView        = RatingView()
    
    var paymentItem       = PaymentSidebarItem()
    var settingsItem      = SettingsSidebarItem()
    var reportItem        = ReportSidebarItem()
    var becomeQTItem      = BecomeQTSidebarItem()
    
    var legalItem         = LegalSidebarItem()
    var helpItem          = HelpSidebarItem()
    var shopItem          = ShopSidebarItem()
    
    let optionsLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(14)
        label.text = "Options"
        
        return label
    }()
    
    let moreLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(14)
        label.text = "More"
        
        return label
    }()
    
    let inviteButton = InviteButton()
    
    static var manager = Sidebar()
    
    override func configureView() {
        super.configureView()
        addSubview(profileView)
        addSubview(ratingView)
        addSubview(optionsLabel)
        addSubview(inviteButton)
        addSubview(paymentItem)
        addSubview(settingsItem)
        addSubview(reportItem)
        addSubview(becomeQTItem)
        addSubview(moreLabel)
        addSubview(legalItem)
        addSubview(helpItem)
        addSubview(shopItem)
        
        layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.5, offset: CGSize(width: 0, height: 1.5), radius: 3.0)
		
        backgroundColor = Colors.registrationDark
		
        applyConstraints()
    }
    
    override func applyConstraints() {
        profileView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.15)
        }
        
        ratingView.snp.makeConstraints { (make) in
            make.top.equalTo(profileView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.12)
        }
        
        optionsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(ratingView.snp.bottom).inset(-5)
            make.left.equalToSuperview().inset(17)
        }
        
        moreLabel.snp.makeConstraints { (make) in
            make.top.equalTo(becomeQTItem.snp.bottom).inset(-15)
            make.left.equalToSuperview().inset(17)
        }
        
        inviteButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            if UIScreen.main.bounds.height == 480 {
                make.bottom.equalToSuperview().inset(3)
                make.height.equalTo(40)
            } else {
                make.bottom.equalToSuperview().inset(10)
                make.height.equalTo(45)
            }
            
            
        }
    }
	override func layoutSubviews() {
		super.layoutSubviews()
	}

    deinit {
        print("SideBar Deinit")
    }
}


class InviteButton : InteractableBackgroundView {
    
    let label : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(17)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Invite others to QT!"
        
        return label
    }()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        backgroundColor = Colors.green
        layer.cornerRadius = 5
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

class ProfileView : InteractableBackgroundView {
    
    var profileView = BaseView()
	let profilePicView : UIImageView = {
		let imageView = UIImageView()
		
		imageView.layer.masksToBounds = false
		imageView.clipsToBounds = true
		imageView.scaleImage()
		
		return imageView
	}()
    var profileNameView   = UILabel()
    
    override func configureView() {
		addSubview(profileView)
        super.configureView()
		
        layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.5, offset: CGSize(width: 0, height: 1.5), radius: 3.0)

        profileView.addSubview(profilePicView)
        profileView.addSubview(profileNameView)
        
        backgroundView.isUserInteractionEnabled = false
		
        profileNameView.font = Fonts.createBoldSize(16)
        profileNameView.numberOfLines = 0
		profilePicView.backgroundColor = .black
        applyConstraints()
    }
    
    override func applyConstraints() {
        
        profileView.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.5)
            make.bottom.equalToSuperview().inset(10)
            make.left.equalToSuperview().inset(10)
            make.right.equalToSuperview()
        }
        
        profilePicView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
			make.width.equalTo(profilePicView.snp.height)
        }
        
        profileNameView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalTo(profilePicView.snp.right).inset(-10)
            make.right.equalToSuperview()
        }
    }
}


class RatingView : InteractableView {
    
    let titleLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(14)
        
        return label
    }()
    
    let ratingLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(14)
        label.textColor = UIColor(hex: "996910")
        label.textAlignment = .center
        
        return label
    }()
    
    let container : UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.gold
        view.layer.cornerRadius = 12
        
        return view
    }()
    
    override func configureView() {
        addSubview(titleLabel)
        addSubview(container)
        container.addSubview(ratingLabel)
        super.configureView()

        applyConstraints()
    }
    
    override func applyConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().multipliedBy(0.6)
            make.left.equalToSuperview().inset(17)
        }
        
        container.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().multipliedBy(1.3)
            make.left.equalToSuperview().inset(17)
            make.height.equalTo(24)
            make.width.equalTo(55)
        }
        
        ratingLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}


class SidebarItem : InteractableBackgroundView {
    
    var label = LeftTextLabel()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        label.label.font = Fonts.createSize(18)
        label.label.textColor = UIColor(hex: "919199")
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(17)
            make.height.equalToSuperview()
        }
    }
}

class LegalSidebarItem : SidebarItem {
    
    override func configureView() {
        super.configureView()
        
        label.label.text = "Legal"
    }
}


class HelpSidebarItem : SidebarItem {
    
    override func configureView() {
        super.configureView()
        
        label.label.text = "Help"
    }
}


class ShopSidebarItem : SidebarItem {
    
    override func configureView() {
        super.configureView()
        
        label.label.text = "Shop"
    }
}


class SidebarItemIcon : SidebarItem {
    
    var icon = UIImageView()
    
    override func configureView() {
        addSubview(icon)
        super.configureView()
        
        icon.isUserInteractionEnabled = false
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        icon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(17)
        }
        
        label.snp.remakeConstraints { (make) in
            make.left.equalTo(icon.snp.right).inset(-12)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}


class PaymentSidebarItem : SidebarItemIcon {
    override func configureView() {
        super.configureView()
        
        icon.image = UIImage(named: "sidebar-payment")
        label.label.text = "Payment"
    }
}


class SettingsSidebarItem : SidebarItemIcon {
    override func configureView() {
        super.configureView()
        
        icon.image = UIImage(named: "sidebar-settings")
        label.label.text = "Settings"
    }
}


class ReportSidebarItem : SidebarItemIcon {
    override func configureView() {
        super.configureView()
        
        icon.image = UIImage(named: "sidebar-report")
        label.label.text = "File Report"
    }
}


class BecomeQTSidebarItem : SidebarItemIcon {
    override func configureView() {
        super.configureView()
        
        icon.image = UIImage(named: "sidebar-qt")
        label.label.text = "Become a QuickTutor"
    }
}

class TaxSidebarItem : SidebarItem {
    override func configureView() {
        super.configureView()

        label.label.text = "Tax Information"
    }
}
