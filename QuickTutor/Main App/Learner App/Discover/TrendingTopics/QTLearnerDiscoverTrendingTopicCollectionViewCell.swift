//
//  QTLearnerDiscoverTrendingTopicCollectionViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 10/2/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTLearnerDiscoverTrendingTopicCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: QTCustomView!
    @IBOutlet weak var lblTopic: UILabel!
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTLearnerDiscoverTrendingTopicCollectionViewCell.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addShadow()
    }
    
    private func addShadow() {
        containerView.superview?.layer.applyShadow(color: Colors.darkGray.cgColor, opacity: 0.5, offset: CGSize(width: 0, height: 1), radius: 2)
    }

}
