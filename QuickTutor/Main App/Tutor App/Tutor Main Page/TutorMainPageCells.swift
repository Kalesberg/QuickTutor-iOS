//
//  TutorMainPageCells.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorMainPageHeaderCell : BaseTableViewCell {
    
    let headerLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createBoldSize(38)
        
        return label
    }()
    
    let subHeaderLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createSize(14)
        
        return label
    }()
    
    let icon = UIImageView()
    
    let headerContainer = UIView()
    
    let infoContainer : UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.registrationDark
        view.layer.borderWidth = 1
        view.layer.borderColor = Colors.divider.cgColor
        
        return view
    }()
    
    override func configureView() {
        addSubview(headerContainer)
        headerContainer.addSubview(headerLabel)
        headerContainer.addSubview(icon)
        addSubview(subHeaderLabel)
        addSubview(infoContainer)
        super.configureView()
        
        backgroundColor = .clear
        selectionStyle = .none
        
        icon.image = #imageLiteral(resourceName: "big-gold-star")
        subHeaderLabel.text = "TUTOR RATING"
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        headerContainer.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(40)
            make.height.equalTo(50)
            make.left.equalTo(icon)
            make.right.equalTo(headerLabel)
            make.centerX.equalToSuperview()
        }
        
        headerLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        icon.snp.makeConstraints { (make) in
            make.right.equalTo(headerLabel.snp.left).inset(-15)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(55)
        }
        
        subHeaderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerContainer.snp.bottom).inset(-15)
            make.centerX.equalToSuperview()
        }
    }
}

class TutorMainPageSummaryCell : BaseTableViewCell {
    
    let infoLabel1 : UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    let infoLabel2 : UILabel = {
        let label = UILabel()
        
        let formattedString = NSMutableAttributedString()
        
        formattedString
            .bold("\n", 16, .white)
            .regular("5-Stars", 15, Colors.grayText)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
        
        label.attributedText = formattedString
        
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    let infoLabel3 : UILabel = {
        let label = UILabel()
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("\n", 16, .white)
            .regular("Hours", 15, Colors.grayText)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        formattedString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, formattedString.length))
        
        label.attributedText = formattedString
        
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    override func configureView() {
        contentView.addSubview(infoLabel1)
        contentView.addSubview(infoLabel2)
        contentView.addSubview(infoLabel3)
        super.configureView()
        
        backgroundColor = Colors.registrationDark
        selectionStyle = .none
        
        applyConstraints()
    }
    
    override func applyConstraints() {
        infoLabel1.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).inset(15)
            make.left.equalToSuperview().inset(35)
            make.centerY.equalToSuperview()
        }

        infoLabel2.snp.makeConstraints { (make) in
            make.top.equalTo(contentView)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        infoLabel3.snp.makeConstraints { (make) in
            make.top.equalTo(contentView)
            make.right.equalToSuperview().inset(35)
            make.centerY.equalToSuperview()
        }
    }
}

class TutorMainPageTopSubjectCell : BaseTableViewCell {

    let topSubjectsLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createBoldSize(16)
        label.text = "Top Subject"
        
        return label
    }()
    
    let subjectLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createSize(17)
        
        return label
    }()
    
    let icon = UIImageView()
    
    override func configureView() {
        addSubview(topSubjectsLabel)
        addSubview(subjectLabel)
        addSubview(icon)
        super.configureView()

        backgroundColor = Colors.registrationDark
        selectionStyle = .none
		
        applyConstraints()
    }
    
    override func applyConstraints() {
        topSubjectsLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(8)
            make.left.equalToSuperview().inset(20)
        }
        
        subjectLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(6)
            make.centerX.equalToSuperview()
        }
        
        icon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().inset(-5)
            make.centerX.equalToSuperview()
        }
    }
}
