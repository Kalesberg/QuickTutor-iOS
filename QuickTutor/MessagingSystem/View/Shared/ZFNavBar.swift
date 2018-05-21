//
//  ZFNavBar.swift
//  QuickTutor
//
//  Created by Zach Fuller on 5/7/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class ZFNavBar: UIView {
    
    let rightAccessoryView: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    let leftAccessoryView: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    var titleView = UIView()
    var delegate: CustomNavBarDisplayer?
    
    let search: SearchBar = {
        let bar = SearchBar()
        return bar
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(18)
        return label
    }()
    
    func setupViews() {
        setupMainView()
        setupLeftAccessoryView()
        setupTitleView()
        setupRightAccessoryView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.registrationDark
        layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.3, offset: CGSize(width: 0, height: 2.0), radius: 0)
    }
    
    func setupTitleView() {
        addSubview(titleView)
        titleView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 65, paddingBottom: 10, paddingRight: 65, width: 0, height: 35)
    }
    
    func setupRightAccessoryView() {
        addSubview(rightAccessoryView)
        rightAccessoryView.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 10, width: 35, height: 35)
        rightAccessoryView.addTarget(self, action: #selector(handleRightViewTapped), for: .touchUpInside)
    }
    
    func setupLeftAccessoryView() {
        addSubview(leftAccessoryView)
        leftAccessoryView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 10, paddingRight: 0, width: 35, height: 35)
        leftAccessoryView.addTarget(self, action: #selector(handleLeftViewTapped), for: .touchUpInside)
    }
    
    @objc func handleRightViewTapped() {
        delegate?.handleRightViewTapped()
    }
    
    @objc func handleLeftViewTapped() {
        delegate?.handleLeftViewTapped()
    }
    
    @objc func handleSearchTapped() {
        navigationController.pushViewController(SearchSubjects(), animated: true)
    }
    
    func addSearchBar() {
        addSubview(search)
        search.anchor(top: titleView.topAnchor, left: titleView.leftAnchor, bottom: titleView.bottomAnchor, right: titleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSearchTapped))
        tap.numberOfTapsRequired = 1
        search.addGestureRecognizer(tap)
    }
    
    func setupTitleLabelWithText(_ text: String) {
        titleLabel.text = text
        addSubview(titleLabel)
        titleLabel.anchor(top: titleView.topAnchor, left: titleView.leftAnchor, bottom: titleView.bottomAnchor, right: titleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol CustomNavBarDisplayer {
    var navBar: ZFNavBar { get set }
    func addNavBar()
    func handleLeftViewTapped()
    func handleRightViewTapped()
}

extension CustomNavBarDisplayer where Self: UIViewController {
    func addNavBar() {
        navBar.delegate = self
        view.addSubview(navBar)
        navBar.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -50, paddingRight: 0, width: 0, height: 150)
    }
    
    func handleLeftViewTapped() {
        
    }
    
    func handleRightViewTapped() {
        
    }
}


struct CustomNavButtons {
    static let backButton: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
        return button
    }()
    
    static let addTutorButton: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "addTutorByUsernameButton"), for: .normal)
        return button
    }()
}
