//
//  MyProfile.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/28/18.
//  Copyright © 2018 QuickTutor. All rights reserved.


import Foundation
import UIKit
import SnapKit
import FirebaseUI


protocol LearnerWasUpdatedCallBack {
    func learnerWasUpdated(learner: AWLearner!)
}

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
    
    let backgroundView : InteractableObject = {
        let view = InteractableObject()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.isHidden = true
        
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
    
    let profilePics : TutorCardProfilePic = {
        let view = TutorCardProfilePic()
        
        view.isUserInteractionEnabled = true
        view.backgroundColor = .clear
        
        return view
    }()
    
    let nameContainer : UIView = {
        let view = UIView()
        return view
    }()
    
    let name : UILabel = {
        var label = UILabel()
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(20)
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    override func configureView() {
        addSubview(profilePics)
        profilePics.addSubview(nameContainer)
        nameContainer.addSubview(name)
        addSubview(tableView)
        addSubview(backgroundView)
        super.configureView()
        insertSubview(statusbarView, at: 1)
        insertSubview(navbar, at: 2)
        
        title.label.text = "My Profile"
        navbar.backgroundColor = Colors.learnerPurple
        statusbarView.backgroundColor = Colors.learnerPurple
        backgroundColor = Colors.registrationDark
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        profilePics.roundCorners(.allCorners, radius: 8)
    }
    
    override func applyConstraints() {
        super.applyConstraints()

        profilePics.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom).inset(-30)
            make.centerX.equalToSuperview()
            if UIScreen.main.bounds.height < 570 {
                make.width.height.equalTo(160)
            } else {
                make.width.height.equalTo(200)
            }
        }
        nameContainer.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.width.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        name.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(3)
        }
        
        backgroundView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(name.snp.bottom).inset(-20)
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


class ProfileItem : BaseView {

    var imageViewContainer = UIView()
    var imageView = UIImageView()
    var label = UILabel()

    override func configureView() {
        addSubview(imageViewContainer)
        imageViewContainer.addSubview(imageView)
        addSubview(label)
        super.configureView()

        imageView.scaleImage()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageViewContainer.backgroundColor = Colors.tutorBlue
        imageViewContainer.layer.cornerRadius = 13

        label.textColor = Colors.grayText
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 1
        label.font = Fonts.createSize(14)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(imageViewContainer.snp.right).inset(-11)
            make.right.equalToSuperview().inset(3)
        }
        
        imageViewContainer.snp.makeConstraints { (make) in
            make.centerY.left.equalToSuperview()
            make.height.width.equalTo(26)
        }

        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
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


class LearnerMyProfile : BaseViewController, LearnerWasUpdatedCallBack {
	
	let storageRef : StorageReference! = Storage.storage().reference(forURL: Constants.STORAGE_URL)

	override var contentView: LearnerMyProfileView {
		return view as! LearnerMyProfileView
	}
	
	override func loadView() {
		view = LearnerMyProfileView()
	}
	
    var learner : AWLearner! {
        didSet {
            contentView.tableView.reloadData()
        }
    }

    var isViewing : Bool = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDelegates()
        
        let name = learner.name.split(separator: " ")
        contentView.name.text = "\(String(name[0])) \(String(name[1]).prefix(1))."
		let reference = storageRef.child("student-info").child(CurrentUser.shared.learner.uid).child("student-profile-pic1")
		contentView.profilePics.sd_setImage(with: reference, placeholderImage: nil)
        //contentView.ratingLabel.text = String(learner.lRating)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
	
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
		contentView.nameContainer.backgroundColor = UIColor(hex: "6662C9")
    }
	
    private func configureDelegates() {
        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.register(ProfilePicTableViewCell.self, forCellReuseIdentifier: "profilePicTableViewCell")
        contentView.tableView.register(AboutMeTableViewCell.self, forCellReuseIdentifier: "aboutMeTableViewCell")
        contentView.tableView.register(ExtraInfoTableViewCell.self, forCellReuseIdentifier: "extraInfoTableViewCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func learnerWasUpdated(learner: AWLearner!) {
		self.learner = learner
		let name = learner.name.split(separator: " ")
		contentView.name.text = "\(String(name[0])) \(String(name[1]).prefix(1))."
	}
	
    override func handleNavigation() {
        if(touchStartView is NavbarButtonEdit) {
			let next = LearnerEditProfile()
			next.delegate = self
			navigationController?.pushViewController(next, animated: true)
        } else if(touchStartView is TutorCardProfilePic) {
			self.displayProfileImageViewer(imageCount: learner.images.filter({$0.value != ""}).count, userId: learner.uid)
        }
    }
}

extension LearnerMyProfile : ProfileImageViewerDelegate {
    func dismiss() {
        self.dismissProfileImageViewer()
    }
}

extension LearnerMyProfile : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0:
            return UITableViewAutomaticDimension
        case 1:
            return UITableViewAutomaticDimension
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
//            cell.locationImage.isHidden = true
//            let name = learner.name.split(separator: " ")
//            cell.nameLabel.text = "\(String(name[0])) \(String(name[1]).prefix(1))."
//
//            cell.profilePicView.loadUserImages(by: learner.images["image1"]!)
//            cell.ratingLabel.text = String(learner.lRating)
//
//            return cell
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutMeTableViewCell", for: indexPath) as! AboutMeTableViewCell
            
            cell.aboutMeLabel.label.textColor = Colors.learnerPurple

            if learner.bio == "" && !isViewing {
                cell.bioLabel.text = "No biography yet! You can add a bio by tapping \"edit\" in the top right of the screen.\n"
            } else if learner.bio == "" && isViewing {
                let name = learner.name.split(separator: " ")
                cell.bioLabel.text = "\(String(name[0])) has not yet entered a biography. \n"
            } else {
                cell.bioLabel.text = learner.bio + "\n"
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "extraInfoTableViewCell", for: indexPath) as! ExtraInfoTableViewCell
            
            for view in cell.contentView.subviews {
                view.snp.removeConstraints()
            }
            
            cell.speakItem.imageViewContainer.backgroundColor = Colors.learnerPurple
            cell.studysItem.imageViewContainer.backgroundColor = Colors.learnerPurple
            cell.tutorItem.imageViewContainer.backgroundColor = Colors.learnerPurple
            
            cell.speakItem.removeFromSuperview()
            cell.studysItem.removeFromSuperview()
            cell.tutorItem.label.text = "Tutored in \(0) sessions"
            
            if let languages = learner.languages {
                cell.speakItem.label.text = "Speaks: \(languages.compactMap({$0}).joined(separator: ", "))"
                cell.contentView.addSubview(cell.speakItem)
                
                cell.tutorItem.snp.makeConstraints { (make) in
                    make.left.equalToSuperview().inset(12)
                    make.right.equalToSuperview().inset(20)
                    make.height.equalTo(35)
                    make.top.equalToSuperview().inset(10)
                }
                
                if let studies = learner.school {
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
