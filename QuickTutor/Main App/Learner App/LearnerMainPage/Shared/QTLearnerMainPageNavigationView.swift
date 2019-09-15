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
        view.layer.cornerRadius = 20.5
        view.clipsToBounds = true
        view.backgroundColor = UIColor(hex: "010101")
        
        return view
    }()
    
    let searchIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "searchIconMain")
        
        return imageView
    }()
    
    var didSearchIconButtonClicked: (() -> Void)?
    
    // MARK: - Functions
    func setupLogoImageView() {
        addSubview(logoImageView)
        
        logoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 0, width: 170, height: 41)
    }
    
    func setupSearchIconView() {
        addSubview(searchIconView)
        
        searchIconView.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 20, paddingRight: 20, width: 41, height: 41)
        searchIconView.leftAnchor.constraint(greaterThanOrEqualTo: logoImageView.rightAnchor, constant: 20).isActive = true
        
        searchIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDidSearchIconTap)))
    }
    
    func setupSearchIconImageView() {
        searchIconView.addSubview(searchIconImageView)
        
        searchIconImageView.centerXAnchor.constraint(equalTo: searchIconView.centerXAnchor).isActive = true
        searchIconImageView.centerYAnchor.constraint(equalTo: searchIconView.centerYAnchor).isActive = true
        searchIconImageView.widthAnchor.constraint(equalToConstant: 21).isActive = true
        searchIconImageView.heightAnchor.constraint(equalToConstant: 21).isActive = true
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
