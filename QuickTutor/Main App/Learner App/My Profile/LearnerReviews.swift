//
//  Reviews.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

struct Review {
	let fname : String!
	let lname : String!
	let rating : String!
}

class LearnerReviewsView : MainLayoutTitleBackButton {
	
	var tableView = UITableView()
	fileprivate var subtitleLabel 	= LeftTextLabel()

    override func configureView() {
		addSubview(tableView)
		addSubview(subtitleLabel)
        super.configureView()
        
        title.label.text = "Reviews"
		
		subtitleLabel.label.text = "22 Reviews"
		subtitleLabel.label.textAlignment = .left
		subtitleLabel.label.font = Fonts.createBoldSize(20)
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 80
		tableView.isScrollEnabled = true
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.backgroundColor = UIColor(red: 0.1534448862, green: 0.1521476209, blue: 0.1913509965, alpha: 1)
		
		applyConstraints()
    }
	override func applyConstraints() {
		super.applyConstraints()
		
		subtitleLabel.snp.makeConstraints { (make) in
			make.top.equalTo(navbar.snp.bottom)
			make.width.equalToSuperview().multipliedBy(0.85)
			make.height.equalToSuperview().multipliedBy(0.1)
			make.centerX.equalToSuperview()
		}
		
		tableView.snp.makeConstraints { (make) in
			make.top.equalTo(subtitleLabel.snp.bottom).inset(-20)
			make.width.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.8)
			make.centerX.equalToSuperview()
		}
	}
}

class LearnerReviews : BaseViewController {
    
    override var contentView: LearnerReviewsView {
        return view as! LearnerReviewsView
    }
    var reviews = ["1", "2", "4"]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		contentView.tableView.register(CustomReviewCell.self, forCellReuseIdentifier: "reviewCell")
    }
    
    override func loadView() {
        view = LearnerReviewsView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        
    }
}

extension LearnerReviews : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return reviews.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.estimatedRowHeight
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell : CustomReviewCell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! CustomReviewCell
		cell.reviewTextLabel.text = "Such a great time over there doing over there things over there"
		cell.dateSubjectLabel.text = "Dec 17th, 2018 - Biology"
		cell.nameLabel.text = "Austin Welch"
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//would probably want to show a message here saying that this will set the new card as Default.
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		return "Remove Card"
	}
	
	
	func insertBorder(cell: UITableViewCell) {
		let border = UIView(frame:CGRect(x: 0, y: cell.contentView.frame.size.height - 1.0, width: cell.contentView.frame.size.width, height: 1))
		border.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
		cell.contentView.addSubview(border)
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
		
		if let image = LocalImageCache.localImageManager.getImage(number: "1") {
			profilePic.image = image
		} else {
			//set to some arbitrary image.
		}
		
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
			make.left.equalToSuperview().inset(10)
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
