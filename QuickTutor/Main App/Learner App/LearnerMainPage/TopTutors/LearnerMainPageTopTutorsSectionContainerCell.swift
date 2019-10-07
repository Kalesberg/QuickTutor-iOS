//
//  LearnerMainPageTopTutorsSectionContainerCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SnapKit

class LearnerMainPageTopTutorsSectionContainerCell: UICollectionViewCell {
    
    let risingTalentImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "ic_rising_talent")
        
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rising Talents"
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(20)
        return label
    }()
    
    let seeAllBox: MockCollectionViewCell = {
        let cell = MockCollectionViewCell()
        cell.titleLabel.text = "View new tutors"
        cell.primaryButton.setTitle("View", for: .normal)
        return cell
    }()
    
    let topTutorsController = LearnerMainPageTopTutorsController()
    
    func setupViews() {
        setupMainView()
        setupRisingTalentImageView()
        setupTitleLabel()
        setupCollectionViewController()
        setupSeeAllBox()
    }
    
    func setupMainView() {
        backgroundColor = Colors.newScreenBackground
    }
    
    func setupRisingTalentImageView() {
        addSubview(risingTalentImageView)
        risingTalentImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(risingTalentImageView.snp.right).offset(10)
            make.height.equalTo(24)
        }
    }
    
    func setupCollectionViewController() {
        addSubview(topTutorsController.view)
        topTutorsController.view.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(528)
        }
    }
    
    func setupSeeAllBox() {
        addSubview(seeAllBox)
        seeAllBox.snp.makeConstraints { make in
            make.top.equalTo(topTutorsController.view.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        seeAllBox.profileDelegate = self
    }
    
    func handleSeeAllButton() {
        let userInfo = ["tutors": topTutorsController.datasource]
        NotificationCenter.default.post(name: NotificationNames.LearnerMainFeed.seeAllTopTutorsTapped, object: nil, userInfo: userInfo)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LearnerMainPageTopTutorsSectionContainerCell: ProfileModeToggleViewDelegate {
    func profleModeToggleView(_ profileModeToggleView: MockCollectionViewCell, shouldSwitchTo side: UserType) {
        handleSeeAllButton()
    }
}
