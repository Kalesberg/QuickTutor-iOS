//
//  MyProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class TutorMyProfileView : MainLayoutTitleBackTwoButton {
    
    var editButton = NavbarButtonEdit()
    
    override var rightButton: NavbarButton {
        get {
            return editButton
        } set {
            editButton = newValue as! NavbarButtonEdit
        }
    }
    
    let tableView : UITableView = {
        let tableView = UITableView()
        
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 250
        tableView.isScrollEnabled = true
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        return tableView
    }()
    
    let backgroundView : UIView = {
        let view = UIView()
        
        view.backgroundColor = .black
        view.alpha = 0.0
        
        return view
    }()
    
    let xButton : NavbarButtonX = {
        let button = NavbarButtonX()
        
        button.alpha = 0.0
        
        return button
    }()
    
    override func configureView() {
        addSubview(tableView)
        addSubview(backgroundView)
        addSubview(xButton)
        super.configureView()
        
        title.label.text = "My Profile"
        statusbarView.backgroundColor = Colors.tutorBlue
        navbar.backgroundColor = Colors.tutorBlue
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        tableView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        xButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.175)
            make.top.equalTo(navbar).inset(10)
            make.bottom.equalTo(navbar).inset(10)
            make.left.equalToSuperview()
        }
    }
}

class TutorMyProfile : BaseViewController {
    
    override var contentView: TutorMyProfileView {
        return view as! TutorMyProfileView
    }
    
    let horizontalScrollView = UIScrollView()
    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    var pageControl : UIPageControl = UIPageControl(frame: CGRect(x:50,y: 300, width:200, height:50))
    
    let tutor = TutorData.shared
    
    var pageCount : Int {
        var count = 0
        tutor.images.forEach { (_,value) in
            if value != "" {
                count += 1
            }
        }
        return count
    }
    
    override func viewDidLoad() {
        contentView.addSubview(horizontalScrollView)
        super.viewDidLoad()
        
        horizontalScrollView.delegate = self
    
        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)
        
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        
        contentView.tableView.register(ProfilePicTableViewCell.self, forCellReuseIdentifier: "profilePicTableViewCell")
        contentView.tableView.register(AboutMeTableViewCell.self, forCellReuseIdentifier: "aboutMeTableViewCell")
        contentView.tableView.register(SubjectsTableViewCell.self, forCellReuseIdentifier: "subjectsTableViewCell")
        contentView.tableView.register(PoliciesTableViewCell.self, forCellReuseIdentifier: "policiesTableViewCell")
        contentView.tableView.register(RatingTableViewCell.self, forCellReuseIdentifier: "ratingTableViewCell")
        contentView.tableView.register(ExtraInfoTableViewCell.self, forCellReuseIdentifier: "extraInfoTableViewCell")
    }
    
    override func loadView() {
        view = TutorMyProfileView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureScrollView()
        configurePageControl()
        setUpImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentView.tableView.reloadData()
        contentView.tableView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .automatic)
    }
    
    private func configureScrollView() {
        
        horizontalScrollView.isUserInteractionEnabled = false
        horizontalScrollView.isHidden = true
        horizontalScrollView.isPagingEnabled = true
        horizontalScrollView.showsHorizontalScrollIndicator = false
        
        horizontalScrollView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.35)
            make.centerX.equalToSuperview()
            make.top.equalTo(contentView.navbar.snp.bottom).inset(-15)
        }
        contentView.layoutIfNeeded()
        
        horizontalScrollView.contentSize = CGSize(width: horizontalScrollView.frame.size.width * CGFloat(pageCount), height: horizontalScrollView.frame.size.height)
    }
    
    private func configurePageControl() {
        
        // The total number of pages that are available is based on how many available colors we have.
        pageControl.numberOfPages = pageCount
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .white
        pageControl.currentPageIndicatorTintColor = Colors.learnerPurple
        contentView.backgroundView.addSubview(pageControl)
        
        pageControl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(horizontalScrollView.snp.bottom).inset(-10)
        }
    }
    
    @objc func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * horizontalScrollView.frame.size.width
        horizontalScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    private func setUpImages() {
        var count = 0
        
        for number in 1..<5 {
            if tutor.images["image\(number)"] == "" {
                continue
            }
            print("found image\(number)")
            count += 1
            setImage(number, count)
        }
    }
    
    private func setImage(_ number: Int, _ count: Int) {
        
        let imageView = UIImageView()
        
        imageView.image = LocalImageCache.localImageManager.getImage(number: String(number))
        imageView.scaleImage()
        
        self.horizontalScrollView.addSubview(imageView)
        
        imageView.snp.makeConstraints({ (make) in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
            if (count != 1) {
                make.left.equalTo(horizontalScrollView.subviews[count - 1].snp.right)
            } else {
                make.centerX.equalToSuperview()
            }
        })
        contentView.layoutIfNeeded()
    }
    
    override func handleNavigation() {
        if (touchStartView is NavbarButtonEdit) {
            navigationController?.pushViewController(TutorEditProfile(), animated: true)
        } else if(touchStartView is NavbarButtonX) {
            contentView.backgroundView.alpha = 0.0
            contentView.xButton.alpha = 0.0
            horizontalScrollView.isUserInteractionEnabled = false
            horizontalScrollView.isHidden = true
            contentView.leftButton.isHidden = false
        }
    }
}

extension TutorMyProfile : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0:
            return 200
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return UITableViewAutomaticDimension
        case 3:
            return 90
        case 4:
            return UITableViewAutomaticDimension
        case 5:
            return UITableViewAutomaticDimension
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.row) {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "profilePicTableViewCell", for: indexPath) as! ProfilePicTableViewCell
            
            //cell.locationLabel.text = tutor.region
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutMeTableViewCell", for: indexPath) as! AboutMeTableViewCell
            
            //cell.bioLabel.text = tutor.bio + "\n"
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "extraInfoTableViewCell", for: indexPath) as! ExtraInfoTableViewCell
            
            //cell.tutorItem.label.text = "Tutored in \(tutor.numSessions!) sessions"
            //cell.speakItem.label.text = "Speaks: \(tutor.languages.compactMap({$0}).joined(separator: ", "))"
            //cell.studysItem.label.text = tutor.school!
            
            cell.tutorItem.snp.makeConstraints { (make) in
                make.left.equalToSuperview().inset(12)
                make.right.equalToSuperview().inset(20)
                make.height.equalTo(35)
                make.top.equalToSuperview().inset(10)
                
                //remove line below this once logic is implemented... the bottom will be set with the if below it
                make.bottom.equalToSuperview().inset(10)
                
                //if speak and study is not set {
                //   make.bottom.equalToSuperview().inset(10)
                //}
            }
            
            //if speak item is set {
            //cell.addSubview(speakItem)
//            cell.speakItem.snp.makeConstraints { (make) in
//                make.left.equalToSuperview().inset(12)
//                make.right.equalToSuperview().inset(20)
//                make.height.equalTo(40)
//                make.top.equalTo(cell.tutorItem.snp.bottom)
//
//                if study is not set{
//                   make.bottom.equalToSuperview().inset(10)
//                }
//            }
//        }
            //if study is set {
            //cell.addSubview(studysItem)
//            cell.studysItem.snp.makeConstraints { (make) in
//                make.left.equalToSuperview().inset(12)
//                make.right.equalToSuperview().inset(20)
//                make.height.equalTo(40)
//                if speak is set {
//                  make.top.equalTo(cell.speakItem.snp.bottom)
//                } else {
//                  make.top.equalTo(cell.tutorItem.snp.bottom)
//       }
//                make.bottom.equalToSuperview().inset(10)
//            }
//        }
            return cell
        
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subjectsTableViewCell", for: indexPath) as! SubjectsTableViewCell
            //cell.datasource = tutor.subjects
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ratingTableViewCell", for: indexPath) as! RatingTableViewCell

//            if tutor.reviews.count <= 2 {
//                cell.datasource = tutor.reviews
//            } else {
//                cell.datasource = Array(tutor.reviews[0..<2])
//            }
            
            return cell
            
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "policiesTableViewCell", for: indexPath) as! PoliciesTableViewCell
        
            let policies = tutor.policy.split(separator: "_")
            
            let cancelNotice = policies[2]
            
            let formattedString = NSMutableAttributedString()
            
            formattedString
                .regular(" - Will travel up to \(tutor.distance!) miles\n\n", 14, .white)
                .regular(tutor.preference.preferenceNormalization(), 14, .white)
                .regular(" - Cancellations: \(cancelNotice) Hour Notice\n\n", 14, .white)
                //not sure how were storing these yet
                .regular("      Late Fee: $15.00\n", 13, Colors.qtRed)
                .regular("      Cancellation Fee: $15.00", 13, Colors.qtRed)
            
            cell.policiesLabel.attributedText = formattedString

            return cell
        default:
            break
        }
        return UITableViewCell()
    }
}
