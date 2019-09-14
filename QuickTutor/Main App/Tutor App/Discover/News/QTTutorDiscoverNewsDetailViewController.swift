//
//  QTTutorDiscoverNewsDetailViewController.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/13/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import MXParallaxHeader

class QTTutorDiscoverNewsDetailViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    var news: QTNewsModel!
    
    // MARK: - Functions
    func configureViews() {
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .clear
        
        // Register reusable cells.
        tableView.register(QTTutorDiscoverNewsDetailDescTableViewCell.nib,
                           forCellReuseIdentifier: QTTutorDiscoverNewsDetailDescTableViewCell.reuseIdentifier)
        tableView.register(QTTutorDiscoverNewsDetailContentTableViewCell.nib,
                           forCellReuseIdentifier: QTTutorDiscoverNewsDetailContentTableViewCell.reuseIdentifier)
        
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupParallaxHeader() {
        
        let headerView = QTTutorDiscoverNewsDetailParallaxHeaderView.view
        tableView.parallaxHeader.view = headerView
        tableView.parallaxHeader.height = 286
        tableView.parallaxHeader.mode = .fill
        tableView.parallaxHeader.minimumHeight = 0
        
        headerView.setData(news: news)
    }
    
    // MARK: - Actionts
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupParallaxHeader()
        configureViews()
    }
}

// MARK: - UITableViewDelegate
extension QTTutorDiscoverNewsDetailViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension QTTutorDiscoverNewsDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return news.contents.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: QTTutorDiscoverNewsDetailDescTableViewCell.reuseIdentifier,
                                                     for: indexPath) as! QTTutorDiscoverNewsDetailDescTableViewCell
            cell.setData(news: news)
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: QTTutorDiscoverNewsDetailContentTableViewCell.reuseIdentifier,
                                                     for: indexPath) as! QTTutorDiscoverNewsDetailContentTableViewCell
            cell.setData(content: news.contents[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
    }
}

// MARK: - UIScrollViewDelegate
extension QTTutorDiscoverNewsDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let nav = self.navigationController {
            let height = nav.navigationBar.frame.origin.y + nav.navigationBar.frame.size.height
            if scrollView.contentOffset.y >= -height + 60 {
                navigationController?.navigationBar.isTranslucent = false
                navigationController?.navigationBar.backgroundColor = Colors.newNavigationBarBackground.withAlphaComponent(max(height + scrollView.contentOffset.y, 0) / height)
                title = news.title
            } else {
                navigationController?.navigationBar.isTranslucent = true
                navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
                navigationController?.navigationBar.shadowImage = UIImage()
                navigationController?.navigationBar.backgroundColor = .clear
                navigationController?.navigationBar.alpha = 1
                title = ""
            }
        }
    }
}
