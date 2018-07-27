//
//  TutorTips.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorMainTipsView : MainLayoutTitleOneButton {
	
	var backButton = NavbarButtonX()
	
	override var leftButton: NavbarButton {
		get {
			return backButton
		}
		set {
			backButton = newValue as! NavbarButtonX
		}
	}
	
    let tableView : UITableView = {
        let tableView = UITableView()
        
        if UIScreen.main.bounds.height == 568 || UIScreen.main.bounds.height == 480 {
            tableView.rowHeight = 300
        } else {
            tableView.rowHeight = 280
        }
        
        tableView.isScrollEnabled = true
        tableView.separatorInset.left = 0
        tableView.separatorColor = Colors.divider
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.alwaysBounceVertical = true
        
        return tableView
    }()
    
    let backgroundImageView : UIImageView = {
        let view = UIImageView()
        
        view.image = #imageLiteral(resourceName: "dark-pattern").alpha(0.6)
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    override func configureView() {
        addSubview(backgroundImageView)
        addSubview(tableView)
        super.configureView()
		
		backButton.image.image = #imageLiteral(resourceName: "back-button")
        title.label.text = "Tutor Tips"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        backgroundImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.bottom.centerX.width.equalToSuperview()
        }
    }
}

class TutorMainTips : BaseViewController {
    
    override var contentView: TutorMainTipsView {
        return view as! TutorMainTipsView
    }
    override func loadView() {
        view = TutorMainTipsView()
    }
    
    let headers = ["How to Connect with Learners", "Adjust your Preferences", "Increase Learner Connection Requests"]
    let verbiage = ["Once you build a profile, you wait for learners to send you connection requests. You can increase your chances of recieving more connection requests by adding as many subjects as you are capable of tutoring to your profile, under \"Edit Profile.\"", "Your preferences are your hourly price as a tutor, whether you'd like to do video calling sessions, and how far you are willing to travel for a tutoring session.  You set them up in registration when you first made your account. You can adjust your preferences by selecting the \"Edit Profile\" button on your profile (top right).", "You can increase the number of learner requests you receive by setting up your policies, adding more subjects to your profile, uploading more than one profile picture, or increasing the amount of detail in your biography so that learners know you're the real deal."]
    let images = [#imageLiteral(resourceName: "small-illustration2"), #imageLiteral(resourceName: "small-illustration1"), #imageLiteral(resourceName: "small-illustration3")]
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        
        contentView.tableView.register(TutorTipsTableViewCell.self, forCellReuseIdentifier: "tutorTipsTableViewCell")
    }
	override func handleNavigation() {
		if touchStartView is NavbarButtonX {
			contentView.backgroundImageView.isHidden = true
			navigationController?.popViewController(animated: true)
		}
	}
}

extension TutorMainTips : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tutorTipsTableViewCell", for: indexPath) as! TutorTipsTableViewCell
        
        cell.headerLabel.text = headers[indexPath.row]
        cell.img.image = images[indexPath.row]
        cell.verbiageLabel.text = verbiage[indexPath.row]
        
        return cell
    }
}

class TutorTipsTableViewCell : UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    let headerLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    let verbiageLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createSize(14)
        label.numberOfLines = 0
        
        return label
    }()
    
    let img = UIImageView()
    
    func configureView() {
        addSubview(headerLabel)
        addSubview(img)
        addSubview(verbiageLabel)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        applyConstraints()
    }
    
    func applyConstraints() {
        headerLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(20)
        }
        
        img.snp.makeConstraints { (make) in
            make.top.equalTo(headerLabel.snp.bottom).inset(-20)
            make.left.equalToSuperview().inset(20)
        }
        
        verbiageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(img.snp.bottom).inset(-20)
            make.left.right.equalToSuperview().inset(20)
            
        }
    }
}
