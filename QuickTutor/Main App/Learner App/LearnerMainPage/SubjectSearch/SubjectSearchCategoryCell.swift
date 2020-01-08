//
//  SubjectSearchTableViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/30/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class SubjectSearchCategoryCell: UITableViewCell {
    var isRotated = false
    let container = UIView()

    let title: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(17)
        return label
    }()

    let subtitle: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createLightSize(16)
        return label
    }()

    let dropDownArrow: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "backButton")
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        return imageView
    }()

    func configureTableViewCell() {
        addSubview(container)
        container.addSubview(title)
        container.addSubview(dropDownArrow)

        selectionStyle = .none
        backgroundColor = Colors.purple
        container.backgroundColor = Colors.newScreenBackground
        layer.cornerRadius = 4

        applyConstraints()
    }

    func applyConstraints() {
        container.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(4)
            make.height.right.centerY.equalToSuperview()
        }
        title.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(10)
            make.right.equalTo(dropDownArrow.snp.left)
            make.height.equalTo(20)
        }
        dropDownArrow.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }
    }

    func applyRotation() {
        UIView.animate(withDuration: 0.2) {
            let degrees: CGFloat = self.isRotated ? 0 : CGFloat.pi * 0.999 / 2
            self.dropDownArrow.transform = CGAffineTransform(rotationAngle: degrees)
            self.isRotated = !self.isRotated
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        container.cornerRadius([.topRight, .bottomRight], radius: 4)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }
}
