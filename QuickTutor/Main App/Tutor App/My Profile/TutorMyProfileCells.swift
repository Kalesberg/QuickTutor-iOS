//
//  TutorMyProfileCells.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/31/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class SubjectSelectionCollectionViewCell : UICollectionViewCell {
    
    required override init(frame: CGRect) {
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label : UILabel = {
        let label = UILabel()
        
        label.backgroundColor = .clear
        label.font = Fonts.createSize(14)
        label.textColor = .white
        label.textAlignment = .center
        
        return label
    }()
    
    let labelContainer = UIView()
    
    func configureView() {
        addSubview(labelContainer)
        labelContainer.addSubview(label)
        
        labelContainer.backgroundColor = Colors.tutorBlue
        labelContainer.layer.cornerRadius = 10
        labelContainer.clipsToBounds = true
        
        applyConstraints()
    }
    
    func applyConstraints(){
        label.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        labelContainer.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}

class BaseTableViewCell : UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    func configureView() {}
    func applyConstraints() {}
    
    var touchStartView : (UIView & Interactable)? = nil
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let firstTouch = touches.first {
            let hitView = self.contentView.hitTest(firstTouch.location(in: self.contentView), with: event)
            print(hitView)
            if (hitView is Interactable) {
                print("BEGAN: INTERACTABLE")
                touchStartView = hitView as? (UIView & Interactable)!
                touchStartView?.touchStart()
            } else {
                print("BEGAN: NOT INTERACTABLE")
            }
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if(touchStartView == nil) {
            print("DRAGGING ON A NONINTERACTABLE")
        } else {
            if let firstTouch = touches.first {
                let hitView = self.contentView.hitTest(firstTouch.location(in: self.contentView), with: event)
                let previousView = self.contentView.hitTest(firstTouch.previousLocation(in: self.contentView), with: event)
                
                if ((touchStartView == hitView) && (previousView == hitView)) {
                    print("DRAGGING ON START VIEW")
                    touchStartView?.draggingOn()
                } else if (previousView == touchStartView) {
                    print("DID DRAG OFF START VIEW")
                    touchStartView?.didDragOff()
                } else if ((previousView != touchStartView) && (hitView == touchStartView)) {
                    print("DID DRAG ON TO START VIEW")
                    touchStartView?.didDragOn()
                } else {
                    touchStartView?.draggingOff()
                    print("DRAGGING OFF START VIEW")
                }
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if(touchStartView == nil) {
            print("ENDED: NON INTERACTABLE")
        }
        else {
            if let firstTouch = touches.first {
                let hitView = self.contentView.hitTest(firstTouch.location(in: self.contentView), with: event)
                print(hitView)
                if (touchStartView == hitView) {
                    print("ENDED: ON START")
                    touchStartView?.touchEndOnStart()
                } else {
                    touchStartView?.touchEndOffStart()
                    touchStartView = nil
                    print("ENDED: OFF START")
                }
            }
        }
        
        handleNavigation()
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if(touchStartView == nil) {
            print("CANCELLED: NON INTERACTABLE")
        } else {
            print("CANCELLED: INTERACTABLE")
            touchStartView?.touchCancelled()
        }
        
        touchStartView = nil
    }
    
    public func handleNavigation() {}
}


class InteractableUIImageView : UIImageView, Interactable {}


class ProfilePicTableViewCell : BaseTableViewCell {
    
    let mainContainer : UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.registrationDark
        view.layer.cornerRadius = 7
        
        return view
    }()
    
    let profilePicView : InteractableUIImageView = {
        let imageView = InteractableUIImageView()
        
        if let image = LocalImageCache.localImageManager.getImage(number: "1") {
            imageView.image = image
        } else {
            
        }
        
        imageView.isUserInteractionEnabled = true
        
        imageView.scaleImage()
        imageView.sizeToFit()
        
        return imageView
    }()
    
    let locationItem : ProfileItem = {
        let item = ProfileItem()
        
        item.imageView.image = #imageLiteral(resourceName: "location")
        
        return item
    }()
    
    let speakItem : ProfileItem = {
        let item = ProfileItem()
        
        item.imageView.image = #imageLiteral(resourceName: "speaks")
        
        return item
    }()
    
    let studysItem : ProfileItem = {
        let item = ProfileItem()
        
        item.imageView.image = #imageLiteral(resourceName: "studys-at")
        
        return item
    }()
    
    let tutorItem : ProfileItem = {
        let item = ProfileItem()
        
        item.imageView.image = UIImage(named: "tutored-in")
        
        return item
    }()
    
    let container : UIView = {
        let view = UIView()
        
        return view
    }()
    override func configureView() {
        contentView.addSubview(mainContainer)
        mainContainer.addSubview(profilePicView)
        mainContainer.addSubview(container)
        container.addSubview(locationItem)
        container.addSubview(tutorItem)
        container.addSubview(speakItem)
        container.addSubview(studysItem)
        
        backgroundColor = .clear
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        
        mainContainer.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.95)
            make.height.equalTo(150)
            make.centerX.equalToSuperview()
            make.top.equalTo(contentView).inset(15)
        }
        
        profilePicView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(10)
            make.width.equalToSuperview().multipliedBy(0.35)
            make.centerY.equalToSuperview()
        }
        
        container.snp.makeConstraints { (make) in
            make.left.equalTo(profilePicView.snp.right).inset(-5)
            make.right.equalToSuperview().inset(3)
            make.height.equalTo(100)
            make.centerY.equalToSuperview()
        }
        
        locationItem.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.25)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        tutorItem.snp.makeConstraints { (make) in
            make.top.equalTo(locationItem.snp.bottom)
            make.height.equalToSuperview().multipliedBy(0.25)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        speakItem.snp.makeConstraints { (make) in
            make.top.equalTo(tutorItem.snp.bottom)
            make.height.equalToSuperview().multipliedBy(0.25)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        studysItem.snp.makeConstraints { (make) in
            make.top.equalTo(speakItem.snp.bottom)
            make.height.equalToSuperview().multipliedBy(0.25)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    override func handleNavigation() {
        if (touchStartView is InteractableUIImageView) {
            
            let vc = (next?.next?.next as! LearnerMyProfile)
    
            vc.contentView.backgroundView.alpha = 0.65
            vc.contentView.xButton.alpha = 1.0
            vc.horizontalScrollView.isUserInteractionEnabled = true
            vc.horizontalScrollView.isHidden = false
            vc.contentView.leftButton.isHidden = true
        }
    }
}


class AboutMeTableViewCell : UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    var aboutMeLabel : LeftTextLabel = {
        let label = LeftTextLabel()
        
        label.label.font = Fonts.createBoldSize(18)
        label.label.text = "About Me"
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var bioLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = Colors.grayText
        label.font = Fonts.createSize(13)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let divider1 = BaseView()
    let divider2 = BaseView()
    
    let container = UIView()
    
    func configureView() {
        contentView.addSubview(aboutMeLabel)
        contentView.addSubview(divider1)
        contentView.addSubview(bioLabel)
        contentView.addSubview(divider2)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        divider1.backgroundColor = Colors.divider
        divider2.backgroundColor = Colors.divider
    
        applyConstraints()
    }
    
    func applyConstraints() {
        
        aboutMeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).inset(12)
            make.height.equalTo(44)
            make.top.equalTo(contentView)
        }
        
        bioLabel.snp.makeConstraints { (make) in
            make.top.equalTo(aboutMeLabel.snp.bottom)
            make.left.equalTo(contentView).inset(20)
            make.right.equalTo(contentView).inset(20)
            make.bottom.equalTo(contentView)
        }
        
        divider1.snp.makeConstraints { (make) in
            make.left.equalTo(aboutMeLabel.snp.right).inset(-10)
            make.centerY.equalTo(aboutMeLabel)
            make.height.equalTo(0.75)
            make.right.equalTo(bioLabel)
        }
        
        divider2.snp.makeConstraints { (make) in
            make.height.equalTo(0.75)
            make.left.equalTo(aboutMeLabel)
            make.right.equalTo(divider1)
            make.top.equalTo(contentView.snp.bottom)
        }
    }
}

class PoliciesTableViewCell : UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    let header : UILabel = {
        let label = UILabel()
        
        label.text = "Policies"
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let policiesLabel : UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        label.numberOfLines = 0
        
        return label
    }()
    
    var divider1 = UIView()
    
    func configureView() {
        contentView.addSubview(header)
        contentView.addSubview(policiesLabel)
        contentView.addSubview(divider1)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        divider1.backgroundColor = Colors.divider
        
        applyConstraints()
    }
    
    func applyConstraints() {
        header.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).inset(10)
            make.left.equalTo(contentView).inset(10)
        }
        
        policiesLabel.snp.makeConstraints { (make) in
            make.top.equalTo(header.snp.bottom).inset(-10)
            make.left.equalTo(contentView.snp.left).inset(10)
            make.right.equalTo(contentView).inset(15)
            make.bottom.equalTo(contentView).inset(15)
        }
        
        divider1.snp.makeConstraints { (make) in
            make.left.equalTo(header.snp.right).inset(-10)
            make.centerY.equalTo(header).inset(0.5)
            make.height.equalTo(0.75)
            make.right.equalTo(contentView).inset(20)
        }
    }
}

class SubjectsTableViewCell : UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }
    
    let subjectCollectionView : UICollectionView = {
        
        let collectionView : UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8.0
        layout.minimumLineSpacing = 8.0
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.tag = 1
        
        return collectionView
    }()
	
	var datasource : [String]? {
		didSet {
			subjectCollectionView.reloadData()
		}
	}
	
	let label : UILabel = {
		let label = UILabel()
		
		label.text = "Subjects"
		label.textColor = .white
		label.font = Fonts.createBoldSize(18)
		
		return label
	}()
	
    func configureView() {
        addSubview(label)
        addSubview(subjectCollectionView)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        subjectCollectionView.delegate = self
        subjectCollectionView.dataSource = self
        subjectCollectionView.register(SubjectSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "subjectSelectionCollectionViewCell")
        
        applyConstraints()
    }
    
    func applyConstraints() {
        
        label.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(10)
            make.height.equalTo(55)
            make.top.equalToSuperview()
        }
        
        subjectCollectionView.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(label.snp.bottom)
        }
    }
}


extension SubjectsTableViewCell : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subjectSelectionCollectionViewCell", for: indexPath) as! SubjectSelectionCollectionViewCell
        
		cell.label.text = datasource?[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: (datasource![indexPath.row] as NSString).size(withAttributes: nil).width + 35, height: 30)
    }
}

class RatingTableViewCell : BaseTableViewCell {

	let tableView : UITableView = {
		let tableView = UITableView()
		
		tableView.backgroundColor = .clear
		tableView.estimatedRowHeight = 60
		tableView.isScrollEnabled = false
		tableView.separatorInset.left = 0
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
		tableView.estimatedSectionHeaderHeight = 30
		
		return tableView
	}()
	
    let seeAllButton : SeeAllButton = {
        let button = SeeAllButton()
        
        return button
    }()
	
	var datasource : [TutorReview]? {
		didSet {
			tableView.reloadData()
		}
	}
	
	override func configureView() {
		contentView.addSubview(tableView)
        contentView.addSubview(seeAllButton)
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(TutorMyProfileReviewTableViewCell.self, forCellReuseIdentifier: "reviewCell")
	
        backgroundColor = .clear
        selectionStyle = .none
		
		
		applyConstraints()
    }
    
    override func applyConstraints() {
		
		tableView.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.95)
            make.height.equalTo(190)
			make.centerX.equalToSuperview()
		}
		
        seeAllButton.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.top.equalTo(tableView.snp.bottom).inset(-10)
            make.right.equalTo(tableView.snp.right)
            make.bottom.equalTo(contentView)
        }
    }
	override func handleNavigation() {
		if touchStartView is SeeAllButton {
			if let current = UIApplication.getPresentedViewController() {
				let next = LearnerReviews()
				next.datasource = datasource
				current.present(next, animated: true, completion: nil)
			}
		}
	}
}

extension RatingTableViewCell : UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return datasource?.count ?? 0
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 70
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! TutorMyProfileReviewTableViewCell
		
		let data = datasource?[indexPath.row]
		
		cell.nameLabel.text = data?.studentName ?? ""
		cell.reviewTextLabel.text = data?.message ?? ""
		cell.dateSubjectLabel.text = "\(data?.date ?? "") - \(data?.subject ?? "")"
		cell.profilePic.loadUserImages(by: data?.imageURL ?? "")
	
		return cell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
		return 10
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		cell.backgroundColor = .clear
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
	
		let label = UILabel()
		
		label.font = Fonts.createBoldSize(18)
		label.text = "Reviews \((datasource?.count ?? 0))"
        label.textColor = .white
		
		return label
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 50
	}
}

class TutorMyProfileReviewTableViewCell : BaseTableViewCell {
	
	let profilePic : UIImageView = {
		
		let imageView = UIImageView()
		
		imageView.scaleImage()
		
		return imageView
	}()
	
	
	let nameLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = .white
		label.font = Fonts.createBoldSize(16)
		
		return label
	}()
	let dateSubjectLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = Colors.grayText
		label.font = Fonts.createSize(13)
		
		return label
	}()
	
	let reviewTextLabel : UILabel = {
		let label = UILabel()
		
		label.textColor = Colors.grayText
		label.font = Fonts.createItalicSize(14)
		
		return label
	}()
    
    let container = UIView()
	
	override func configureView() {
        addSubview(container)
		container.addSubview(profilePic)
		container.addSubview(nameLabel)
		container.addSubview(dateSubjectLabel)
		container.addSubview(reviewTextLabel)
		super.configureView()
		
		if let image = LocalImageCache.localImageManager.getImage(number: "1") {
			profilePic.image = image
		} else {
			//set to some arbitrary image.
		}
		applyConstraints()
		container.layer.cornerRadius = 15
		container.layer.borderWidth = 1.5
		container.layer.borderColor = Colors.sidebarPurple.cgColor

		contentView.backgroundColor = .clear

		selectionStyle = .none

	}
	
	override func applyConstraints() {
        
        container.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(60)
        }
		
		profilePic.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(7)
			make.centerY.equalToSuperview()
			make.height.equalTo(50)
			make.width.equalTo(50)
		}
		
		nameLabel.snp.makeConstraints { (make) in
			make.left.equalTo(profilePic.snp.right).inset(-10)
			make.centerY.equalToSuperview().multipliedBy(0.7)
		}
		
		dateSubjectLabel.snp.makeConstraints { (make) in
			make.left.equalTo(nameLabel.snp.right).inset(-8)
			make.centerY.equalTo(nameLabel)
		}
		
		reviewTextLabel.snp.makeConstraints { (make) in
			make.left.equalTo(profilePic.snp.right).inset(-10)
			make.centerY.equalToSuperview().multipliedBy(1.4)
			make.right.equalToSuperview().inset(3)
		}
	}
}
