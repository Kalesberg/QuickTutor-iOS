//
//  QTLearnerDiscoverForYouTableViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTLearnerDiscoverForYouTableViewCell: UITableViewCell {

    var didClickTutor: ((_ tutor: AWTutor) -> ())?
    
    private let learnerDiscoverForYouVC = QTLearnerDiscoverForYouViewController(nibName: String(describing: QTLearnerDiscoverForYouViewController.self), bundle: nil)
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTLearnerDiscoverForYouTableViewCell.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
     
        learnerDiscoverForYouVC.category = QTLearnerDiscoverService.shared.category
        learnerDiscoverForYouVC.subcategory = QTLearnerDiscoverService.shared.subcategory
        learnerDiscoverForYouVC.didClickTutor = { tutor in
            self.didClickTutor?(tutor)
        }
        contentView.addSubview(learnerDiscoverForYouVC.view)
        learnerDiscoverForYouVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
