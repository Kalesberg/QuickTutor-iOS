//
//  SessionTableCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/4/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class SessionTableCell: UITableViewCell {
    
    func setupViews() {
        setupMainView()
    }
    
    private func setupMainView() {
        backgroundColor = Colors.darkBackground
        accessoryType = .disclosureIndicator
        accessoryView?.isHidden = false
        textLabel?.text = "Mathematics"
        textLabel?.isHidden = false
        textLabel?.textColor = .white
        selectionStyle = .none
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
