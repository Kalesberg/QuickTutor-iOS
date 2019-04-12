//
//  LearnerMainPageFeaturedSubjectCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class LearnerMainPageFeaturedSubjectCell: UICollectionViewCell {
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 4
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "cookingTest")
        return iv
    }()
    
    let infoBox: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.layer.cornerRadius = 4
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.clipsToBounds = true
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(14)
        label.text = "Mathmatics"
        return label
    }()
    
    let tryItButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.purple
        button.setTitle("Try it", for: .normal)
        button.layer.cornerRadius = 4
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(12)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    func setupViews() {
        setupBackgroundImageView()
        setupInfoBox()
        setupTitleLabel()
        setupTryItButton()
    }
    
    func setupBackgroundImageView() {
        addSubview(backgroundImageView)
        backgroundImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    func setupInfoBox() {
        addSubview(infoBox)
        infoBox.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 10, paddingRight: 30, width: 0, height: 50)
    }
    
    func setupTitleLabel() {
        infoBox.contentView.addSubview(titleLabel)
        titleLabel.anchor(top: infoBox.topAnchor, left: infoBox.leftAnchor, bottom: infoBox.bottomAnchor, right: infoBox.rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupTryItButton() {
        infoBox.contentView.addSubview(tryItButton)
        tryItButton.anchor(top: nil, left: nil, bottom: nil, right: infoBox.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 60, height: 30)
        addConstraint(NSLayoutConstraint(item: tryItButton, attribute: .centerY, relatedBy: .equal, toItem: infoBox, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func updateUI(_ featuredSubject: MainPageFeaturedItem) {
        titleLabel.text = featuredSubject.title
        backgroundImageView.sd_setImage(with: featuredSubject.backgroundImageUrl, completed: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
