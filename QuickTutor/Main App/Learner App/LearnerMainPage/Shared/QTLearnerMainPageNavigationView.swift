//
//  QTLearnerMainPageNavigationView.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/24/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTLearnerMainPageNavigationView: UIView {

    // MARK: - Properties
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "ic_logo_circle")
        
        return imageView
    }()

    let searchIconView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 21
        view.clipsToBounds = true
        view.backgroundColor = UIColor(hex: "010101")
        
        return view
    }()
    
    let searchIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "searchIconMain")
        
        return imageView
    }()
    
    var didSearchIconButtonClicked: (() -> Void)?
    var searchIconViewLeft: NSLayoutConstraint?
    
    // MARK: - Functions
    func setupLogoImageView() {
        addSubview(logoImageView)
        
        logoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 0, width: 170, height: 42)
    }
    
    
    func setupSearchIconView() {
        addSubview(searchIconView)
        
        searchIconView.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 20, paddingRight: 20, width: 42, height: 42)
        let width = UIScreen.main.bounds.width - 62
        searchIconViewLeft = searchIconView.leftAnchor.constraint(equalTo: leftAnchor, constant: width)
        searchIconViewLeft?.isActive = true
        searchIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDidSearchIconTap)))
    }
    
    func setupSearchIconImageView() {
        searchIconView.addSubview(searchIconImageView)
        searchIconImageView.snp.makeConstraints { (make) in
            make.width.equalTo(21)
            make.height.equalTo(21)
            make.left.equalTo(searchIconView.snp.left).offset(10.5)
            make.centerY.equalToSuperview()
        }
    }
    
    func setupViews() {
        backgroundColor = Colors.newNavigationBarBackground
        
        setupLogoImageView()
        setupSearchIconView()
        setupSearchIconImageView()
    }
    
    // MARK: - Actions
    @objc func handleDidSearchIconTap() {
        if let didSearchIconButtonClicked = didSearchIconButtonClicked {
            didSearchIconButtonClicked()
        }
    }
    
    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    
}
