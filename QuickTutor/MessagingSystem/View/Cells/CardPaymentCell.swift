//
//  CardPaymentCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 6/29/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class CardPaymentCell: CardManagerTableViewCell {
    override func applyConstraints() {
        brand.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 50, height: 27)
        addConstraint(NSLayoutConstraint(item: brand, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

        hiddenCardNumbers.anchor(top: nil, left: brand.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 30, height: 20)
        addConstraint(NSLayoutConstraint(item: hiddenCardNumbers, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -2))

        last4.anchor(top: nil, left: hiddenCardNumbers.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 30, height: 20)
        addConstraint(NSLayoutConstraint(item: last4, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -2))

        defaultcard.layer.cornerRadius = 4
        defaultcard.clipsToBounds = true
        defaultcard.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 65, height: 30)
        addConstraint(NSLayoutConstraint(item: defaultcard, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
}
