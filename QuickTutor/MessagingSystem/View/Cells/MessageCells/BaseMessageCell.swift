//
//  BaseMessageCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/27/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class BaseMessageCell: UICollectionViewCell {
    var message: BaseMessage?

    func updateUI(message: UserMessage) {
        self.message = message
    }

    func setupViews() {}

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
