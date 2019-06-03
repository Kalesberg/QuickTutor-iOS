//
//  SessionTableCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/4/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

protocol SessionTableCellDelegate: class {
    func sessionTableCell(_ cell: SessionTableCell, didSelectItemAt index: Int)
}

class SessionTableCell: UITableViewCell {
    
    weak var delegate: SessionTableCellDelegate?
    
    let button: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.contentHorizontalAlignment = .center
        button.backgroundColor = Colors.gray
        button.setTitle("Fake profile", for: .normal)
        button.layer.cornerRadius = 4
        return button
    }()
    
    func setupViews() {
        setupMainView()
        setupButton()
    }

    private func setupMainView() {
        backgroundColor = Colors.newScreenBackground
        selectionStyle = .none
    }
    
    func setupButton() {
        addSubview(button)
        button.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 60, paddingBottom: 5, paddingRight: 60, width: 0, height: 0)
        button.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        button.setupDimmingTitle()
    }
    
    @objc func handleButton() {
        delegate?.sessionTableCell(self, didSelectItemAt: tag)
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
