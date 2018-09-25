//
//  PickedSubjectsCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/31/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class PickedSubjectsCollectionViewCell: UICollectionViewCell {
    required override init(frame _: CGRect) {
        super.init(frame: .zero)
        configureView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let subject: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createSize(13)
        return label
    }()

    let subjectView: UIView = {
        let view = UIView()

        view.clipsToBounds = true
        view.backgroundColor = Colors.tutorBlue

        return view
    }()

    func configureView() {
        addSubview(subjectView)
        subjectView.addSubview(subject)

        applyConstraints()
    }

    func applyConstraints() {
        subjectView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        subject.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        subjectView.layer.cornerRadius = subjectView.frame.height / 2
    }
}
