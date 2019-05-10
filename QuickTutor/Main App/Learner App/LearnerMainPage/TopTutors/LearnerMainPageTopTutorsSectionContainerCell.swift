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
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tutors on the rise"
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(20)
        return label
    }()
    
    let topTutorsController = LearnerMainPaigeTopTutorsController()
    
    let seeAllBox: MockCollectionViewCell = {
        let cell = MockCollectionViewCell()
        cell.titleLabel.text = "View new tutors"
        cell.primaryButton.setTitle("View", for: .normal)
        return cell
    }()
    
    func setupViews() {
        setupMainView()
        setupTitleLabel()
        setupCollectionViewController()
        setupSeeAllBox()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(30)
        }
    }
    
    func setupCollectionViewController() {
        addSubview(topTutorsController.view)
        topTutorsController.view.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(470)
        }
    }
    
    func setupSeeAllBox() {
        let shadowView = UIView()
        shadowView.backgroundColor = .clear
        
        shadowView.layer.shadowColor = UIColor(white: 0, alpha: 0.06).cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowRadius = 4
        shadowView.layer.shadowOffset = .zero
        
        addSubview(shadowView)
        shadowView.snp.makeConstraints { make in
            make.top.equalTo(topTutorsController.view.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        
        shadowView.addSubview(seeAllBox)
        seeAllBox.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func handleSeeAllButton(_ sender: UIButton) {
        let userInfo: [AnyHashable: Any] = ["tutors": topTutorsController.datasource]
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
