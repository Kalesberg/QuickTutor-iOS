//
//  QTLearnerDiscoverRecentlyActiveTableViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

protocol QTLearnerDiscoverRecentlyActiveDelegate {
    func onDidUpdateRecentlyActive(_ tutors: [AWTutor])
}

class QTLearnerDiscoverRecentlyActiveTableViewCell: UITableViewCell {

    var delegate: QTLearnerDiscoverRecentlyActiveDelegate? {
        didSet {
            learnerDiscoverRecentlyActiveVC.delegate = delegate
        }
    }
    
    var didClickTutor: ((_ tutor: AWTutor) -> ())?
    var didClickBtnMessage: ((_ tutor: AWTutor) -> ())?
    
    private let learnerDiscoverRecentlyActiveVC = QTLearnerDiscoverRecentlyActiveViewController(nibName: String(describing: QTLearnerDiscoverRecentlyActiveViewController.self), bundle: nil)
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTLearnerDiscoverRecentlyActiveTableViewCell.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        learnerDiscoverRecentlyActiveVC.category = QTLearnerDiscoverService.shared.category
        learnerDiscoverRecentlyActiveVC.subcategory = QTLearnerDiscoverService.shared.subcategory
        learnerDiscoverRecentlyActiveVC.didClickTutor = { tutor in
            self.didClickTutor?(tutor)
        }
        learnerDiscoverRecentlyActiveVC.didClickBtnMessage = { tutor in
            self.didClickBtnMessage?(tutor)
        }
        contentView.addSubview(learnerDiscoverRecentlyActiveVC.view)
        learnerDiscoverRecentlyActiveVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
