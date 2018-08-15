//
//  MyProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

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
    
    override var contentView: TutorMyProfileView {
        return view as! TutorMyProfileView
    }
    
    func tutorWasUpdated(tutor: AWTutor!) {
        self.tutor = tutor
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
        contentView.profilePics.loadUserImagesWithoutMask(by: tutor.images["image1"]!)
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
            self.displayAWImageViewer(images: tutor.images.filter({$0.value != ""}))
        }
    }
}
extension TutorMyProfile : AWImageViewer {
    func dismiss() {
        self.dismissAWImageViewer()
    }
}
extension TutorMyProfile : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row) {
//        case 0:
//            return 200
        case 0,1,3,4:
            return UITableViewAutomaticDimension
        case 2:
            return 90
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.row) {
            
//        case 0:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "profilePicTableViewCell", for: indexPath) as! ProfilePicTableViewCell
//
//            let name = tutor.name.split(separator: " ")
//            cell.nameLabel.text = "\(String(name[0])) \(String(name[1]).prefix(1))."
//            cell.locationLabel.text = tutor.region
//            cell.profilePicView.loadUserImages(by: tutor.images["image1"]!)
//            cell.ratingLabel.text = String(tutor.tRating)
//
//            return cell
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutMeTableViewCell", for: indexPath) as! AboutMeTableViewCell
            
            cell.bioLabel.text = tutor.tBio + "\n"
            
            return cell
        case 1:
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
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subjectsTableViewCell", for: indexPath) as! SubjectsTableViewCell
            
            cell.datasource = tutor.subjects!
            
            return cell
            
        case 3:

            guard let datasource = tutor.reviews else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noRatingsTableViewCell", for: indexPath) as!
                NoRatingsTableViewCell
                return cell
            }
            
            if datasource.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noRatingsTableViewCell", for: indexPath) as!
                NoRatingsTableViewCell
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ratingTableViewCell", for: indexPath) as!
            RatingTableViewCell
            
            cell.seeAllButton.isHidden = !(datasource.count > 2)
            cell.datasource = datasource
            return cell
            
        case 4:
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
