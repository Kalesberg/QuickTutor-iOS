//
//  MyProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.


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


class LearnerMyProfileView : MainLayoutTitleTwoButton {
    
    var editButton = NavbarButtonEdit()
    var backButton = NavbarButtonBack()
	
	override var leftButton: NavbarButton{
		get {
			return backButton
		}
		set {
			backButton = newValue as! NavbarButtonBack
		}
	}
	
    override var rightButton: NavbarButton {
        get {
            return editButton
        } set {
            editButton = newValue as! NavbarButtonEdit
        }
    }
    
    let xButton : NavbarButtonX = {
        let xButton = NavbarButtonX()
        
        xButton.alpha = 0
        
        return xButton
    }()
    
    let backgroundView : UIView = {
        let view = UIView()
        
        view.backgroundColor = .black
        view.alpha = 0.0
        
        return view
    }()
    
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
    
    override func configureView() {
        addSubview(tableView)
        addSubview(backgroundView)
        addSubview(xButton)
        super.configureView()
        
        title.label.text = "My Profile"
        navbar.backgroundColor = Colors.learnerPurple
        statusbarView.backgroundColor = Colors.learnerPurple
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
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
        
        tableView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
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
        label.numberOfLines = 1
        label.font = Fonts.createSize(15)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(imageView.snp.right).inset(-5)
            make.right.equalToSuperview().inset(3)
        }

        imageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalTo(18)
            make.width.equalTo(25)
        }
    }

    func constraintItem(top: ConstraintItem) {
        self.snp.makeConstraints { (make) in
            make.top.equalTo(top)
            make.left.equalToSuperview().inset(12)
            make.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
            make.bottom.equalToSuperview()
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


class LearnerMyProfile : BaseViewController {
    
    let horizontalScrollView = UIScrollView()
    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    var pageControl : UIPageControl = UIPageControl(frame: CGRect(x:50,y: 300, width:200, height:50))
	
	var pageCount : Int {
		var count = 0
		learner.images.forEach { (_,value) in
			if value != "" {
				count += 1
			}
		}
		return count
	}

	var learner : AWLearner! {
        didSet {
            contentView.tableView.reloadData()
        }
    }

    override var contentView: LearnerMyProfileView {
        return view as! LearnerMyProfileView
    }
    
    override func viewDidLoad() {
        contentView.addSubview(horizontalScrollView)
        super.viewDidLoad()
		configureDelegates()
		
    }
	
    override func loadView() {
        view = LearnerMyProfileView()
    }
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		guard let learner = CurrentUser.shared.learner else {
			return
		}
		self.learner = learner
		configurePageControl()
		configureScrollView()
		setUpImages()
    }
	
	private func configureDelegates() {
		horizontalScrollView.delegate = self
		pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)
		
		contentView.tableView.delegate = self
		contentView.tableView.dataSource = self
		contentView.tableView.register(ProfilePicTableViewCell.self, forCellReuseIdentifier: "profilePicTableViewCell")
		contentView.tableView.register(AboutMeTableViewCell.self, forCellReuseIdentifier: "aboutMeTableViewCell")
		contentView.tableView.register(ExtraInfoTableViewCell.self, forCellReuseIdentifier: "extraInfoTableViewCell")
	}
	private func setUpImages() {
		var count = 0
		for number in 1..<5 {
			if learner.images["image\(number)"] == "" {
				continue
			}
			count += 1
			setImage(number, count)
		}
	}
	private func setImage(_ number: Int, _ count: Int) {
		let imageView = UIImageView()
		imageView.loadUserImages(by: learner.images["image\(number)"]!)
        imageView.scaleImage()
		
		self.horizontalScrollView.addSubview(imageView)
		
		imageView.snp.makeConstraints({ (make) in
			make.top.equalToSuperview()
			make.height.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
			if (count != 1) {
				make.left.equalTo(horizontalScrollView.subviews[count - 2].snp.right)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func handleNavigation() {
        if(touchStartView is NavbarButtonEdit) {
			navigationController?.pushViewController(LearnerEditProfile(), animated: true)
		} else if(touchStartView == contentView.xButton) {
			
			contentView.backgroundView.alpha = 0.0
            contentView.xButton.alpha = 0.0
			contentView.leftButton.isHidden = false

			horizontalScrollView.isUserInteractionEnabled = false
            horizontalScrollView.isHidden = true
		}
    }
}

extension LearnerMyProfile : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0:
            return 200
        case 1:
            return UITableViewAutomaticDimension
        case 2:
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
			cell.nameLabel.text = learner.name
            cell.locationLabel.text = "Mount Pleasant, MI"
			cell.profilePicView.loadUserImages(by: learner.images["image1"]!)

			return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutMeTableViewCell", for: indexPath) as! AboutMeTableViewCell

			if learner.bio == "" {
				cell.bioLabel.text = "No bio yet! Add one in Edit Profile\n"
			} else {
				cell.bioLabel.text = learner.bio + "\n"
			}
			return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "extraInfoTableViewCell", for: indexPath) as! ExtraInfoTableViewCell
            
            for view in cell.contentView.subviews {
                view.snp.removeConstraints()
            }
            
            cell.speakItem.removeFromSuperview()
            cell.studysItem.removeFromSuperview()
            
            //cell.tutorItem.label.text = "Tutored in \(LearnerData.userData.numSessions!) sessions"
            cell.tutorItem.label.text = "Tutored in 0 sessions"
			if let languages = learner.languages {
                print("languages")
                cell.speakItem.label.text = "Speaks: \(languages.compactMap({$0}).joined(separator: ", "))"
                cell.contentView.addSubview(cell.speakItem)
                
                cell.tutorItem.snp.makeConstraints { (make) in
                    make.left.equalToSuperview().inset(12)
                    make.right.equalToSuperview().inset(20)
                    make.height.equalTo(35)
                    make.top.equalToSuperview().inset(10)
                }
                
				if let studies = learner.school {
                    print("school")
                    cell.studysItem.label.text = "Studies at " + studies
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
                    print("school nil")
                    cell.speakItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalTo(cell.tutorItem.snp.bottom)
                        make.bottom.equalToSuperview().inset(10)
                    }
                }
            } else {
				if let studies = learner.school {
                    print("languages nil & school")
                    cell.studysItem.label.text = "Studies at " + studies
                    cell.contentView.addSubview(cell.studysItem)
                    
                    cell.tutorItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalToSuperview().inset(10)
                    }
                    
                    cell.studysItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalTo(cell.tutorItem.snp.bottom)
                        make.bottom.equalToSuperview().inset(10)
                    }
                } else {
                    print("all nil")
                    cell.tutorItem.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().inset(12)
                        make.right.equalToSuperview().inset(20)
                        make.height.equalTo(35)
                        make.top.equalToSuperview().inset(10)
                        make.bottom.equalToSuperview().inset(10)
                    }
                }
            }
            
            cell.applyConstraints()

            return cell
            
        default:
            break
        }
        return UITableViewCell()
    }
}


extension LearnerMyProfile : UIScrollViewDelegate {
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let pageNumber = round(horizontalScrollView.contentOffset.x / horizontalScrollView.frame.size.width)
		pageControl.currentPage = Int(pageNumber)
	}
}
