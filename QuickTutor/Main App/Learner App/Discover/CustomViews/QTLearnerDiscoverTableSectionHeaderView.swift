//
//  QTLearnerDiscoverTableSectionHeaderView.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTLearnerDiscoverTableSectionHeaderView: UIView {

    var title: String? {
        didSet {
            lblTitle.text = title
        }
    }
    
    @IBOutlet weak var lblTitle: UILabel!
    
}
