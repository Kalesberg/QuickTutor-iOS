//
//  TutorManagePolicies.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/2/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorManagePoliciesView : MainLayoutTitleBackButton {
    
    let tableView : UITableView = {
        let tableView = UITableView()
        
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 250
        tableView.isScrollEnabled = true
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        return tableView
    }()
    
    override func configureView() {
        addSubview(tableView)
        super.configureView()
        
        title.label.text = "Manage Policies"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom).inset(-20)
            make.leading.equalTo(layoutMarginsGuide.snp.leading)
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
}


class TutorManagePolicies : BaseViewController {
    
    override var contentView: TutorManagePoliciesView {
        return view as! TutorManagePoliciesView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(EditProfilePolicyTableViewCell.self, forCellReuseIdentifier: "editProfilePolicyTableViewCell")
        contentView.tableView.register(EditProfileHeaderTableViewCell.self, forCellReuseIdentifier: "editProfileHeaderTableViewCell")
    }
    override func loadView() {
        view = TutorManagePoliciesView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func handleNavigation() {
    }
}

extension TutorManagePolicies : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0:
            return 45
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return UITableViewAutomaticDimension
        case 3:
            return UITableViewAutomaticDimension
        case 4:
            return UITableViewAutomaticDimension
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.row) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileHeaderTableViewCell", for: indexPath) as! EditProfileHeaderTableViewCell
            
            cell.label.text = "Policies"
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfilePolicyTableViewCell", for: indexPath) as! EditProfilePolicyTableViewCell
            
            cell.infoLabel.label.text = "Late Policy"
            cell.textField.attributedText = NSAttributedString(string: "Enter how many minutes",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            cell.label.text = "How much time passes from the scheduled session before the learner is late?"
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfilePolicyTableViewCell", for: indexPath) as! EditProfilePolicyTableViewCell
            
            cell.infoLabel.label.text = "Late Fee"
            cell.textField.attributedText = NSAttributedString(string: "Enter late fee",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            cell.label.text = "How much learner pays if they arrive late to a session after the above time."
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfilePolicyTableViewCell", for: indexPath) as! EditProfilePolicyTableViewCell
            
            cell.infoLabel.label.text = "Cancellation Notice"
            cell.textField.attributedText = NSAttributedString(string: "Enter how many hours",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            cell.label.text = "How many hours before a session should a learner notify you of a cancellation?"
            
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfilePolicyTableViewCell", for: indexPath) as! EditProfilePolicyTableViewCell
            
            cell.infoLabel.label.text = "Cancellation Fee"
            cell.textField.attributedText = NSAttributedString(string: "Enter cancellation fee",
                                                               attributes: [NSAttributedStringKey.foregroundColor: Colors.grayText])
            cell.label.text = "How much learner pays if they cancel a session after the above time."
            
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
}
