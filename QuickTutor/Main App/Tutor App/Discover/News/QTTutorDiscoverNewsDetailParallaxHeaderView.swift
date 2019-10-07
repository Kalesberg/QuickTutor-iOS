//
//  QTTutorDiscoverNewsDetailParallaxHeaderView.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/13/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTTutorDiscoverNewsDetailParallaxHeaderView: UIView {

    // MARK: - Properties
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var newsTitleView: UIView!
    @IBOutlet weak var newsTitleLabel: UILabel!
    
    static var view: QTTutorDiscoverNewsDetailParallaxHeaderView {
        return Bundle.main.loadNibNamed(String(describing: QTTutorDiscoverNewsDetailParallaxHeaderView.self),
                                        owner: nil,
                                        options: nil)?.first
            as! QTTutorDiscoverNewsDetailParallaxHeaderView
    }
    
    var news: QTNewsModel!
    
    // MARK: - Functions
    func setData(news: QTNewsModel) {
        newsTitleLabel.text = news.title
        bannerImageView.setImage(url: news.image)
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
        newsTitleView.layer.insertSublayer(gradientLayer, at: 0)
        newsTitleView.clipsToBounds = true
    }
}
