//
//  BaseSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/31/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class BaseSessionCell: UICollectionViewCell, SessionCellActionViewDelegate {
    
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
    
    let actionView: SessionCellActionView = {
        let av = SessionCellActionView()
        return av
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
        setupActionView()
        actionView.setupAsSingleButton()
        actionView.delegate = self
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
    
    func setupActionView() {
        addSubview(actionView)
        actionView.delegate = self
        actionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
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

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
}

protocol SessionCellActionViewDelegate {
    func handleButton1()
    func handleButton2()
    func handleButton3()
}

//extension SessionCellActionViewDelegate {
//    func handleButton1() {}
//    func handleButton2() {}
//    func handleButton3() {}
//}

class SessionCellActionView: UIView {
    
    var delegate: SessionCellActionViewDelegate?
    
    let cellActionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.isHidden = true
        return view
    }()
    
    let actionButton1: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    let actionButton2: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    let actionButton3: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    func setupViews() {
        setupActionContainerView()
        setupActionButtonTargets()
    }
    
    func setupActionContainerView() {
        addSubview(cellActionContainerView)
        cellActionContainerView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(hideActionContainerView))
        cellActionContainerView.addGestureRecognizer(dismissTap)
    }
    
    private func setupActionButton1() {
        cellActionContainerView.addSubview(actionButton1)
        actionButton1.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 60, height: 50)
        addConstraint(NSLayoutConstraint(item: actionButton1, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 5))
        actionButton1.addTarget(self, action: #selector(handleButton1), for: .touchUpInside)
    }
    
    private func setupActionButton2() {
        cellActionContainerView.addSubview(actionButton2)
        actionButton2.anchor(top: nil, left: nil, bottom: nil, right: actionButton1.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 60, height: 50)
        addConstraint(NSLayoutConstraint(item: actionButton2, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 5))
        actionButton2.addTarget(self, action: #selector(handleButton2), for: .touchUpInside)
    }
    
    private func setupActionButton3() {
        cellActionContainerView.addSubview(actionButton3)
        actionButton3.anchor(top: nil, left: nil, bottom: nil, right: actionButton2.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 60, height: 50)
        addConstraint(NSLayoutConstraint(item: actionButton3, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 5))
        actionButton3.addTarget(self, action: #selector(handleButton3), for: .touchUpInside)
    }
    
    func setupActionButtonTargets() {
        
    }
    
    func showActionContainerView() {
        cellActionContainerView.isHidden = false
    }
    
    @objc func hideActionContainerView() {
        cellActionContainerView.isHidden = true
    }
    
    func updateButtonImages(_ images: [UIImage]) {
        let buttons = [actionButton1, actionButton2, actionButton3]
        for x in 0...images.count - 1 {
            buttons[buttons.count - (x + 1)].setImage(images[x], for: .normal)
        }
    }
    
    func setupAsSingleButton() {
        setupActionButton1()
    }
    
    func setupAsDoubleButton() {
        setupAsSingleButton()
        setupActionButton2()
    }
    
    func setupAsTripleButton() {
        setupAsDoubleButton()
        setupActionButton3()
    }
    
    @objc func handleButton1() {
        delegate?.handleButton1()
    }
    
    @objc func handleButton2() {
        delegate?.handleButton2()
    }
    
    @objc func handleButton3() {
        delegate?.handleButton3()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
