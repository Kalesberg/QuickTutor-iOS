//
//  SessionsContentCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

let userType = "learner"

class BaseSessionsContentCell: BaseContentCell {
    
    var pendingSessions = [Session]()
    var upcomingSessions = [Session]()
    var pastSessions = [Session]()
    
    let requestSessionButton: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "requestSessionButton"), for: .normal)
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        fetchSessions()
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.register(LearnerPendingSessionCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.register(BasePastSessionCell.self, forCellWithReuseIdentifier: "pastSessionCell")
        collectionView.register(EmptySessionCell.self, forCellWithReuseIdentifier: "emptyCell")
        collectionView.register(SessionHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
    }
    
    func fetchSessions() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("sessions").child(uid).observeSingleEvent(of: .childAdded) { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else { return }
            let session = Session(dictionary: value, id: snapshot.key)
            if session.status != "pending" && session.date > Date().timeIntervalSince1970 {
                self.pendingSessions.append(session)
            }
            
            if session.date < Date().timeIntervalSince1970 {
                self.pastSessions.append(session)
            }
            
            self.upcomingSessions.append(session)
            self.collectionView.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
//            guard !upcomingSessions.isEmpty else {
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
//                cell.setLabelToPending()
//                return cell
//            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! LearnerPendingSessionCell
//            cell.updateUI(session: pendingSessions[indexPath.item])
            return cell
        }
        
        if indexPath.section == 1 {
            guard !upcomingSessions.isEmpty else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
                cell.setLabelToUpcoming()
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! BaseSessionCell
            return cell
        }
        
        guard !upcomingSessions.isEmpty else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
            cell.setLabelToPast()
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pastSessionCell", for: indexPath) as! BasePastSessionCell
        return cell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return pendingSessions.isEmpty ? 1 : pendingSessions.count
        } else if section == 1 {
            return upcomingSessions.isEmpty ? 1 : upcomingSessions.count
        } else {
            return pastSessions.isEmpty ? 1 : pastSessions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    var headerTitles = ["Pending", "Upcoming", "Past"]
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId", for: indexPath) as! SessionHeaderCell
        header.titleLabel.text = headerTitles[indexPath.section]
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? BaseSessionCell else { return }
        cell.showActionContainerView()
    }
}

class LearnerSessionsContentCell: BaseSessionsContentCell {
    
    override func setupViews() {
        super.setupViews()
        setupRequestSessionButton()
    }
    
    func setupRequestSessionButton() {
        addSubview(requestSessionButton)
        requestSessionButton.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 50, paddingRight: 20, width: 71, height: 60)
    }
}

class TutorSessionContentCell: BaseSessionsContentCell {

    override func setupViews() {
        super.setupViews()
        headerTitles[0] = "Requests"
    }
    
}

class BaseSessionCell: UICollectionViewCell {
    
    var session: Session!
    
    let monthLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createSize(11)
        label.text = "Dec"
        label.textAlignment = .center
        return label
    }()
    
    let dayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createSize(20)
        label.text = "31"
        label.textAlignment = .center
        return label
    }()
    
    let weekdayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createSize(12)
        label.textAlignment = .center
        label.text = "Tue"
        return label
    }()
    
    let profileImage: UserImageView = {
        let iv = UserImageView()
        iv.imageView.backgroundColor = .yellow
        return iv
    }()
    
    let subjectLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(13)
        label.text = "Mathematics"
        return label
    }()
    
    let tutorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createSize(11)
        label.text = "with Alex Zoltowski"
        return label
    }()
    
    let timeAndPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createSize(11)
        label.text = "3:05 - 6:05pm, $18.50"
        return label
    }()
    
    let starLabel: UILabel = {
        let label = UILabel()
        label.text = "4.71"
        label.textAlignment = .right
        label.font = Fonts.createBoldSize(9)
        label.textColor = UIColor(hex: "FFDA02")
        return label
    }()
    
    let starIcon: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "yellow-star"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let cellActionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.isHidden = true
        return view
    }()
    
    func updateUI(session: Session) {
        self.session = session
        subjectLabel.text = session.subject
        tutorLabel.text = "with \(session.tutorId)"
    }
    
    func setupViews() {
        setupMainView()
        setupMonthLabel()
        setupDayLabel()
        setupWeekdayLabel()
        setupProfileImage()
        setupSubjectLabel()
        setupTutorLabel()
        setupTimeAndPriceLabel()
        setupStarIcon()
        setupStarLabel()
        setupActionContainerView()
    }
    
    func setupMainView() {
        backgroundColor = UIColor(red: 76.0/255.0, green: 94.0/255.0, blue: 141.0/255.0, alpha: 1.0)
    }
    
    func setupMonthLabel() {
        addSubview(monthLabel)
        monthLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 13, paddingLeft: 17, paddingBottom: 0, paddingRight: 0, width: 20, height: 10)
    }
    
    func setupDayLabel() {
        addSubview(dayLabel)
        dayLabel.anchor(top: monthLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 30, height: 20)
        addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .centerX, relatedBy: .equal, toItem: monthLabel, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupWeekdayLabel() {
        addSubview(weekdayLabel)
        weekdayLabel.anchor(top: dayLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 20, height: 10)
        addConstraint(NSLayoutConstraint(item: weekdayLabel, attribute: .centerX, relatedBy: .equal, toItem: monthLabel, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupProfileImage() {
        addSubview(profileImage)
        profileImage.anchor(top: topAnchor, left: dayLabel.rightAnchor, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 25, paddingBottom: 10, paddingRight: 0, width: 60, height: 60)
    }
    
    func setupSubjectLabel() {
        addSubview(subjectLabel)
        subjectLabel.anchor(top: topAnchor, left: profileImage.rightAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 200, height: 15)
    }
    
    func setupTutorLabel() {
        addSubview(tutorLabel)
        tutorLabel.anchor(top: subjectLabel.bottomAnchor, left: subjectLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 15)
    }
    
    func setupTimeAndPriceLabel() {
        addSubview(timeAndPriceLabel)
        timeAndPriceLabel.anchor(top: tutorLabel.bottomAnchor, left: subjectLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 15)
    }
    
    func setupStarIcon() {
        addSubview(starIcon)
        starIcon.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 12, height: 12)
        addConstraint(NSLayoutConstraint(item: starIcon, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func setupStarLabel() {
        addSubview(starLabel)
        starLabel.anchor(top: nil, left: nil, bottom: nil, right: starIcon.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 60, height: 15)
        addConstraint(NSLayoutConstraint(item: starLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func setupActionContainerView() {
        addSubview(cellActionContainerView)
        cellActionContainerView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(hideActionContainerView))
        cellActionContainerView.addGestureRecognizer(dismissTap)
    }
    
    func updateMonthLabel() {
        let month = Calendar.current.component(.month, from: Date(timeIntervalSince1970: session.date))
        let dateFormatter = DateFormatter()
        let monthString = dateFormatter.shortMonthSymbols[month]
        monthLabel.text = monthString
    }
    
    func updateDayLabel() {
        let day = Calendar.current.component(.day, from: Date(timeIntervalSince1970: session.date))
        dayLabel.text = "\(day)"
    }
    
    func updateWeekdayLabel() {
        
    }
    
    func showActionContainerView() {
        cellActionContainerView.isHidden = false
    }
    
    @objc func hideActionContainerView() {
        cellActionContainerView.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class BasePendingSessionCell: BaseSessionCell {
    
    
}

class LearnerPendingSessionCell: BasePendingSessionCell {
    
    let messageButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "cancelSessionButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        setupCancelButton()
        setupMessageButton()
    }
    
    func setupCancelButton() {
        cellActionContainerView.addSubview(cancelButton)
        cancelButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 60, height: 50)
        addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 5))
        cancelButton.addTarget(self, action: #selector(postCancelButtonNofitication), for: .touchUpInside)
    }
    
    func setupMessageButton() {
        cellActionContainerView.addSubview(messageButton)
        messageButton.anchor(top: nil, left: nil, bottom: nil, right: cancelButton.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 60, height: 50)
        addConstraint(NSLayoutConstraint(item: messageButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 5))
        messageButton.addTarget(self, action: #selector(postMessageNotification), for: .touchUpInside)
    }
    
    @objc func postMessageNotification() {
        let userInfo = ["uid": "gCoBPk6oFda95PuPJlkFEEUJlLC2"]
        let notification = Notification(name: NSNotification.Name(rawValue: "sendMessage"), object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    @objc func postCancelButtonNofitication() {
        let notification = Notification(name: NSNotification.Name(rawValue: "cancelSession"), object: nil, userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
}

class TutorPendingSessionCell: BasePendingSessionCell {
    
}

class BaseUpcomingSessionCell: BaseSessionCell {
    
}

class LearnerUpcomingSessionCell: BaseUpcomingSessionCell {
    
}

class TutorUpcomingSessionCell: BaseUpcomingSessionCell {
    
}

class BasePastSessionCell: BaseSessionCell {
    
    let darkenView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        return view
    }()
    
    let starView: StarView = {
        let sv = StarView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    override func setupViews() {
        super.setupViews()
        setupDarkenView()
        setupStarView()
        starIcon.removeFromSuperview()
        starLabel.removeFromSuperview()
    }
    
    override func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    private func setupDarkenView() {
        addSubview(darkenView)
        darkenView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    private func setupStarView() {
        addSubview(starView)
        starView.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 12, width: 40, height: 7)
    }
}

class LearnerPastSessionCell: BasePastSessionCell {
    
}

class TutorPastSessionCell: BasePastSessionCell {
    
}

class PendingSessionCell: BaseSessionCell {
    
}

class UpcomingSessionCell: BaseSessionCell {
    
}


class SessionHeaderCell: UICollectionReusableView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(22)
        label.text = "Pending"
        return label
    }()
    
    func setupViews() {
        setupTitleLabel()
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class StarView: UIView {
    
    let star1: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "yellow-star"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let star2: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "yellow-star"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let star3: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "yellow-star"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let star4: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "yellow-star"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let star5: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "yellow-star"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    func setupViews() {
        setupStar1()
        setupStar2()
        setupStar3()
        setupStar4()
        setupStar5()
    }
    
    let rightPadding: CGFloat = 1
    private func setupStar1() {
        addSubview(star1)
        star1.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 7, height: 7)
    }
    
    private func setupStar2() {
        addSubview(star2)
        star2.anchor(top: nil, left: nil, bottom: bottomAnchor, right: star1.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: rightPadding, width: 7, height: 7)
    }
    
    private func setupStar3() {
        addSubview(star3)
        star3.anchor(top: nil, left: nil, bottom: bottomAnchor, right: star2.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: rightPadding, width: 7, height: 7)
    }
    
    private func setupStar4() {
        addSubview(star4)
        star4.anchor(top: nil, left: nil, bottom: bottomAnchor, right: star3.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: rightPadding, width: 7, height: 7)
    }
    
    private func setupStar5() {
        addSubview(star5)
        star5.anchor(top: nil, left: nil, bottom: bottomAnchor, right: star4.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: rightPadding, width: 7, height: 7)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


