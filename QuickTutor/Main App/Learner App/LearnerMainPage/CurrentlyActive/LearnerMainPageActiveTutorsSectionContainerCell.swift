//
//  LearnerMainPageActiveTutorsSectionContainerCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class LearnerMainPageActiveTutorsSectionContainerCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Recently Active"
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(20)
        return label
    }()
    
    let topTutorsController = QTLearnerDiscoverRecentlyActiveViewController(nibName: String(describing: QTLearnerDiscoverRecentlyActiveViewController.self), bundle: nil)
    
    func setupViews() {
        setupMainView()
        setupTitleLabel()
        setupCollectionViewController()
    }
    
    func setupMainView() {
        backgroundColor = Colors.newScreenBackground
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 30)
    }
    
    func setupCollectionViewController() {
        addSubview(topTutorsController.view)
        QTLearnerDiscoverService.shared.category = nil
        QTLearnerDiscoverService.shared.subcategory = nil
        
        topTutorsController.view.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        topTutorsController.didClickTutor = { tutor in
            let userInfo: [String: Any] = ["uid": tutor.uid]
            NotificationCenter.default.post(name: NotificationNames.LearnerMainFeed.activeTutorCellTapped, object: nil, userInfo: userInfo)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

