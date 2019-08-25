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

    let searchIconImageView: UIView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.image = UIImage(named: "searchIconMain")
        
        return imageView
    }()
    
    var didSearchIconButtonClicked: (() -> Void)?
    
    // MARK: - Functions
    func setupLogoImageView() {
        addSubview(logoImageView)
        
        logoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 0, width: 170, height: 41)
    }
    
    func setupSearchIconImageView() {
        addSubview(searchIconImageView)
        
        searchIconImageView.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 20, paddingRight: 20, width: 41, height: 41)
        searchIconImageView.leftAnchor.constraint(greaterThanOrEqualTo: logoImageView.rightAnchor, constant: 20).isActive = true
        
        searchIconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDidSearchIconTap)))
    }
    
    func setupViews() {
        backgroundColor = Colors.newNavigationBarBackground
        
        setupLogoImageView()
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
