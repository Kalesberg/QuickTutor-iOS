//
//  MyProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//
//TODO: Design
//  - Instagram scroll view
//  - course codes?
//
//TODO: Backend
//  - fix up the if let for the bio text... if the bio is changed to empty, it doesnt set the placeholder text
//  - test to see if the constraints work properly with no school in profile
//  - tableview in Reviews, i have the cell view that would be inserted

import Foundation
import UIKit
import SnapKit


class SeeAllButton: InteractableView, Interactable {
    
    var label = UILabel()
    
    override func configureView() {
        addSubview(label)
        super.configureView()
        
        layer.borderColor = Colors.green.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 7
        
        label.text = "See all »"
        label.textColor = Colors.green
        label.font = Fonts.createSize(16)
        label.textAlignment = .center
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    func touchStart() {
        alpha = 0.7
    }
    
    func didDragOff() {
        alpha = 1.0
    }
}


class ReviewView : BaseView {
    
    var profilePic = UIImageView()
    var nameLabel = UILabel()
    var dateSubjectLabel = UILabel()
    var reviewTextLabel = UILabel()
    
    override func configureView() {
        addSubview(profilePic)
        addSubview(nameLabel)
        addSubview(dateSubjectLabel)
        addSubview(reviewTextLabel)
        super.configureView()
        
        if let image = LocalImageCache.localImageManager.getImage(number: "1") {
            profilePic.image = image
        } else {
            //set to some arbitrary image.
        }
        
        profilePic.scaleImage()
        
        nameLabel.textColor = .white
        nameLabel.font = Fonts.createBoldSize(18)
        
        dateSubjectLabel.textColor = Colors.grayText
        dateSubjectLabel.font = Fonts.createSize(13)
        
        reviewTextLabel.textColor = Colors.grayText
        reviewTextLabel.font = Fonts.createItalicSize(15)
        
        applyConstraints()
    }
    
    override func applyConstraints() {
       
        profilePic.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
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

class LearnerMyProfileView : MainLayoutTitleBackTwoButton {
    
    var editButton = NavbarButtonEdit()
    
    override var rightButton: NavbarButton {
        get {
            return editButton
        } set {
            editButton = newValue as! NavbarButtonEdit
        }
    }
    
    var xButton = NavbarButtonX()
    
    var scrollView = MyProfileScrollView()
    var backgroundView = UIView()
    
    var imageContainer = ImageContainer()
    var nameLabel = CenterTextLabel()
    var locationItem = LocationItem()
    var aboutMe = AboutMeView()
    var speakItem = ProfileItem()
    var tutorItem = ProfileItem()
    var studysItem = ProfileItem()
    var divider = UIView()
    var reviewLabel = ReviewLabel()
    var review = ReviewView()
    var review2 = ReviewView()
    var seeAllButton = SeeAllButton()
    var divider2 = UIView()
    
    override func configureView() {
        addSubview(scrollView)
        addSubview(backgroundView)
        addSubview(xButton)
        scrollView.addSubview(imageContainer)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(locationItem)
        scrollView.addSubview(aboutMe)
        scrollView.addSubview(speakItem)
        scrollView.addSubview(tutorItem)
        scrollView.addSubview(studysItem)
        scrollView.addSubview(divider)
        scrollView.addSubview(reviewLabel)
        scrollView.addSubview(review)
        scrollView.addSubview(review2)
        scrollView.addSubview(seeAllButton)
        scrollView.addSubview(divider2)
        super.configureView()
        
        let user = LearnerData.userData
        
        title.label.text = "My Profile"
        
        scrollView.showsVerticalScrollIndicator = false
        
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0.0
        
        xButton.alpha = 0.0
        
        nameLabel.label.font = Fonts.createBoldSize(22)
        nameLabel.label.text = user.name!

		
		speakItem.label.text = "Speaks: "
        speakItem.imageView.image = UIImage(named: "speaks")
        
        tutorItem.label.text = "Tutored in 14 sessions"
        tutorItem.imageView.image = UIImage(named: "tutored-in")
        
        studysItem.imageView.image = UIImage(named: "studys-at")
        
        if let bio = user.bio {
            aboutMe.bioLabel.text = "\(bio)\n"
        } else {
            aboutMe.bioLabel.text = "No bio yet! You can add one in Edit Profile."
        }
        
        divider.backgroundColor = Colors.divider
        divider2.backgroundColor = Colors.divider
        
        if let school = user.school {
            studysItem.label.text = "Studys at \(school)"
            studysItem.constrainSelf(top: tutorItem.snp.bottom)
            
            divider.snp.makeConstraints({ (make) in
                make.height.equalTo(0.5)
                make.bottom.equalTo(studysItem).inset(-10)
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
            })
        } else {
            divider.snp.makeConstraints({ (make) in
                make.height.equalTo(0.5)
                make.bottom.equalTo(tutorItem).inset(-10)
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
            })
        }
        
        reviewLabel.reviewlabel.text = "22 Reviews"
        reviewLabel.ratingLabel.text = "4.71"
        
        review.nameLabel.text = "Alex Z."
        review.dateSubjectLabel.text = "Dec 12, 2017 - Python"
        review.reviewTextLabel.text = "\"Collin was a natural at python, a genius really!\""
        
        review2.nameLabel.text = "Austin W."
        review2.dateSubjectLabel.text = "Jan 12, 2018 - A long subject line dfsds"
        review2.reviewTextLabel.text = "\"Alex is a legend, he taught me!\""
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.left.equalTo(layoutMarginsGuide.snp.left)
            make.right.equalTo(layoutMarginsGuide.snp.right)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        
        backgroundView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        xButton.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.175)
            make.top.equalTo(navbar).inset(10)
            make.bottom.equalTo(navbar).inset(10)
            make.left.equalToSuperview()
        }
        
        imageContainer.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.21)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageContainer.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.06)
        }
        
        locationItem.constrainSelf(top: nameLabel.snp.bottom)
        
        aboutMe.snp.makeConstraints { (make) in
            make.top.equalTo(locationItem.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(aboutMe.divider2)
        }
    
        speakItem.snp.makeConstraints { (make) in
            make.top.equalTo(aboutMe.divider2.snp.bottom).inset(-10)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.05)
        }
        
        tutorItem.constrainSelf(top: speakItem.snp.bottom)
        
        reviewLabel.snp.makeConstraints { (make) in
            make.top.equalTo(divider).inset(15)
            make.left.equalToSuperview()
            make.right.equalTo(reviewLabel.ratingLabel).inset(-10)
            make.height.equalTo(30)
        }
        
        review.snp.makeConstraints { (make) in
            make.top.equalTo(reviewLabel.snp.bottom).inset(-13)
            make.height.equalTo(60)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        review2.snp.makeConstraints { (make) in
            make.top.equalTo(review.snp.bottom)
            make.height.equalTo(60)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        seeAllButton.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.top.equalTo(review2.snp.bottom).inset(-13)
            make.right.equalTo(review.snp.right)
        }
        
        divider2.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(seeAllButton.snp.bottom).inset(-15)
        }
    }
}


class ProfilePicInteractable : UIImageView, Interactable, BaseViewProtocol {
    
    public required init() {
        super.init(frame: UIScreen.main.bounds)
        configureView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configureView() {
        image = LocalImageCache.localImageManager.image1
        isUserInteractionEnabled = true
        scaleImage()
    }
    
    func applyConstraints() { }
}



class ImageContainer : InteractableView {
    
    var profilePicImageView = ProfilePicInteractable()
    var star = UIImageView()
    var ratingLabel = UILabel()
    
    override func configureView() {
        addSubview(profilePicImageView)
        addSubview(star)
        addSubview(ratingLabel)
        super.configureView()
        
        ratingLabel.textColor = .white
        ratingLabel.font = Fonts.createSize(12)
        ratingLabel.numberOfLines = 0
        ratingLabel.text = "4.71"
        ratingLabel.textAlignment = .right
        
        star.image = UIImage(named: "sidebar-star")
        star.scaleImage()
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        profilePicImageView.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.8)
            make.bottom.equalToSuperview().inset(5)
            make.width.equalToSuperview().multipliedBy(0.4)
            make.centerX.equalToSuperview()
        }
        
        star.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalTo(profilePicImageView)
            make.height.equalTo(12)
            make.width.equalTo(20)
        }
        
        ratingLabel.snp.makeConstraints { (make) in
            make.right.equalTo(star.snp.left)
            make.top.equalTo(star)
            make.width.equalTo(50)
            make.height.equalTo(star)
        }
    }
}

class AboutMeView : BaseView {
		
    var aboutMeLabel = LeftTextLabel()
    var bioLabel = UILabel()
    var divider1 = BaseView()
    var divider2 = BaseView()
    
    override func configureView() {
        addSubview(aboutMeLabel)
        addSubview(divider1)
        addSubview(bioLabel)
        addSubview(divider2)
        super.configureView()
        
        aboutMeLabel.label.font = Fonts.createBoldSize(18)
        aboutMeLabel.label.text = "About Me"
        aboutMeLabel.sizeToFit()
        
        bioLabel.textColor = Colors.grayText
        bioLabel.font = Fonts.createSize(13)
        bioLabel.numberOfLines = 0
        
        divider1.backgroundColor = Colors.divider
        divider2.backgroundColor = Colors.divider
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        aboutMeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.height.equalTo(30)
            make.top.equalToSuperview()
        }
        
        bioLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(aboutMeLabel.snp.bottom)
        }
        
        divider1.snp.makeConstraints { (make) in
            make.left.equalTo(aboutMeLabel.snp.right).inset(-10)
            make.centerY.equalTo(aboutMeLabel)
            make.height.equalTo(0.5)
            make.right.equalToSuperview()
        }
        
        divider2.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(bioLabel.snp.bottom).inset(-10)
        }
    }
}

class ProfileItem : BaseView {
    
    var imageView = UIImageView()
    var label = UILabel()
    
    override func configureView() {
        addSubview(imageView)
        addSubview(label)
        super.configureView()
        
        imageView.scaleImage()
        
        label.textColor = .white
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = Fonts.createSize(14)
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp.right).offset(7)
            make.height.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(25)
        }
    }
    
    func constrainSelf(top: ConstraintItem) {
        self.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(DeviceInfo.multiplier * 0.05)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(top)
        }
    }
}

class ReviewLabel : BaseView {
    
    var reviewlabel = UILabel()
    var starImage = UIImageView()
    var ratingLabel = UILabel()
    
    override func configureView() {
        addSubview(reviewlabel)
        addSubview(starImage)
        addSubview(ratingLabel)
        super.configureView()
        
        layer.borderWidth = 1
        layer.borderColor = Colors.yellow.cgColor
        layer.cornerRadius = 15
        
        reviewlabel.textColor = Colors.yellow
        reviewlabel.font = Fonts.createSize(14)
        reviewlabel.sizeToFit()
        
        starImage.image = UIImage(named: "yellow-star")
        starImage.scaleImage()
        
        ratingLabel.textColor = Colors.yellow
        ratingLabel.font = Fonts.createSize(14)
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        reviewlabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        starImage.snp.makeConstraints { (make) in
            make.height.equalTo(reviewlabel)
            make.width.equalTo(30)
            make.centerY.equalToSuperview()
            make.left.equalTo(reviewlabel.snp.right)
        }
        
        ratingLabel.snp.makeConstraints { (make) in
            make.left.equalTo(starImage.snp.right)
            make.centerY.equalToSuperview()
        }
    }
}

class LocationItem : ProfileItem {
    
    override func configureView() {
        super.configureView()
        
        label.text = "Mount Pleasant, Michigan"
        label.textAlignment = .center
        label.font = Fonts.createSize(12)
        imageView.image = UIImage(named: "location")
    }
    
    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.5)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.right.equalTo(label.snp.left).inset(-7)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.5)
        }
    }
}

class MyProfileScrollView : BaseScrollView {
    
    override func handleNavigation() {
        let vc = (next?.next as! LearnerMyProfile)
        
        if(touchStartView is ProfilePicInteractable) {
            vc.contentView.backgroundView.alpha = 0.65
            vc.contentView.xButton.alpha = 1.0
            vc.horizontalScrollView.isUserInteractionEnabled = true
            vc.horizontalScrollView.isHidden = false
            vc.contentView.leftButton.isHidden = true
        } else if (touchStartView is SeeAllButton) {
            navigationController.pushViewController(LearnerReviews(), animated: true)
        }
    }
}

class LearnerMyProfile : BaseViewController {
    
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
	
	var languages : String! {
		let languages = LearnerData.userData.languages.map({ (language) -> String in
			return language
		}).joined(separator: ", ")
		return "Speaks: \(languages)"
	}
	var bio : String! {
		return LearnerData.userData.bio
	}
	
    override var contentView: LearnerMyProfileView {
        return view as! LearnerMyProfileView
    }
    
    override func viewDidLoad() {
        contentView.addSubview(horizontalScrollView)
        super.viewDidLoad()
		horizontalScrollView.delegate = self

        contentView.scrollView.contentSize = CGSize(width: 280, height: (contentView.seeAllButton.frame.maxY - contentView.imageContainer.frame.minY) + 30)
		
		pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)
    }
    override func loadView() {
        view = LearnerMyProfileView()
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		configurePageControl()
		configureScrollView()
		setUpImages()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setUpLabels()
	}
	private func setUpLabels (){
		contentView.speakItem.label.text = languages
		contentView.studysItem.label.text = LearnerData.userData.school
		contentView.imageContainer.profilePicImageView.image = LocalImageCache.localImageManager.image1
		contentView.aboutMe.bioLabel.text = bio
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
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    @objc func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * horizontalScrollView.frame.size.width
        horizontalScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        if (touchStartView == nil) {
            return
        } else if(touchStartView is NavbarButtonEdit) {
            navigationController?.pushViewController(LearnerEditProfile(), animated: true)
        } else if(touchStartView is NavbarButtonX) {
            contentView.backgroundView.alpha = 0.0
            contentView.xButton.alpha = 0.0
            horizontalScrollView.isUserInteractionEnabled = false
            horizontalScrollView.isHidden = true
            contentView.leftButton.isHidden = false
        }
    }
}
extension LearnerMyProfile : UIScrollViewDelegate {
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		
		let pageNumber = round(horizontalScrollView.contentOffset.x / horizontalScrollView.frame.size.width)
		pageControl.currentPage = Int(pageNumber)
	}
}
