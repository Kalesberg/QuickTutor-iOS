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
    
    var pageCount : Int {
        var count = 0
        LearnerData.userData.images.forEach { (_,value) in
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
            if LearnerData.userData.images["image\(number)"] == "" {
                print("nothing")
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0:
            return 170
        case 1:
            return UITableViewAutomaticDimension
        case 2:
            return 80
        case 3:
            return UITableViewAutomaticDimension
        case 4:
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
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutMeTableViewCell", for: indexPath) as! AboutMeTableViewCell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subjectsTableViewCell", for: indexPath) as! SubjectsTableViewCell
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ratingTableViewCell", for: indexPath) as! RatingTableViewCell
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "policiesTableViewCell", for: indexPath) as! PoliciesTableViewCell
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
}
