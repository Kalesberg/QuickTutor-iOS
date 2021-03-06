//
//  QTTutorDiscoverOpportunitiesSectionCollectionViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/4/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTTutorDiscoverOpportunitiesSectionCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Opportunities"
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(20)
        return label
    }()
    
    let controller = QTTutorDiscoverOpportunitiesViewController()
    
    static var reuseIdentifier: String {
        return String(describing: QTTutorDiscoverOpportunitiesSectionCollectionViewCell.self)
    }
    
    // MARK: - Functions
    func setupTitleLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor,
                          paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20,
                          width: 0, height: 0)
    }
    
    func setupController() {
        contentView.addSubview(controller.view)
        controller.view.anchor(top: titleLabel.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor,
                               paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0,
                               width: 0, height: 0)
    }
    
    func setupViews() {
        setupTitleLabel()
        setupController()
    }
    
    // MARK: - Actions
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
