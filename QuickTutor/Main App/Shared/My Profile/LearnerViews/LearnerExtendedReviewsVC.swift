//
//  Reviews.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import FirebaseUI
import Foundation
import SDWebImage
import UIKit

class LearnerReviewsView: UIView {

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = Colors.newScreenBackground
        tableView.backgroundColor = Colors.newScreenBackground
        tableView.showsVerticalScrollIndicator = false
        tableView.register(QTReviewTableViewCell.nib, forCellReuseIdentifier: QTReviewTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        return tableView
    }()

    func setupViews() {
        backgroundColor = Colors.newScreenBackground
        setupTableView()
    }
    
    func setupTableView() {
        addSubview(tableView)
        tableView.anchor(top: topAnchor, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LearnerReviewsVC: UIViewController {
    let storageRef = Storage.storage().reference()

    let contentView: LearnerReviewsView = {
        let view = LearnerReviewsView()
        return view
    }()

    var datasource = [Review]() {
        didSet {
            contentView.tableView.reloadData()
        }
    }

    var isViewing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        navigationItem.title = "Reviews"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        hideTabBar(hidden: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hideTabBar(hidden: false)
    }
    override func loadView() {
        view = contentView
    }
    
}

extension LearnerReviewsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QTReviewTableViewCell.reuseIdentifier, for: indexPath) as! QTReviewTableViewCell
        cell.selectionStyle = .none
        cell.backgroundColor = Colors.newScreenBackground
        cell.contentView.backgroundColor = Colors.newScreenBackground
        cell.setData(review: datasource[indexPath.row])
        return cell
    }
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0
	}

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		FirebaseData.manager.fetchTutor(datasource[indexPath.row].reviewerId, isQuery: false) { (tutor) in
			if let tutor = tutor {
                let controller = QTProfileViewController.controller
                controller.user = tutor
                controller.profileViewType = .tutor
                if tutor.uid == AccountService.shared.currentUser.uid {
                    controller.profileViewType = .myTutor
                } else {
                    controller.profileViewType = .tutor
                }
				self.navigationController?.pushViewController(controller, animated: true)
			}
		}
    }
}
