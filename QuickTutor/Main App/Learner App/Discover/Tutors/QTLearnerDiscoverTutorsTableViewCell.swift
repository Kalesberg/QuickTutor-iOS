//
//  QTLearnerDiscoverTutorsTableViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTLearnerDiscoverTutorsTableViewCell: UITableViewCell {

    var didClickTutor: ((_ tutor: AWTutor) -> ())?
    var didClickViewAllTutors: ((_ subject: String?, _ subcategory: String?, _ category: String?, _ tutors: [AWTutor], _ loadedAllTutors: Bool) -> ())?
    
    private let learnerDiscoverTutorsVC = QTLearnerDiscoverTutorsViewController(nibName: String(describing: QTLearnerDiscoverTutorsViewController.self), bundle: nil)
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTLearnerDiscoverTutorsTableViewCell.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        learnerDiscoverTutorsVC.isRisingTalent = QTLearnerDiscoverService.shared.isRisingTalent
        learnerDiscoverTutorsVC.isFirstTop = QTLearnerDiscoverService.shared.isFirstTop
        learnerDiscoverTutorsVC.category = QTLearnerDiscoverService.shared.category
        learnerDiscoverTutorsVC.subcategory = QTLearnerDiscoverService.shared.subcategory
        learnerDiscoverTutorsVC.didClickTutor = { tutor in
            self.didClickTutor?(tutor)
        }
        learnerDiscoverTutorsVC.didClickViewAllTutors = { subject, subcategory, category, tutors, loadedAllTutors in
            self.didClickViewAllTutors?(subject, subcategory, category, tutors, loadedAllTutors)
        }
        contentView.addSubview(learnerDiscoverTutorsVC.view)
        learnerDiscoverTutorsVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func updateDatasource() {
        if !QTLearnerDiscoverService.shared.isRisingTalent {
            learnerDiscoverTutorsVC.getTutors()
        }
    }
    
}
