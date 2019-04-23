//
//  QTInviteOthersHeaderView.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 4/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTInviteOthersHeaderView: UIView {

    // MARK: - Properties
    static var view: QTInviteOthersHeaderView {
        return Bundle.main.loadNibNamed(String(describing: QTInviteOthersHeaderView.self), owner: nil, options: [:])?.first as! QTInviteOthersHeaderView
    }
    
    var didClickCopyLinkButton: (() -> ())?
    var didClickShareButton: (() -> ())?
    
    // MARK: - Lifecycle
    
    // MARK: - Actions
    @IBAction func onCopyLinkButtonClicked(_ sender: Any) {
        if let didClickCopyLinkButton = didClickCopyLinkButton {
            didClickCopyLinkButton()
        }
    }
    
    @IBAction func onShareButtonClicked(_ sender: Any) {
        if let didClickShareButton = didClickShareButton {
            didClickShareButton()
        }
    }
    
    // MARK: - Functions
    
    
}
