//
//  MyProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI

protocol UpdatedTutorCallBack : class {
    func tutorWasUpdated(tutor: AWTutor!)
}


class TutorMyProfileView : LearnerMyProfileView {
    
    override func configureView() {
        super.configureView()
        
        title.label.text = "My Profile"
        statusbarView.backgroundColor = Colors.tutorBlue
        navbar.backgroundColor = Colors.tutorBlue
    
    }
}

class TutorMyProfile : BaseViewController, UpdatedTutorCallBack {
    
    let storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)

    override var contentView: TutorMyProfileView {
        return view as! TutorMyProfileView
    }
    
    func tutorWasUpdated(tutor: AWTutor!) {
        self.tutor = tutor
        let name = tutor.name.split(separator: " ")
        contentView.name.text = "\(String(name[0])) \(String(name[1]).prefix(1))."
    }
    
    var tutor : AWTutor! {
        didSet {
            contentView.tableView.reloadData()
        }
    }
    
    var isViewing : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDelegates()
        
        let name = tutor.name.split(separator: " ")
        contentView.name.text = "\(String(name[0])) \(String(name[1]).prefix(1))."
        //cell.locationLabel.text = tutor.region
        let reference = storageRef.child("student-info").child(tutor.uid).child("student-profile-pic1")
        contentView.profilePics.sd_setImage(with: reference, placeholderImage: nil)

        //cell.ratingLabel.text = String(tutor.tRating)
    }
    
    override func loadView() {
        view = TutorMyProfileView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.nameContainer.backgroundColor = UIColor(hex: "4267a8")
    }
    
    private func configureDelegates() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        
        contentView.tableView.register(ProfilePicTableViewCell.self, forCellReuseIdentifier: "profilePicTableViewCell")
        contentView.tableView.register(AboutMeTableViewCell.self, forCellReuseIdentifier: "aboutMeTableViewCell")
        contentView.tableView.register(SubjectsTableViewCell.self, forCellReuseIdentifier: "subjectsTableViewCell")
        contentView.tableView.register(PoliciesTableViewCell.self, forCellReuseIdentifier: "policiesTableViewCell")
        contentView.tableView.register(RatingTableViewCell.self, forCellReuseIdentifier: "ratingTableViewCell")
        contentView.tableView.register(NoRatingsTableViewCell.self, forCellReuseIdentifier: "noRatingsTableViewCell")
        contentView.tableView.register(ExtraInfoCardTableViewCell.self, forCellReuseIdentifier: "extraInfoTableViewCell")
    }
    
    override func handleNavigation() {
        if (touchStartView is NavbarButtonEdit) {
            let next = TutorEditProfile()
            next.tutor = self.tutor
            next.delegate = self
            navigationController?.pushViewController(next, animated: true)
        } else if(touchStartView is TutorCardProfilePic) {
            self.displayProfileImageViewer(imageCount: tutor.images.filter({$0.value != ""}).count, userId: tutor.uid)
        }
    }
}

extension TutorMyProfile : ProfileImageViewerDelegate {
    func dismiss() {
        self.dismissProfileImageViewer()
    }
}

extension TutorMyProfile : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0:
            if UIScreen.main.bounds.height < 570 {
                return 250
            } else {
                return 290
            }
        case 1,2,4,5:
            return UITableViewAutomaticDimension
        case 3:
            return 90
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.row) {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "profilePicTableViewCell", for: indexPath) as! ProfilePicTableViewCell

            let name = tutor.name.split(separator: " ")
            cell.nameLabel.text = "\(String(name[0])) \(String(name[1]).prefix(1))."
            cell.profilePicView.loadUserImages(by: tutor.images["image1"]!)
            cell.ratingLabel.text = tutor.reviews?.count.formatReviewLabel(rating: tutor.tRating)
            cell.ratingLabel.font = Fonts.createSize(14)
            
            cell.ratingLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(cell.nameLabel.snp.bottom).inset(-13)
                make.right.equalToSuperview().inset(-14)
                make.width.equalToSuperview().multipliedBy(0.50)
            }
            
            let backgroundView : UIView = {
                let view = UIView()
                view.backgroundColor = Colors.green
                view.layer.cornerRadius = 11
                return view
            }()
            
            let label : UILabel = {
                let label = UILabel()
                label.font = Fonts.createBoldSize(14)
                label.textColor = .white
                label.textAlignment = .center
                return label
            }()
            
            label.text = "$" + String(tutor.price) + " / hour"
            
            cell.addSubview(backgroundView)
            backgroundView.addSubview(label)
            
            backgroundView.snp.makeConstraints { (make) in
                make.centerY.equalTo(cell.ratingLabel.snp.centerY)
                make.right.equalTo(cell.ratingLabel.snp.left).inset(-28)
                make.height.equalTo(22)
                make.width.equalTo(label).inset(-12)
            }
            
            label.snp.makeConstraints { (make) in
                make.center.equalTo(backgroundView)
            }

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutMeTableViewCell", for: indexPath) as! AboutMeTableViewCell
            
            cell.bioLabel.text = tutor.tBio + "\n"
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "extraInfoTableViewCell", for: indexPath) as! ExtraInfoCardTableViewCell
            
            for view in cell.contentView.subviews {
                view.snp.removeConstraints()
            }
            
            cell.speakItem.removeFromSuperview()
            cell.studysItem.removeFromSuperview()
            
            cell.locationItem.label.text = tutor.region
            
            cell.locationItem.snp.makeConstraints { (make) in
                make.left.equalToSuperview().inset(12)
                make.right.equalToSuperview().inset(20)
                make.height.equalTo(35)
                make.top.equalTo(cell.label.snp.bottom).inset(-6)
            }
            
            cell.tutorItem.label.text = "Has tutored \(tutor.tNumSessions!) sessions"
            
            if let languages = tutor.languages {
                cell.speakItem.label.text = "Speaks: \(languages.compactMap({$0}).joined(separator: ", "))"
                cell.contentView.addSubview(cell.speakItem)
                
                cell.tutorItem.snp.makeConstraints { (make) in
                    make.left.equalToSuperview().inset(12)
                    make.right.equalToSuperview().inset(20)
                    make.height.equalTo(35)
                    make.top.equalTo(cell.locationItem.snp.bottom)
                }
                
                if tutor.school != "" {
                    cell.studysItem.label.text = "Studies at " + tutor.school!
                    cell.contentView.addSubview(cell.studysItem)
                    
                    cell.speakItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalTo(cell.tutorItem.snp.bottom)
                    }
                    
                    cell.studysItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalTo(cell.speakItem.snp.bottom)
                        make.bottom.equalToSuperview().inset(10)
                    }
                } else {
                    cell.speakItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalTo(cell.tutorItem.snp.bottom)
                        make.bottom.equalToSuperview().inset(10)
                    }
                }
            } else {
                if tutor.school != "" {
                    cell.studysItem.label.text = "Studies at " + tutor.school!
                    cell.contentView.addSubview(cell.studysItem)
                    
                    cell.tutorItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalTo(cell.locationItem.snp.bottom)
                    }
                    
                    cell.studysItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalTo(cell.tutorItem.snp.bottom)
                        make.bottom.equalToSuperview().inset(10)
                    }
                } else {
                    cell.tutorItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalTo(cell.locationItem.snp.bottom)
                        make.bottom.equalToSuperview().inset(10)
                    }
                }
            }
            cell.applyConstraints()
            
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subjectsTableViewCell", for: indexPath) as! SubjectsTableViewCell
            
            cell.datasource = tutor.subjects!
            
            return cell
            
        case 4:
            guard let datasource = tutor.reviews, datasource.count != 0 else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noRatingsTableViewCell", for: indexPath) as!
                NoRatingsTableViewCell
				cell.isViewing = isViewing
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ratingTableViewCell", for: indexPath) as!
            RatingTableViewCell
            
            if datasource.count == 1 {
                cell.tableView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview()
                    make.width.equalToSuperview().multipliedBy(0.95)
                    make.height.equalTo(120)
                    make.centerX.equalToSuperview()
                }
            }
            
            cell.datasource = datasource.sorted(by: { $0.date > $1.date })
            cell.isViewing = isViewing
			
            return cell
            
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "policiesTableViewCell", for: indexPath) as! PoliciesTableViewCell
            
            if let policy = tutor.policy {
                let policies = policy.split(separator: "_")
                
                let formattedString = NSMutableAttributedString()
                
                formattedString
                    .bold("•  ", 20, .white)
                    .regular(tutor.distance.distancePreference(tutor.preference), 16, Colors.grayText)
                    .bold("•  ", 20, .white)
                    .regular(tutor.preference.preferenceNormalization(), 16, Colors.grayText)
                    .bold("•  ", 20, .white)
                    .regular(String(policies[0]).lateNotice(), 16, Colors.grayText)
                    .bold("•  ", 20, .white)
                    .regular(String(policies[2]).cancelNotice(), 16, Colors.grayText)
                    .regular(String(policies[1]).lateFee(), 16, Colors.qtRed)
                    .regular(String(policies[3]).cancelFee(), 16, Colors.qtRed)
                
                cell.policiesLabel.attributedText = formattedString
            } else {
                // show "No Policies cell"
            }
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
}
