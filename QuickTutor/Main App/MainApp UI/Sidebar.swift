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

class TutorSideBar : Sidebar {
    
    var taxItem = TaxSidebarItem()
    
    override func configureView() {
        itemContainer.addSubview(taxItem)
        super.configureView()
        
        becomeQTItem.label.label.text = "Start Learning"
        ratingView.tutorOrLearnerLabel.text = "Tutor Rating:"
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        itemContainer.snp.remakeConstraints { (make) in
            make.top.equalTo(divider1.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.525)
        }
        
        paymentItem.snp.makeConstraints { (make) in
            make.top.equalTo(ratingView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.125)
        }
        
        settingsItem.snp.makeConstraints { (make) in
            make.top.equalTo(paymentItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.125)
        }
        
        reportItem.snp.makeConstraints { (make) in
            make.top.equalTo(settingsItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.125)
        }
        
        becomeQTItem.snp.makeConstraints { (make) in
            make.top.equalTo(reportItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.125)
        }
        
        divider2.snp.makeConstraints { (make) in
            make.top.equalTo(becomeQTItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        legalItem.snp.makeConstraints { (make) in
            make.top.equalTo(divider2.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.125)
        }
        
        helpItem.snp.makeConstraints { (make) in
            make.top.equalTo(legalItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.125)
        }
        
        taxItem.snp.makeConstraints { (make) in
            make.top.equalTo(helpItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.125)
        }
    }
    
}


class LearnerSideBar : Sidebar {
    
    override func configureView() {
        super.configureView()
    
        ratingView.tutorOrLearnerLabel.text = "Learner Rating:"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        itemContainer.snp.makeConstraints { (make) in
            make.top.equalTo(divider1.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.46)
        }
        
        paymentItem.snp.makeConstraints { (make) in
            make.top.equalTo(ratingView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.14285)
        }
        
        settingsItem.snp.makeConstraints { (make) in
            make.top.equalTo(paymentItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.14285)
        }
        
        reportItem.snp.makeConstraints { (make) in
            make.top.equalTo(settingsItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.14285)
        }
        
        becomeQTItem.snp.makeConstraints { (make) in
            make.top.equalTo(reportItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.14285)
        }
        
        divider2.snp.makeConstraints { (make) in
            make.top.equalTo(becomeQTItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        legalItem.snp.makeConstraints { (make) in
            make.top.equalTo(divider2.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.14285)
        }
        
        helpItem.snp.makeConstraints { (make) in
            make.top.equalTo(legalItem.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.14285)
        }
    }
    
}

class Sidebar : BaseView {
    
    var profileView       = ProfileView()
    var divider           = UIView()
    var ratingView        = RatingView()
    var divider1          = BaseView()
    
    var itemContainer     = UIView()
    var paymentItem       = PaymentSidebarItem()
    var settingsItem      = SettingsSidebarItem()
    var reportItem        = ReportSidebarItem()
    var becomeQTItem      = BecomeQTSidebarItem()
    var divider2          = BaseView()
    
    var legalItem         = LegalSidebarItem()
    var helpItem          = HelpSidebarItem()
    
    static var manager = Sidebar()
    
    override func configureView() {
        super.configureView()
        addSubview(profileView)
        addSubview(divider)
        addSubview(ratingView)
        addSubview(divider1)
        addSubview(itemContainer)
        itemContainer.addSubview(paymentItem)
        itemContainer.addSubview(settingsItem)
        itemContainer.addSubview(reportItem)
        itemContainer.addSubview(becomeQTItem)
        itemContainer.addSubview(divider2)
        itemContainer.addSubview(legalItem)
        itemContainer.addSubview(helpItem)
        
        layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.5, offset: CGSize(width: 0, height: 1.5), radius: 3.0)
        
        divider.backgroundColor = Colors.divider
        divider1.backgroundColor = Colors.divider
        divider2.backgroundColor = Colors.divider
		
        applyConstraints()
    }
    
    override func applyConstraints() {
        
        profileView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.15)
        }
        
        divider.snp.makeConstraints { (make) in
            make.top.equalTo(profileView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        ratingView.snp.makeConstraints { (make) in
            make.top.equalTo(profileView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.08)
        }
        
        divider1.snp.makeConstraints { (make) in
            make.top.equalTo(ratingView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    deinit {
        print("SideBar Deinit")
    }
}

class ProfileView : InteractableBackgroundView {
    
    var profileView       = BaseView()
    var profilePicView    = UIImageView() {
        didSet {
            print("set profile pic")
        }
    }
    var profileNameView   = UILabel()
    
    override func configureView() {
        super.configureView()

        addSubview(profileView)
        
        layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.5, offset: CGSize(width: 0, height: 1.5), radius: 3.0)

        profileView.addSubview(profilePicView)
        profileView.addSubview(profileNameView)
        
        backgroundView.isUserInteractionEnabled = false
        profilePicView.scaleImage()
        
        profileNameView.font = Fonts.createBoldSize(16)
        profileNameView.numberOfLines = 3
        
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
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.27)
        }
        
        profileNameView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.left.equalTo(profilePicView.snp.right).inset(-10)
            make.right.equalToSuperview().inset(3)
        }
    }
}


class RatingView : InteractableView {
    
    let starImageView : UIImageView = {
        let view = UIImageView()
        
        view.image = UIImage(named: "sidebar-star")
        
        return view
    }()
    let ratingLabel : UILabel = {
        let label = UILabel()
    
        label.font = Fonts.createBoldSize(14)
        label.textColor = .white
        
        return label
    }()
    let tutorOrLearnerLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createSize(16)
        label.textColor = .white
        
        return label
    }()
    
    override func configureView() {
        addSubview(starImageView)
        addSubview(ratingLabel)
        addSubview(tutorOrLearnerLabel)
        super.configureView()
		
        applyConstraints()
    }
    
    override func applyConstraints() {
        starImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(20)
        }
        
        ratingLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().inset(1)
            make.right.equalTo(starImageView.snp.left).inset(-5)
        }
        
        tutorOrLearnerLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }
}


class SidebarItem : InteractableBackgroundView {
    
    var label = LeftTextLabel()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        label.label.font = Fonts.createSize(18)
        
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
