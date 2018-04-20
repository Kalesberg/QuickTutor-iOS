//
//  TrendingCategories.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TrendingCategoriesView : MainLayoutTitleBackButton {
    
    let titleLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(18)
        label.text = "Top Categories"
        label.textColor = .white
        
        return label
    }()
    
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
        addSubview(titleLabel)
        addSubview(tableView)
        super.configureView()
        
        title.label.text = "Trending Categories"

    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom).inset(-20)
            make.left.equalToSuperview().inset(15)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).inset(-10)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}

class TrendingCategories : BaseViewController {
    
    override var contentView: TrendingCategoriesView {
        return view as! TrendingCategoriesView
    }
    override func loadView() {
        view = TrendingCategoriesView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "categoryCell")
    }
}

extension TrendingCategories : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIScreen.main.bounds.height == 568 {
            return 180
        } else {
            return 210
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
