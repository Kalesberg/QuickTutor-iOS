//
//  QTTutorDiscoverTipDetailParallaxHeaderView.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/14/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTTutorDiscoverTipDetailParallaxHeaderView: UIView {

    // MARK: - Properties
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var tipTitleView: UIView!
    @IBOutlet weak var tipNameLabel: UILabel!
    
    static var view: QTTutorDiscoverTipDetailParallaxHeaderView {
        return Bundle.main.loadNibNamed(String(describing: QTTutorDiscoverTipDetailParallaxHeaderView.self),
                                        owner: nil,
                                        options: nil)?.first
            as! QTTutorDiscoverTipDetailParallaxHeaderView
    }
    
    // MARK: - Functions
    func setData(tip: QTNewsModel) {
        bannerImageView.setImage(url: tip.image)
        tipNameLabel.text = tip.title
    }
    
    // MARK: - Acitons
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let screenWidth = UIScreen.main.bounds.width
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 60)
        gradientLayer.colors = [UIColor.clear,
                                UIColor.black.withAlphaComponent(0.8)].map({$0.cgColor})
        gradientLayer.locations = [0, 1]
        tipTitleView.layer.insertSublayer(gradientLayer, at: 0)
        tipTitleView.clipsToBounds = true
        
    }
}
