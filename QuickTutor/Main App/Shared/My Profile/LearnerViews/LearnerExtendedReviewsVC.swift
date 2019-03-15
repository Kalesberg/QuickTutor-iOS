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

class LearnerReviewsView: MainLayoutTitleOneButton {
    var backButton = NavbarButtonXLight()

    override var leftButton: NavbarButton {
        get { return backButton }
        set { backButton = newValue as! NavbarButtonXLight }
    }

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
		tableView.separatorInset.left = 0
		tableView.separatorColor = Colors.navBarColor
        tableView.backgroundColor = Colors.navBarColor
		tableView.showsVerticalScrollIndicator = false
        return tableView
    }()

    override func configureView() {
        addSubview(tableView)
        super.configureView()

        title.label.text = "Reviews"
		backgroundColor = Colors.navBarColor
		
        applyConstraints()
    }

    override func applyConstraints() {
        super.applyConstraints()
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navbar.snp.bottom).inset(-1)
            make.width.equalToSuperview().multipliedBy(0.98)
			make.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }
}

class LearnerReviewsVC: BaseViewController {
    let storageRef = Storage.storage().reference()

    override var contentView: LearnerReviewsView {
        return view as! LearnerReviewsView
    }

    var datasource = [Review]() {
        didSet {
            contentView.tableView.reloadData()
        }
    }

    var isViewing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.navbar.backgroundColor = isViewing ? Colors.purple : Colors.purple
        contentView.statusbarView.backgroundColor = isViewing ? Colors.purple : Colors.purple

        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(TutorMyProfileLongReviewTableViewCell.self, forCellReuseIdentifier: "reviewCell")
    }

    override func loadView() {
        view = LearnerReviewsView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func handleNavigation() {
        if touchStartView is NavbarButtonXLight {
			self.navigationController?.popViewController(animated: true)
		}
    }
}

extension LearnerReviewsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! TutorMyProfileLongReviewTableViewCell

        let data = datasource[indexPath.row]
		cell.minHeight = 75
        cell.isViewing = isViewing

		cell.dateLabel.text = "\(data.formattedDate)"
		cell.reviewTextLabel.text = "\"\(data.message)\""
		let formattedName = data.studentName.split(separator: " ")
		cell.nameLabel.textColor = isViewing ? Colors.purple : Colors.purple
        cell.nameLabel.text = "\(String(formattedName[0]).capitalized) \(String(formattedName[1]).capitalized.prefix(1))."
        cell.subjectLabel.attributedText = NSMutableAttributedString().bold("\(data.rating) ★", 14, Colors.gold).bold(" - \(data.subject)", 13, .white)
        cell.profilePic.sd_setImage(with: storageRef.child("student-info").child(data.reviewerId).child("student-profile-pic1"), placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
	
		return cell
    }
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 50
	}
	
    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()

        label.text = "Reviews (\((datasource.count)))"
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.95)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(5)
        }
        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		FirebaseData.manager.fetchTutor(datasource[indexPath.row].reviewerId, isQuery: false) { (tutor) in
			if let tutor = tutor {
                let controller = QTProfileViewController.controller
                controller.user = tutor
                controller.profileViewType = .tutor
				self.navigationController?.pushViewController(controller, animated: true)
			}
		}
    }
}
