//
//  QTLoadMoreTableViewCell.swift
//  QuickTutor
//
//  Created by Michael Burkard on 9/7/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTLoadMoreTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    static var nib: UINib {
        return UINib(nibName: String(describing: QTLoadMoreTableViewCell.self), bundle: nil)
    }
    
    static var reuseIdentifier: String {
        return String(describing: QTLoadMoreTableViewCell.self)
    }
    
}
