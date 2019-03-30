//
//  LearnerEditProfileVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 1/10/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class LearnerEditProfileVCView: UIView, Keyboardable {
    
    var keyboardComponent = ViewComponent()
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 250
        tableView.isScrollEnabled = true
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(EditProfileImagesCell.self, forCellReuseIdentifier: "EditProfileImagesCell")
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: "editProfileCell")
        tableView.register(EditProfileBioCell.self, forCellReuseIdentifier: "editProfileBioCell")
        tableView.register(EditProfileHeaderTableViewCell.self, forCellReuseIdentifier: "editProfileHeaderTableViewCell")
        return tableView
    }()
    
    func setupViews() {
        addKeyboardView()
        setupMainView()
        setupTableView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupTableView() {
        addSubview(tableView)
        tableView.anchor(top: getTopAnchor(), left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
