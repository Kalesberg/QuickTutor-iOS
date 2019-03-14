////
////  Sidebar.swift
////  QuickTutor
////
////  Created by QuickTutor on 1/11/18.
////  Copyright © 2018 QuickTutor. All rights reserved.
////
//
//import FirebaseUI
//import Foundation
//import SDWebImage
//import SnapKit
//import UIKit
//
//class ProfileView: InteractableBackgroundView {
//    var profileView = BaseView()
//    let profilePicView: UIImageView = {
//        let imageView = UIImageView()
//
//        imageView.layer.masksToBounds = false
//        imageView.clipsToBounds = true
//        imageView.scaleImage()
//
//        return imageView
//    }()
//
//    var profileNameView = UILabel()
//
//    override func configureView() {
//        addSubview(profileView)
//        super.configureView()
//
//        layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.5, offset: CGSize(width: 0, height: 1.5), radius: 3.0)
//
//        profileView.addSubview(profilePicView)
//        profileView.addSubview(profileNameView)
//
//        backgroundView.isUserInteractionEnabled = false
//
//        profileNameView.font = Fonts.createBoldSize(16)
//        profileNameView.numberOfLines = 0
//        profilePicView.backgroundColor = .black
//        profilePicView.scaleImage()
//
//        applyConstraints()
//    }
//
//    override func applyConstraints() {
//        profileView.snp.makeConstraints { make in
//            make.height.equalToSuperview().multipliedBy(0.65)
//            make.bottom.equalToSuperview().inset(2)
//            make.left.equalToSuperview().inset(8)
//            make.right.equalToSuperview()
//        }
//
//        profilePicView.snp.makeConstraints { make in
//            make.left.equalToSuperview()
//            make.centerY.equalToSuperview()
//            make.height.equalToSuperview().multipliedBy(0.75)
//            make.width.equalTo(profilePicView.snp.height)
//        }
//
//        profileNameView.snp.makeConstraints { make in
//            make.top.equalToSuperview()
//            make.bottom.equalToSuperview()
//            make.left.equalTo(profilePicView.snp.right).inset(-10)
//            make.right.equalToSuperview()
//        }
//    }
//}
//
//class RatingView: InteractableView {
//    let titleLabel: UILabel = {
//        let label = UILabel()
//
//        label.font = Fonts.createBoldSize(14)
//
//        return label
//    }()
//
//    let ratingLabel: UILabel = {
//        let label = UILabel()
//
//        label.font = Fonts.createBoldSize(14)
//        label.textColor = UIColor(hex: "996910")
//        label.textAlignment = .center
//
//        return label
//    }()
//
//    let container: UIView = {
//        let view = UIView()
//
//        view.backgroundColor = Colors.gold
//        view.layer.cornerRadius = 12
//
//        return view
//    }()
//
//    override func configureView() {
//        addSubview(titleLabel)
//        addSubview(container)
//        container.addSubview(ratingLabel)
//        super.configureView()
//
//        applyConstraints()
//    }
//
//    override func applyConstraints() {
//        titleLabel.snp.makeConstraints { make in
//            make.centerY.equalToSuperview().multipliedBy(0.6)
//            make.left.equalToSuperview().inset(17)
//        }
//
//        container.snp.makeConstraints { make in
//            make.centerY.equalToSuperview().multipliedBy(1.3)
//            make.left.equalToSuperview().inset(17)
//            make.height.equalTo(24)
//            make.width.equalTo(55)
//        }
//
//        ratingLabel.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//    }
//}
//
//class SidebarItem: InteractableBackgroundView {
//    var label = LeftTextLabel()
//
//    override func configureView() {
//        addSubview(label)
//        super.configureView()
//
//        label.label.font = Fonts.createSize(18)
//        label.label.textColor = UIColor(hex: "919199")
//
//        applyConstraints()
//    }
//
//    override func applyConstraints() {
//        label.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.left.equalToSuperview().inset(17)
//            make.height.equalToSuperview()
//        }
//    }
//}
//
//class LegalSidebarItem: SidebarItem {
//    override func configureView() {
//        super.configureView()
//
//        label.label.text = "Legal"
//    }
//}
//
//class HelpSidebarItem: SidebarItem {
//    override func configureView() {
//        super.configureView()
//
//        label.label.text = "Help"
//    }
//}
//
//class ShopSidebarItem: SidebarItem {
//    override func configureView() {
//        super.configureView()
//
//        label.label.text = "Shop"
//    }
//}
//
//class SidebarItemIcon: SidebarItem {
//    var icon = UIImageView()
//
//    override func configureView() {
//        addSubview(icon)
//        super.configureView()
//
//        icon.isUserInteractionEnabled = false
//
//        applyConstraints()
//    }
//
//    override func applyConstraints() {
//        super.applyConstraints()
//
//        icon.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.left.equalToSuperview().inset(17)
//        }
//
//        label.snp.remakeConstraints { make in
//            make.left.equalTo(icon.snp.right).inset(-12)
//            make.top.equalToSuperview()
//            make.bottom.equalToSuperview()
//        }
//    }
//}
//
//class PaymentSidebarItem: SidebarItemIcon {
//    override func configureView() {
//        super.configureView()
//
//        icon.image = UIImage(named: "sidebar-payment")
//        label.label.text = "Payment"
//    }
//}
//
//class SettingsSidebarItem: SidebarItemIcon {
//    override func configureView() {
//        super.configureView()
//
//        icon.image = UIImage(named: "sidebar-settings")
//        label.label.text = "Settings"
//    }
//}
//
//class ReportSidebarItem: SidebarItemIcon {
//    override func configureView() {
//        super.configureView()
//
//        icon.image = UIImage(named: "sidebar-history")
//        label.label.text = "Past Sessions"
//    }
//}
//
//class BecomeQTSidebarItem: SidebarItemIcon {
//    override func configureView() {
//        super.configureView()
//
//        icon.image = UIImage(named: "sidebar-qt")
//        label.label.text = "Become a QuickTutor"
//    }
//}
//
//class TaxSidebarItem: SidebarItem {
//    override func configureView() {
//        super.configureView()
//
//        label.label.text = "Tax Information"
//    }
//}
