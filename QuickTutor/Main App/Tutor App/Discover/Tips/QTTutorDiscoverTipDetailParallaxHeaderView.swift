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

    static var view: QTTutorDiscoverTipDetailParallaxHeaderView {
        return Bundle.main.loadNibNamed(String(describing: QTTutorDiscoverTipDetailParallaxHeaderView.self),
                                        owner: nil,
                                        options: nil)?.first
            as! QTTutorDiscoverTipDetailParallaxHeaderView
    }
    
    // MARK: - Functions
    func setData(tip: QTNewsModel) {
        bannerImageView.setImage(url: tip.image)
    }
    
    // MARK: - Acitons
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
