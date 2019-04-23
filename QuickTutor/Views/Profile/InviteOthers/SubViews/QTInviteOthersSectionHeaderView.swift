//
//  QTInviteOthersSectionHeaderView.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 4/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTInviteOthersSectionHeaderView: UIView {

    // MARK: - Properties
    static var view: QTInviteOthersSectionHeaderView {
        return Bundle.main.loadNibNamed(String(describing: QTInviteOthersSectionHeaderView.self), owner: nil, options: [:])?.first as! QTInviteOthersSectionHeaderView
    }
}
