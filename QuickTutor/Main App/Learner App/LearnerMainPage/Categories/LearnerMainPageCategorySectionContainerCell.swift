//
//  CategoryCollectionView.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

protocol CategoryTableViewCellDelegate: class {
    func categoryTableViewCell(_ cell: LearnerMainPageCategorySectionContainerCell, didSelect category: CategoryNew)
}

class BaseLearnerMainPageContainerCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Categories"
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(20)
        return label
    }()
    
    var childCollectionViewController = UIViewController()
    
    func setupViews() {
        setupTitleLabel()
        setupChildCollectionViewController()
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 30)
    }
    
    func setupChildCollectionViewController() {
        addSubview(childCollectionViewController.view)
        childCollectionViewController.view.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LearnerMainPageCategorySectionContainerCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Categories"
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(20)
        return label
    }()
    
    weak var delegate: CategoryTableViewCellDelegate?

    var categorySectionController = CategorySectionController()
    
    func setupViews() {
        setupMainView()
        setupTitleLabel()
        setupCollectionViewController()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 30)
    }
    
    func setupCollectionViewController() {
        addSubview(categorySectionController.view)
        categorySectionController.view.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

