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
    
    @objc func darken() {
        backgroundColor = backgroundColor?.darker(by: 15)
        textLabel?.textColor = textLabel?.textColor.darker(by: 15)
    }
    
    @objc func lighten() {
        backgroundColor = backgroundColor?.lighter(by: 15)
        textLabel?.textColor = textLabel?.textColor.lighter(by: 15)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        darken()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        lighten()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
