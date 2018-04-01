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
    
    let divider : UIView = {
        var view = UIView()
        
        view.backgroundColor = Colors.backgroundDark
        
        return view
    }()
    
    func configureView() {
        addSubview(label)
        addSubview(divider)
        applyConstraints()
    }
    
    func applyConstraints(){
        label.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        divider.snp.makeConstraints { (make) in
            make.width.equalTo(1)
            make.right.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
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
            
            print(hitView!)
            
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


class ProfilePicTableViewCell : BaseTableViewCell {
    
    let mainContainer : UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.registrationDark
        view.layer.cornerRadius = 7
        
        return view
    }()
    
    let profilePicView : UIImageView = {
        let imageView = UIImageView()
        
        if let image = LocalImageCache.localImageManager.getImage(number: "1") {
            imageView.image = image
        } else {
            
        }
        
        imageView.scaleImage()
        imageView.sizeToFit()
        
        return imageView
    }()
    
    let locationItem : LocationItem = {
        let item = LocationItem()
        
        return item
    }()
    
    let speakItem : ProfileItem = {
        let item = ProfileItem()
        
        item.label.text = "Speaks: English, Spanish"
        item.imageView.image = #imageLiteral(resourceName: "speaks")
        
        return item
    }()
    
    let studysItem : ProfileItem = {
        let item = ProfileItem()
        
        item.label.text = "Central Michigan University"
        item.imageView.image = UIImage(named: "studys-at")
        
        return item
    }()
    
    let tutorItem : ProfileItem = {
        let item = ProfileItem()
        
        item.label.text = "Tutored in 14 sessions"
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
        
        let user = LearnerData.userData
        
        if let bio = user.bio {
            bioLabel.text = "\(bio)\n"
        } else {
            bioLabel.text = "No bio yet! You can add one in Edit Profile."
        }
        
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
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .regular(" - Will travel up to 15 miles\n\n", 14, .white)
            .regular(" - Will tutor Online or In-Person\n\n", 14, .white)
            .regular(" - Cancellations: 24 Hour Notice\n\n", 14, .white)
            .regular("      Late Fee: $15.00\n", 13, Colors.qtRed)
            .regular("      Cancellation Fee: $15.00", 13, Colors.qtRed)
        
        label.attributedText = formattedString
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        label.numberOfLines = 0
        
        return label
    }()
    
    var divider1 = UIView()
    var divider2 = UIView()
    
    func configureView() {
        contentView.addSubview(header)
        contentView.addSubview(policiesLabel)
        contentView.addSubview(divider1)
        contentView.addSubview(divider2)
        
        backgroundColor = .clear
        
        divider1.backgroundColor = Colors.divider
        divider2.backgroundColor = Colors.divider
        
        applyConstraints()
    }
    
    func applyConstraints() {
        header.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).inset(10)
            make.left.equalTo(contentView).inset(15)
        }
        
        policiesLabel.snp.makeConstraints { (make) in
            make.top.equalTo(header.snp.bottom).inset(-10)
            make.left.equalTo(contentView.snp.left).inset(15)
            make.right.equalTo(contentView).inset(15)
            make.bottom.equalTo(contentView).inset(15)
        }
        
        divider1.snp.makeConstraints { (make) in
            make.left.equalTo(header.snp.right).inset(-10)
            make.centerY.equalTo(header).inset(0.5)
            make.height.equalTo(0.75)
            make.right.equalTo(contentView).inset(20)
        }
        
        divider2.snp.makeConstraints { (make) in
            make.left.equalTo(header)
            make.height.equalTo(0.75)
            make.right.equalTo(contentView).inset(20)
            make.bottom.equalTo(policiesLabel).inset(-15)
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
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = Colors.tutorBlue
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.tag = 1
        
        return collectionView
    }()
    
    func configureView() {
        addSubview(subjectCollectionView)
        
        backgroundColor = .clear
        
        subjectCollectionView.delegate = self
        subjectCollectionView.dataSource = self
        subjectCollectionView.register(SubjectSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "subjectSelectionCollectionViewCell")
        
        applyConstraints()
    }
    
    func applyConstraints() {
        subjectCollectionView.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

struct Subjects {
    static var subjects = ["Chemistry", "Math", "Python", "Javascript", "This thug"]
}

extension SubjectsTableViewCell : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Subjects.subjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subjectSelectionCollectionViewCell", for: indexPath) as! SubjectSelectionCollectionViewCell
        
        if(indexPath.row == 0) {
            let divider = UIView()
            divider.backgroundColor = Colors.backgroundDark
            cell.addSubview(divider)
            
            divider.snp.makeConstraints({ (make) in
                make.left.equalToSuperview()
                make.height.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.equalTo(1)
            })
        }
        
        cell.label.text = Subjects.subjects[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (Subjects.subjects[indexPath.row] as NSString).size(withAttributes: nil).width + 40, height: 30)
    }
}

class RatingTableViewCell : BaseTableViewCell {

    let reviewLabel : ReviewLabel = {
        let label = ReviewLabel()
        
        label.reviewlabel.text = "22 Reviews"
        label.ratingLabel.text = "4.71"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let review1 : ReviewView = {
        let review = ReviewView()
        
        review.nameLabel.text = "Alex Z."
        review.dateSubjectLabel.text = "Dec 12, 2017 - Python"
        review.reviewTextLabel.text = "\"Collin was a natural at python, a genius really!\""
        review.translatesAutoresizingMaskIntoConstraints = false
        
        return review
    }()
    
    let review2 : ReviewView = {
        let review = ReviewView()
        
        review.nameLabel.text = "Alex Z."
        review.dateSubjectLabel.text = "Dec 12, 2017 - Python"
        review.reviewTextLabel.text = "\"Collin was a natural at python, a genius really!\""
        review.translatesAutoresizingMaskIntoConstraints = false
        
        return review
    }()
    
    let seeAllButton : SeeAllButton = {
        let button = SeeAllButton()
        
        return button
    }()
    
    override func configureView() {
        contentView.addSubview(reviewLabel)
        contentView.addSubview(review1)
        contentView.addSubview(review2)
        contentView.addSubview(seeAllButton)
        applyConstraints()
        
        backgroundColor = .clear
    }
    
    override func applyConstraints() {
        reviewLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView)
            make.left.equalTo(contentView).inset(15)
            make.right.equalTo(reviewLabel.ratingLabel).inset(-10)
            make.height.equalTo(30)
        }
        
        review1.snp.makeConstraints { (make) in
            make.top.equalTo(reviewLabel.snp.bottom).inset(-10)
            make.height.equalTo(60)
            make.right.equalTo(contentView).inset(15)
            make.left.equalTo(contentView).inset(15)
        }
        
        review2.snp.makeConstraints { (make) in
            make.top.equalTo(review1.snp.bottom).inset(-15)
            make.height.equalTo(60)
            make.right.equalTo(contentView).inset(15)
            make.left.equalTo(contentView).inset(15)
        }
        
        seeAllButton.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.top.equalTo(review2.snp.bottom).inset(-13)
            make.right.equalTo(review1.snp.right).inset(15)
            make.bottom.equalTo(contentView)
        }
    }
}
