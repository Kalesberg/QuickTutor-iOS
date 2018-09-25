//
//  CategorySelectionCollectionViewCell.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/25/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class CategorySelectionCollectionViewCell: UICollectionViewCell {
    required override init(frame _: CGRect) {
        super.init(frame: .zero)
        configureView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let category: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createSize(14)
        label.alpha = 0.6

        return label
    }()

    let dot: UIView = {
        let view = UIView()

        view.clipsToBounds = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 3

        return view
    }()

    override var isSelected: Bool {
        didSet {
            category.alpha = isSelected ? 1.0 : 0.6
            dot.isHidden = isSelected ? false : true
            isUserInteractionEnabled = isSelected ? false : true
        }
    }

    func configureView() {
        addSubview(category)
        addSubview(dot)

        dot.isHidden = true

        applyConstraints()
    }

    func applyConstraints() {
        category.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        dot.snp.makeConstraints { make in
            make.top.equalTo(category.snp.bottom).inset(-3)
            make.height.width.equalTo(6)
            make.centerX.equalToSuperview()
        }
    }
}
