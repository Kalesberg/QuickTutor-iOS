//
//  ProfileVCCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 11/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class ProfileCVCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? Colors.newScreenBackground.darker(by: 30) : Colors.newScreenBackground
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSemiBoldSize(16)
        label.textColor = .white
        return label
    }()
    
    let icon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray
        return view
    }()
    
    func setupViews() {
        setupMainView()
        setupTitleLabel()
        setupIcon()
        setupSeparator()
    }
    
    private func setupMainView() {
        backgroundColor = Colors.newScreenBackground
    }
    
    private func setupTitleLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupIcon() {
        contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupSeparator() {
        contentView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
