//
//  TutorMyProfileCells.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/31/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit


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
        labelContainer.layer.borderColor = UIColor.white.cgColor
        
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

            if (hitView is Interactable) {
                print("BEGAN: INTERACTABLE")
                touchStartView = hitView as? (UIView & Interactable)
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
				print(hitView as Any)
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
    
    let profilePicView : InteractableUIImageView = {
        let imageView = InteractableUIImageView()
        
        imageView.isUserInteractionEnabled = true
        
        imageView.scaleImage()
        imageView.sizeToFit()
        
        return imageView
    }()
    
    let nameLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createBoldSize(20)
        label.textColor = .white
        
        return label
    }()
    
    let locationImage : UIImageView = {
        let view = UIImageView()

        view.image = #imageLiteral(resourceName: "location")

        return view
    }()

    let locationLabel : UILabel = {
        let label = UILabel()

        label.font = Fonts.createSize(14)
        label.adjustsFontSizeToFitWidth = true
        label.clipsToBounds = true
        label.textColor = .white

        return label
    }()
    
    let ratingLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = Colors.yellow
        label.font = Fonts.createBoldSize(14)
        
        return label
    }()
    
    let star : UIImageView = {
        let view = UIImageView()
        
        view.image = #imageLiteral(resourceName: "yellow-star")
        
        return view
    }()
    override func configureView() {
        contentView.addSubview(profilePicView)
        addSubview(nameLabel)
        addSubview(locationImage)
        addSubview(locationLabel)
        addSubview(ratingLabel)
        addSubview(star)
        
        backgroundColor = .clear
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        
        profilePicView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(20)
            make.width.equalTo(110)
            make.height.equalTo(110)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profilePicView.snp.bottom).inset(-15)
            make.centerX.equalToSuperview()
        }
        locationLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().inset(10)
            make.height.equalTo(30)
            make.top.equalTo(nameLabel.snp.bottom)
        }
        locationImage.snp.makeConstraints { (make) in
            make.right.equalTo(locationLabel.snp.left).inset(-7)
            make.centerY.equalTo(locationLabel)
            make.height.equalTo(17)
            make.width.equalTo(17)
        }
        star.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(15)
            make.height.width.equalTo(15)
            make.top.equalTo(profilePicView)
        }
        ratingLabel.snp.makeConstraints { (make) in
            make.right.equalTo(star.snp.left).inset(-5)
            make.centerY.equalTo(star).inset(1)
        }
    }
    
    override func handleNavigation() {
        if (touchStartView is InteractableUIImageView) {
            
            if let current = next?.next?.next {
                
                if current is TutorMyProfile {
                    let vc = (current as! TutorMyProfile)
                    vc.displayAWImageViewer(images: vc.tutor.images.filter({$0.value != ""}))
                    
                } else {
                    let vc = (current as! LearnerMyProfile)
					vc.displayAWImageViewer(images: vc.learner.images.filter({$0.value != ""}))
                }
            }
        }
    }
}


class ExtraInfoTableViewCell : BaseTableViewCell {
    
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
    
    let divider = UIView()
    
    override func configureView() {
        contentView.addSubview(tutorItem)
        contentView.addSubview(divider)
        super.configureView()
        
        backgroundColor = .clear
        selectionStyle = .none
        
        divider.backgroundColor = Colors.divider
        divider.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        divider.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.left.equalToSuperview().inset(12)
            make.right.equalToSuperview().inset(20)
        }
    }
}

class ExtraInfoCardTableViewCell : ExtraInfoTableViewCell {
    
    let locationItem : ProfileItem = {
        let item = ProfileItem()
        
        item.imageView.image = #imageLiteral(resourceName: "location")

        return item
    }()
    
    override func configureView() {
        contentView.addSubview(locationItem)
        super.configureView()
        
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
            make.height.equalTo(1)
            make.right.equalTo(bioLabel)
        }
        
        divider2.snp.makeConstraints { (make) in
            make.height.equalTo(1)
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
    
    var datasource = [TutorReview]() {
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

class NoRatingsTableViewCell : BaseTableViewCell {
    
    let label1 : UILabel = {
        let label = UILabel()
        
        label.text = "Reviews"
        label.font = Fonts.createBoldSize(18)
        label.textColor = .white
        
        return label
    }()
    
    let label2 : UILabel = {
        let label = UILabel()
        
        label.text = "No reviews yet!"
        label.font = Fonts.createBoldSize(18)
        label.textColor = .white
        
        return label
    }()
    
    override func configureView() {
        contentView.addSubview(label1)
        contentView.addSubview(label2)
        super.configureView()
        
        backgroundColor = .clear
        selectionStyle = .none
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        label1.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.95)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalToSuperview()
        }
        
        label2.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalTo(label1.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
}

extension RatingTableViewCell : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (datasource.count >= 2) ? 2 : 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! TutorMyProfileReviewTableViewCell
        
        if tableView.numberOfSections == 1 {
            self.tableView.snp.updateConstraints { (make) in
                make.height.equalTo(120)
            }
        }
        
        let data = datasource[indexPath.row]
        
        cell.nameLabel.text = data.studentName
        cell.reviewTextLabel.text = data.message
        cell.dateSubjectLabel.text = "\(data.date) - \(data.subject)"
        cell.profilePic.loadUserImages(by: datasource[indexPath.row].imageURL)

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
        label.text = "Reviews (\((datasource.count)))"
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

class TutorMyProfileLongReviewTableViewCell : BaseTableViewCell {
    
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
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let container = UIView()
    
    override func configureView() {
        contentView.addSubview(container)
        container.addSubview(profilePic)
        container.addSubview(nameLabel)
        container.addSubview(dateSubjectLabel)
        container.addSubview(reviewTextLabel)
        super.configureView()
    
        container.layer.cornerRadius = 15
        container.layer.borderWidth = 1.5
        container.layer.borderColor = Colors.sidebarPurple.cgColor
        
        contentView.backgroundColor = .clear
        
        selectionStyle = .none
    }
    
    override func applyConstraints() {
        
        container.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(contentView)
            make.top.equalTo(contentView).inset(10)
            make.bottom.equalTo(reviewTextLabel).inset(-10)
        }
        
        profilePic.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(7)
            make.height.width.equalTo(50)
            make.top.equalTo(container).inset(7)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(profilePic.snp.right).inset(-10)
            make.top.equalTo(profilePic).inset(5)
        }
        
        dateSubjectLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).inset(-8)
            make.centerY.equalTo(nameLabel)
        }
        
        reviewTextLabel.snp.makeConstraints { (make) in
            make.left.equalTo(profilePic.snp.right).inset(-10)
            make.right.equalToSuperview().inset(5)
            make.top.equalTo(nameLabel.snp.bottom).inset(-5)
        }
    }
}
