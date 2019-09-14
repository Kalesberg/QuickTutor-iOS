//
//  QTTutorDiscoverCategoryParallaxHeaderView.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/12/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTTutorDiscoverCategoryParallaxHeaderView: UIView {

    // MARK: - Properties
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var categoryNameView: UIView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    static var view: QTTutorDiscoverCategoryParallaxHeaderView {
        return Bundle.main.loadNibNamed(String(describing: QTTutorDiscoverCategoryParallaxHeaderView.self),
                                        owner: nil,
                                        options: nil)?.first as! QTTutorDiscoverCategoryParallaxHeaderView
    }
    
    // MARK: - Functions
    func setData(category: Category) {
        categoryNameLabel.text = category.mainPageData.displayName
        bannerImageView.image = category.mainPageData.image
    }
    
    // MARK: - Actions
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let screenWidth = UIScreen.main.bounds.width
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 60)
        gradientLayer.colors = [UIColor.clear,
                                UIColor.black.withAlphaComponent(0.8)].map({$0.cgColor})
        gradientLayer.locations = [0, 1]
        categoryNameView.layer.insertSublayer(gradientLayer, at: 0)
        categoryNameView.clipsToBounds = true
    }
}
