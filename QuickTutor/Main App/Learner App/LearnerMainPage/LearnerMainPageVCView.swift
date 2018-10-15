//
//  LearnerMainPageVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 9/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class LearnerMainPageVCView: MainPageVCView {
    var search = SearchBar()
    var learnerSidebar = LearnerSideBar()
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedSectionHeaderHeight = 50
        tableView.sectionHeaderHeight = 50
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.register(FeaturedTutorTableViewCell.self, forCellReuseIdentifier: "tutorCell")
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "categoryCell")
        return tableView
    }()
    
    override var sidebar: Sidebar {
        get {
            return learnerSidebar
        } set {
            if newValue is LearnerSideBar {
                learnerSidebar = newValue as! LearnerSideBar
            } else {
                print("incorrect sidebar type for LearnerMainPage")
            }
        }
    }
    
    override func configureView() {
        super.configureView()
        navbar.backgroundColor = Colors.learnerPurple
        statusbarView.backgroundColor = Colors.learnerPurple
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        setupSearchBar()
        setupTableView()
    }
    
    func setupSearchBar() {
        navbar.addSubview(search)
        search.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalToSuperview().multipliedBy(0.65)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    func setupTableView() {
        insertSubview(tableView, belowSubview: navbar)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sidebar.profileView.backgroundColor = UIColor(hex: "6562C9")
        tableView.layoutSubviews()
        tableView.layoutIfNeeded()
    }
}
