//
//  SubjectSearchTableViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/30/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class SubjectSearchCategoryCell: UITableViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }

    func configureTableViewCell() {
        applyContraints()
    }

    func applContraints() {}

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
