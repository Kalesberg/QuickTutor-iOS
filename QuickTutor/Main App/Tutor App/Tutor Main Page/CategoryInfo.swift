//
//  CategoryInfo.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class CategoryInfoView : MainLayoutTitleBackButton {
    
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
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}


class CategoryInfo : BaseViewController {
    
    override var contentView: CategoryInfoView {
        return view as! CategoryInfoView
    }
    override func loadView() {
        view = CategoryInfoView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        
        contentView.title.label.text = category?.mainPageData.displayName
    }
    
    var category : Category? = nil
}

extension CategoryInfo : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0:
            return 350
        case 1:
            return UITableViewAutomaticDimension
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.row) {
        case 0:
            let cell = UITableViewCell()
            
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            
            let imageView : UIImageView = {
                let view = UIImageView()
                
                view.contentMode = .scaleAspectFill
                view.clipsToBounds = true
                view.layer.cornerRadius = 20
                view.layer.masksToBounds = true
                
                view.image = category?.mainPageData.image
                
                return view
            }()
            
            cell.contentView.addSubview(imageView)
            
            imageView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalTo(225)
                make.height.equalTo(300)
            }
            
            return cell
        
        case 1:
            let cell = UITableViewCell()
            
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            let label : UILabel = {
                let label = UILabel()
                
                let formattedString = NSMutableAttributedString()
                
                formattedString
                    .bold((category?.mainPageData.displayName)! + "\n", 24, .white)
                    .regular("\n", 20, .clear)
                    .regular((category?.mainPageData.categoryInfo)! + "\n", 15, .white)
                    .regular("\n", 20, .clear)
                    .regular("Sub-Categories\n", 20, .white)
                    .regular("\n", 10, .clear)
                    .regular((category?.subcategory.subcategories.compactMap({$0}).joined(separator: ", "))! + "\n\n", 15, Colors.grayText)
                
                label.attributedText = formattedString
                label.numberOfLines = 0
                
                return label
            }()
            
            cell.contentView.addSubview(label)
            
            label.snp.makeConstraints { (make) in
                make.top.left.right.bottom.equalToSuperview()
            }
            
            return cell
            
        default:
            break
        }
        
        return UITableViewCell()
    }
}
