//
//  QTLearnerDiscoverTrendingTableViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTLearnerDiscoverTrendingTableViewCell: UITableViewCell {

    var didClickTrending: ((_ trending: MainPageFeaturedItem) -> ())?
    
    private let learnerDiscoverTrendingVC = QTLearnerDiscoverTrendingViewController(nibName: String(describing: QTLearnerDiscoverTrendingViewController.self), bundle: nil)
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTLearnerDiscoverTrendingTableViewCell.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code     
        learnerDiscoverTrendingVC.didClickTrending = { trending in
            self.didClickTrending?(trending)
        }
        contentView.addSubview(learnerDiscoverTrendingVC.view)
        learnerDiscoverTrendingVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

