//
//  QTPastSessionSectionHeaderView.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 5/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTPastSessionSectionHeaderView: UIView {

    @IBOutlet weak var dateLabel: UILabel!
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTPastSessionSectionHeaderView.self), bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTPastSessionSectionHeaderView.self)
    }
    
    static var view: QTPastSessionSectionHeaderView? {
        return Bundle.main.loadNibNamed(reuseIdentifier, owner: nil, options: [:])?.first as? QTPastSessionSectionHeaderView
    }
    
    func setData(date: String) {
        dateLabel.text = date
    }
}
