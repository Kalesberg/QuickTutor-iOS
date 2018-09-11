//
//  Reviews.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI
import SDWebImage

class LearnerReviewsView : MainLayoutTitleOneButton {
    
    var backButton = NavbarButtonXLight()
    
    override var leftButton: NavbarButton {
        get {
            return backButton
        }
        set {
            backButton = newValue as! NavbarButtonXLight
        }
    }
    
    let tableView  : UITableView = {
        let tableView = UITableView()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        tableView.isScrollEnabled = true
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = Colors.backgroundDark
        
        return tableView
    }()
    
    fileprivate var subtitleLabel = LeftTextLabel()
    
    override func configureView() {
        addSubview(tableView)
        addSubview(subtitleLabel)
        super.configureView()
        
        title.label.text = "Reviews"
        
        subtitleLabel.label.textAlignment = .left
        subtitleLabel.label.font = Fonts.createBoldSize(20)
        
        applyConstraints()
    }
    override func applyConstraints() {
        super.applyConstraints()
        
        subtitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom).inset(-20)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(subtitleLabel.snp.bottom).inset(-10)
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }
    }
}

class LearnerReviews : BaseViewController {
    
    let storageRef = Storage.storage().reference()
    
    override var contentView: LearnerReviewsView {
        return view as! LearnerReviewsView
    }

    var datasource = [TutorReview]() {
        didSet {
            contentView.subtitleLabel.label.text = "Reviews (\((datasource.count)))"
            contentView.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension LearnerReviews : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! TutorMyProfileLongReviewTableViewCell
        
        let data = datasource[indexPath.row]
        
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.nameLabel.text = data.studentName
        cell.reviewTextLabel.text = data.message
		cell.dateSubjectLabel.attributedText = NSMutableAttributedString().bold("\(data.rating) ★", 14, Colors.yellow).bold(" - \(data.date) - \(data.subject)", 13, Colors.grayText)
		
		cell.profilePic.sd_setImage(with: storageRef.child("student-info").child(data.reviewerId).child("student-profile-pic1"), placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
		
		cell.applyConstraints()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class CustomReviewCell : UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    var profilePic = UIImageView()
    var nameLabel = UILabel()
    var dateSubjectLabel = UILabel()
    var reviewTextLabel = UILabel()
    
    func configureTableViewCell() {
        addSubview(profilePic)
        addSubview(nameLabel)
        addSubview(dateSubjectLabel)
        addSubview(reviewTextLabel)

        let cellBackground = UIView()
        cellBackground.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        selectedBackgroundView = cellBackground
        
        backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
        
        profilePic.scaleImage()
        
        nameLabel.textColor = .white
        nameLabel.font = Fonts.createBoldSize(18)
        
        dateSubjectLabel.textColor = Colors.grayText
        dateSubjectLabel.font = Fonts.createSize(13)
        
        reviewTextLabel.textColor = Colors.grayText
        reviewTextLabel.font = Fonts.createItalicSize(15)
        reviewTextLabel.numberOfLines = 3
        reviewTextLabel.lineBreakMode = .byWordWrapping
        
        applyConstraints()
    }
    
    func applyConstraints() {
        profilePic.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(profilePic.snp.right).inset(-10)
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }
        
        dateSubjectLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).inset(-8)
            make.centerY.equalTo(nameLabel)
        }
        
        reviewTextLabel.snp.makeConstraints { (make) in
            make.left.equalTo(profilePic.snp.right).inset(-10)
            make.centerY.equalToSuperview().multipliedBy(1.4)
            make.right.equalToSuperview()
        }
    }
}
