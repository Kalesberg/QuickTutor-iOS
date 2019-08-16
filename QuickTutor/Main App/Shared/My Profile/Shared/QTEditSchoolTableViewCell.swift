//
//  QTEditSchoolTableViewCell.swift
//  QuickTutor
//
//  Created by JinJin Lee on 2019/8/17.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTEditSchoolTableViewCell: UITableViewCell {

    @IBOutlet weak var schoolLabel: UILabel!
    
    static var reuseIdentifier: String {
        return String(describing: QTEditSchoolTableViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
