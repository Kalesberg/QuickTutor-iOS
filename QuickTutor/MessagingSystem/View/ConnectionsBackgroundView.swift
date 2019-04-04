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
    
    static let emptyStateText = "This is where your tutor connections will appear. Currently, it looks like you don't have any connections. You can find tutors by searching in your home tab or you can add tutors by username by tapping on the icon located in the top right corner of this screen."
    
    
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
    
    override init(frame _: CGRect) {
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
