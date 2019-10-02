//
//  LearnerMainPageFeaturedSubjectCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class LearnerMainPageFeaturedSubjectCell: UICollectionViewCell {
    
    var didClickBtnTryIt: (() -> Void)?
    
    static var reuseIdentifier: String {
        return String(describing: LearnerMainPageFeaturedSubjectCell.self)
    }
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 4
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.isSkeletonable = true
        
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
        label.backgroundColor = Colors.newScreenBackground
        label.isHidden = true
        
        return label
    }()
    
    let tryItButton: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.purple
        button.setTitle("Try it", for: .normal)
        button.layer.cornerRadius = 4
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(12)
        button.isUserInteractionEnabled = true
        button.isHidden = true
        
        return button
    }()
    
    func setupViews() {
        setupBackgroundImageView()
        setupInfoBox()
        setupTitleLabel()
        setupTryItButton()
    }
    
    func setupBackgroundImageView() {
        contentView.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview()
        }
    }
    
    func setupInfoBox() {
        contentView.addSubview(infoBox)
        infoBox.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(30)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(50)
        }
    }
    
    func setupTitleLabel() {
        infoBox.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
    
    func setupTryItButton() {
        infoBox.contentView.addSubview(tryItButton)
        tryItButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        tryItButton.addTarget(self, action: #selector(onClickBtnTryIt), for: .touchUpInside)
    }
    
    @objc private func onClickBtnTryIt() {
        didClickBtnTryIt?()
    }
    
    func updateUI(_ featuredSubject: MainPageFeaturedItem) {
        if self.isSkeletonActive {
            self.hideSkeleton()
        }
        titleLabel.backgroundColor = .clear
        titleLabel.text = featuredSubject.title
        
        tryItButton.setTitle(featuredSubject.subject, for: .normal)
        
        titleLabel.isHidden = false
        tryItButton.isHidden = false
        backgroundImageView.sd_setImage(with: featuredSubject.backgroundImageUrl, completed: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isSkeletonable = true
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
