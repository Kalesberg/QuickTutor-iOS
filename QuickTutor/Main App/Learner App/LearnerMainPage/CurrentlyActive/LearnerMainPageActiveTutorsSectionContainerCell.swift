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
    
    let topTutorsController = LearnerMainPageActiveTutorsSectionController()
    
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
        topTutorsController.view.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

