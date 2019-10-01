//
//  QTLearnerDiscoverRisingTalentTableViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTLearnerDiscoverRisingTalentTableViewCell: UITableViewCell {

    var category: Category?
    
    var didClickTutor: ((_ tutor: AWTutor) -> ())?
    var didClickViewAllTutors: ((_ tutors: [AWTutor], _ loadedAllTutors: Bool) -> ())?
    
    private let learnerDiscoverRisingTalentVC = QTLearnerDiscoverRisingTalentViewController(nibName: String(describing: QTLearnerDiscoverRisingTalentViewController.self), bundle: nil)
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTLearnerDiscoverRisingTalentTableViewCell.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        learnerDiscoverRisingTalentVC.didClickTutor = { tutor in
            self.didClickTutor?(tutor)
        }
        learnerDiscoverRisingTalentVC.didClickViewAllTutors = { tutors, loadedAllTutors in
            self.didClickViewAllTutors?(tutors, loadedAllTutors)
        }
        contentView.addSubview(learnerDiscoverRisingTalentVC.view)
        learnerDiscoverRisingTalentVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setObject(_ object: Any?) {
        if nil == object {
            learnerDiscoverRisingTalentVC.category = nil
        } else if let category = object as? Category {
            learnerDiscoverRisingTalentVC.category = category
        }
    }
}
