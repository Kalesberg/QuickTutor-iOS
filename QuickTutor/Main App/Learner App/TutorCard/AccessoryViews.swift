//
//  AccessoryViews.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Cosmos

class BaseAccessoryView: UIView {
    
    func setupViews() {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TutorCardAccessoryView: BaseAccessoryView {
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "$60 per hour"
        label.textAlignment = .left
        label.textColor = .white
        label.font = Fonts.createBoldSize(14)
        return label
    }()
    
    let starView: CosmosView = {
        let view = CosmosView()
        
        view.settings.emptyImage = UIImage(named: "ic_star_empty")
        view.settings.filledImage = UIImage(named: "ic_star_filled")
        view.settings.totalStars = 5
        view.settings.starMargin = 1
        view.settings.fillMode = .precise
        view.settings.updateOnTouch = false
        view.settings.starSize = 6
        
        return view
    }()
    
    let starCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.purple
        label.font = Fonts.createBlackSize(10)
        label.text = "12"
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        setupPriceLabel()
        setupStarView()
        setupStarCountLabel()
    }
    
    func setupPriceLabel() {
        addSubview(priceLabel)
        priceLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 130, height: 17)
    }
    
    func setupStarView() {
        addSubview(starView)
        starView.anchor(top: priceLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 8)
    }
    
    func setupStarCountLabel() {
        addSubview(starCountLabel)
        starCountLabel.anchor(top: starView.topAnchor, left: starView.rightAnchor, bottom: starView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 5, paddingBottom: 0, paddingRight: 0, width: 50, height: 0)
    }
}

enum SessionRequestErrorCode: String {
    case noTutor = "Choose a tutor"
    case noSubject = "Choose a subject"
    case invalidDate = "Choose a valid date"
    case invalidDuration = "Choose a valid duration"
    case invalidPrice = "Enter a valid price"
    case noType = "Select a session type"
}

class SessionRequestErrorAccessoryView: BaseAccessoryView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = Fonts.createBoldSize(14)
        label.text = "Error message"
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        setupTitleLabel()
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
}

class SessionRequestAccessoryView: BaseAccessoryView {
    
}
