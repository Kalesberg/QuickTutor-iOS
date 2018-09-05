//
//  BaseSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/31/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol SessionCellDelgate {
    func sessionCell(_ sessionCell: BaseSessionCell, shouldReloadSessionWith id: String)
}

class BaseSessionCell: UICollectionViewCell, SessionCellActionViewDelegate {
    
    var session: Session!
    var delegate: SessionCellDelgate?
    
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
        return iv
    }()
    
    let subjectLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(13)
        return label
    }()
    
    let tutorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createSize(11)
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
    
    let sessionTypeIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let actionView: SessionCellActionView = {
        let av = SessionCellActionView()
        return av
    }()
    
    func updateUI(session: Session) {
        self.session = session
        updateDayLabel()
        updateWeekdayLabel()
        updateMonthLabel()
        updateTimeAndPriceLabel()
        subjectLabel.text = session.subject
        AccountService.shared.currentUserType == .learner ? getTutor() : getLearner()
        sessionTypeIcon.image = session.type == "online" ? #imageLiteral(resourceName: "videoCameraIcon") : #imageLiteral(resourceName: "inPersonIcon")
    }
    
    func getTutor() {
        DataService.shared.getTutorWithId(session.partnerId()) { tutor in
            guard let username = tutor?.formattedName.capitalized, let profilePicUrl = tutor?.profilePicUrl else { return }
            self.tutorLabel.text = "with \(username)"
            self.profileImage.imageView.sd_setImage(with: profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
            guard let rating  = tutor?.rating else { return }
            self.updateRatingLabel(rating: rating)
        }
    }
    
    func getLearner() {
        DataService.shared.getStudentWithId(session.partnerId()) { tutor in
            guard let username = tutor?.formattedName.capitalized, let profilePicUrl = tutor?.profilePicUrl else { return }
            self.tutorLabel.text = "with \(username)"
            self.profileImage.imageView.sd_setImage(with: profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
            guard let rating  = tutor?.rating else { return }
            self.updateRatingLabel(rating: rating)
        }
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
        setupSessionTypeIcon()
        setupActionView()
        actionView.setupAsSingleButton()
        actionView.delegate = self
    }
    
    func setupMainView() {
        backgroundColor = Colors.currentUserColor()
    }
    
    func setupMonthLabel() {
        addSubview(monthLabel)
        monthLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 17, paddingBottom: 0, paddingRight: 0, width: 25, height: 10)
    }
    
    func setupDayLabel() {
        addSubview(dayLabel)
        dayLabel.anchor(top: monthLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 30, height: 20)
        addConstraint(NSLayoutConstraint(item: dayLabel, attribute: .centerX, relatedBy: .equal, toItem: monthLabel, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupWeekdayLabel() {
        addSubview(weekdayLabel)
        weekdayLabel.anchor(top: dayLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 30, height: 10)
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
    
    func setupSessionTypeIcon() {
        addSubview(sessionTypeIcon)
        sessionTypeIcon.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 15, height: 15)
    }
    
    func setupActionView() {
        addSubview(actionView)
        actionView.delegate = self
        actionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func updateMonthLabel() {
        let month = Calendar.current.component(.month, from: Date(timeIntervalSince1970: session.date)).advanced(by: -1)
        let dateFormatter = DateFormatter()
        let monthString = dateFormatter.shortMonthSymbols[month]
        monthLabel.text = monthString
    }
    
    func updateDayLabel() {
        let day = Calendar.current.component(.day, from: Date(timeIntervalSince1970: session.date))
        dayLabel.text = "\(day)"
    }
    
    func updateWeekdayLabel() {
        let weekday = Calendar.current.component(.weekday, from: Date(timeIntervalSince1970: session.date)).advanced(by: -1)
        let weekdayText = DateFormatter().shortWeekdaySymbols[weekday]
        self.weekdayLabel.text = "\(weekdayText)"
    }
    
    func updateTimeAndPriceLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let startTime = Date(timeIntervalSince1970: session.startTime)
        let startTimeString = dateFormatter.string(from: startTime)
        
        let endTime = Date(timeIntervalSince1970: session.endTime)
        let endTimeString = dateFormatter.string(from: endTime)

        let timeString = "\(startTimeString) - \(endTimeString)"
        
        let formattedPrice = String(format: "%.2f", session.price)
        let priceString = "$\(formattedPrice)"
        
        self.timeAndPriceLabel.text = "\(timeString), \(priceString)"
    }

    func updateRatingLabel(rating: Double) {
        self.starLabel.text = "\(rating)"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cellActionView(_ actionView: SessionCellActionView, didSelectButtonAt position: Int) {
        switch position {
        case 1:
            handleButton1()
        case 2:
            handleButton2()
        case 3:
            handleButton3()
        default:
            break
        }
    }
    
    func handleButton1() {
        print("button 1 was touched")
    }
    
    func handleButton2() {
        print("button 2 was touched")
    }
    
    func handleButton3() {
        print("button 3 was touched")
    }
    
    func cellActionViewDidSelectBackground(_ actionView: SessionCellActionView) {
        
    }
    
}

protocol SessionCellActionViewDelegate {
    func cellActionView(_ actionView: SessionCellActionView, didSelectButtonAt position: Int)
    func cellActionViewDidSelectBackground(_ actionView: SessionCellActionView)
}
