//
//  CategoryCollectViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class CategoryCollectionViewCell : UICollectionViewCell {
    
    let label : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createSize(17)
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        
        return label
    }()

    let imageView : UIImageView = {
        let imageView = UIImageView()
    
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    required override init(frame: CGRect) {
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configureView() {
        addSubview(imageView)
        addSubview(label)
        
        applyConstraints()
    }
    func applyConstraints(){
        imageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }
        label.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom)
        }
    }
}

