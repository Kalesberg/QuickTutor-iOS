//
//  ConnectionsBackgroundView.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/20/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class ConnectionsBackgroundView: UIView {
    
    static var userType: UserType?
    static let emptyStateLearnerText = "This is where your tutor connections will appear. You can add tutors by tapping on the \"add tutor\" icon in the top right corner of the screen."
    
    static let emptyStateTutorText = "This is where your learner connections will appear. It looks like you don't have any connections currently."
    
    static let emptyStateFallbackText = "This is where your connections will appear."
    
    static var emptyStateText: String {
        get {
            if let userType = userType {
                return userType == .learner ? emptyStateLearnerText : emptyStateTutorText
            } else {
                return emptyStateFallbackText
            }
        }
    }
    
    let backgroundViewIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.scaleImage()
        imageView.image = UIImage(named: "connections-icon")
        return imageView
    }()

    let title: UILabel = {
        let label = UILabel()
        label.text = emptyStateText
        label.font = Fonts.createSize(14)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    func configureView() {
        applyConstraints()
    }
    
    func applyConstraints() {
        setupBackgroundIcon()
        setupTitle()
    }

    func setupBackgroundIcon() {
        addSubview(backgroundViewIcon)
        backgroundViewIcon.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalToSuperview().multipliedBy(0.2)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.5)
        }
    }
    
    func setupTitle() {
        addSubview(title)
        title.snp.makeConstraints { make in
            make.top.equalTo(backgroundViewIcon.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        title.sizeToFit()
    }
    
    convenience init(userType: UserType) {
        ConnectionsBackgroundView.userType = userType
        self.init()
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
