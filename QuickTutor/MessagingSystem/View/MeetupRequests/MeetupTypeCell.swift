//
//  MeetupTypeCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 3/4/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

protocol MeetupTypeCellDelegate {
    func didSelect(option: String)
}

class MeetupTypeCell: UIView {
    
    var isSelected = false 
    var delegate: MeetupTypeCellDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "In Person"
        label.textAlignment = .center
        label.textColor = UIColor(hex: "89898D")
        label.font = Fonts.createSize(16)
        return label
    }()
    
    let selectionButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor(hex: "89898D").cgColor
        button.layer.borderWidth = 1.5
        button.layer.cornerRadius = 9
        button.isUserInteractionEnabled = true
        return button
    }()
    
    @objc func toggleSelected() {
        guard let lowercasedTitle = titleLabel.text?.lowercased() else { return }
        delegate?.didSelect(option: lowercasedTitle)
    }
    
    func setSelected() {
        selectionButton.backgroundColor = .green
        titleLabel.textColor = .green
    }
    
    func setUnselected() {
        selectionButton.backgroundColor = .clear
        titleLabel.textColor = Colors.border
    }
    
    func updateUI(title: String) {
        titleLabel.text = title
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        isUserInteractionEnabled = true
    }
    
    func setupViews() {
        setupTitleLabel()
        setupInputCircle()
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
    }
    
    private func setupInputCircle() {
        addSubview(selectionButton)
        selectionButton.anchor(top: titleLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 18, height: 18)
        addConstraint(NSLayoutConstraint(item: selectionButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        selectionButton.addTarget(self, action: #selector(toggleSelected), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
