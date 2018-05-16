//
//  InviteOthers.swift
//  QuickTutor
//
//  Created by QuickTutor on 5/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class InviteOthersView : MainLayoutTitleBackTwoButton {
    
    var inviteButton = NavbarButtonInvite()
    
    let container : UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.green
        view.layer.cornerRadius = 5
        
        return view
    }()
    
    let label : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(16)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Share QuickTutor with your friends and family. Invite them to join the party! 🎉"
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    let tableView : UITableView = {
        let tableView = UITableView()
        
        tableView.rowHeight = 40
        tableView.backgroundColor = Colors.registrationDark
        tableView.isScrollEnabled = true
        tableView.separatorInset.left = 0
        tableView.separatorColor = Colors.divider
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = true
        tableView.backgroundView = InviteOthersTableViewBackground()
        
        return tableView
    }()
    
    override var rightButton: NavbarButton {
        get {
            return inviteButton
        } set {
            inviteButton = newValue as! NavbarButtonInvite
        }
    }
    
    override func configureView() {
        addSubview(container)
        container.addSubview(label)
        addSubview(tableView)
        super.configureView()
        
        navbar.backgroundColor = Colors.green
        statusbarView.backgroundColor = Colors.green
        title.label.text = "Share QuickTutor"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        container.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(70)
            make.centerX.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom).inset(-20)
        }
        
        label.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(5)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(container.snp.bottom).inset(-20)
            make.width.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
}


class InviteOthersTableViewBackground : BaseView {
    
    let label : UILabel = {
        let label = UILabel()
        
        let formattedString = NSMutableAttributedString()
        
        formattedString
            .bold("Connect your Contacts\n", 24, .white)
            .regular("\nConnect your phone contacts to invite some peeps!", 17, .white)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
        
        label.attributedText = formattedString
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.width.equalTo(250)
            make.center.equalToSuperview()
        }
    }
}


class InviteOthers : BaseViewController {
    
    override var contentView: InviteOthersView {
        return view as! InviteOthersView
    }
    
    override func loadView() {
        view = InviteOthersView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func handleNavigation() {
        if touchStartView is NavbarButtonInvite {
            
        }
    }
}

extension InviteOthers : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let label : UILabel = {
            let label = UILabel()
            
            label.text = "Austin F'in Welch"
            label.font = Fonts.createBoldSize(14)
            label.textColor = .white
            
            return label
        }()
        
        cell.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview()
        }
        
        return cell
    }
}
