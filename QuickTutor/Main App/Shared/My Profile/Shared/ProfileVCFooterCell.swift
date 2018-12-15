//
//  ProfileVCFooterCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 11/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol ProfileVCFooterCellDelegate {
    func profileVCFooterCell(_ cell: ProfileVCFooterCell, didTap button: UIButton)
}

class ProfileVCFooterCell: UICollectionReusableView {
    
    var delegate: ProfileVCFooterCellDelegate?
    
    let inviteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Invite others", for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.currentUserColor()
        return button
    }()
    
    func setupViews() {
        setupInviteButton()
    }
    
    func setupInviteButton() {
        addSubview(inviteButton)
        inviteButton.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        inviteButton.addTarget(self, action: #selector(inviteOthers), for: .touchUpInside)
    }
    
    @objc func inviteOthers() {
        delegate?.profileVCFooterCell(self, didTap: inviteButton)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

