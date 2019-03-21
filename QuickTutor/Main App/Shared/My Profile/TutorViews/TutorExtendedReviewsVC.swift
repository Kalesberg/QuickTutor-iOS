//
//  Tutor.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/17/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import FirebaseUI
import Foundation
import SDWebImage
import UIKit


class TutorReviewsVCView: UIView {
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = Colors.navBarColor
        tableView.backgroundColor = Colors.navBarColor
        tableView.showsVerticalScrollIndicator = false
        tableView.register(QTReviewTableViewCell.nib, forCellReuseIdentifier: QTReviewTableViewCell.reuseIdentifier)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        return tableView
    }()
    
    func setupViews() {
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

class TutorReviewsVC: UIViewController {
	let storageRef = Storage.storage().reference()

    let contentView: TutorReviewsVCView = {
        let view = TutorReviewsVCView()
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
	
	override func loadView() {
		view = contentView
	}
	
}

extension TutorReviewsVC: UITableViewDelegate, UITableViewDataSource {
	func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		return datasource.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: QTReviewTableViewCell.reuseIdentifier, for: indexPath) as! QTReviewTableViewCell
        cell.selectionStyle = .none
        cell.backgroundColor = Colors.darkBackground
        cell.contentView.backgroundColor = Colors.darkBackground
        cell.setData(review: datasource[indexPath.row])
        return cell
    }
	
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		FirebaseData.manager.fetchLearner(datasource[indexPath.row].reviewerId) { learner in
			guard let learner = learner else { return }
            let controller = QTProfileViewController.controller
            let tutor = AWTutor(dictionary: [:])
            controller.user = tutor.copy(learner: learner)
            controller.profileViewType = .learner
            self.navigationController?.pushViewController(controller, animated: true)
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
