//
//  SearchBar.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/14/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class SearchBar: UIView {
    
    let icon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "navbar-search")
        iv.scaleImage()
        return iv
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Search for Tutors"
        label.font = Fonts.createSize(17)
        label.textColor = UIColor(red: 128 / 255, green: 128 / 255, blue: 128 / 255, alpha: 1.0)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    func setupViews() {
        setupMainView()
        setupIcon()
        setupLabel()
    }
    
    func setupMainView() {
        backgroundColor = .white
        layer.cornerRadius = 12
    }
    
    func setupIcon() {
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.18)
            make.height.equalToSuperview().multipliedBy(0.6)
            make.centerY.equalToSuperview()
        }
    }
    
    func setupLabel() {
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
