//
//  FileReportActionsheetCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol FileReportActionsheetCellDelegate {
    func fileReportActionSheetCellDidSelect(_ fileReportActionSheetCell: FileReportActionsheetCell)
}

class FileReportActionsheetCell: UICollectionViewCell {
    let button: UIButton = {
        let button = UIButton()
        button.titleLabel?.textColor = .white
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = Fonts.createSize(16)
        return button
    }()

    var delegate: FileReportActionsheetCellDelegate?

    func setupViews() {
        setupButton()
    }

    func setupButton() {
        addSubview(button)
        button.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        button.addTarget(self, action: #selector(darken), for: .touchDown)
        button.addTarget(self, action: #selector(lighten), for: [.touchUpInside, .touchUpOutside])
        button.addTarget(self, action: #selector(handleSelect), for: .touchUpInside)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        backgroundColor = UIColor(hex: "272731")
    }

    @objc func darken() {
        backgroundColor = backgroundColor?.darker(by: 15)
        button.titleLabel?.textColor = button.titleLabel?.textColor.darker(by: 15)
    }

    @objc func lighten() {
        backgroundColor = backgroundColor?.lighter(by: 15)
        button.titleLabel?.textColor = button.titleLabel?.textColor.lighter(by: 15)
    }

    @objc func handleSelect() {
        delegate?.fileReportActionSheetCellDidSelect(self)
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                darken()
            } else {}
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
