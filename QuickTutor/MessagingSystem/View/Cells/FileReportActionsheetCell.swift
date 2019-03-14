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
    let button: DimmableButton = {
        let button = DimmableButton()
        button.setTitleColor(.white, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.setImage(UIImage(named: "shareIconProfile"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 17, left: 0, bottom: 17, right: 0)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    var delegate: FileReportActionsheetCellDelegate?

    func setupViews() {
        setupButton()
    }

    func setupButton() {
        addSubview(button)
        button.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        button.addTarget(self, action: #selector(handleSelect), for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        backgroundColor = Colors.darkBackground
    }
    
    @objc func handleSelect() {
        delegate?.fileReportActionSheetCellDidSelect(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
