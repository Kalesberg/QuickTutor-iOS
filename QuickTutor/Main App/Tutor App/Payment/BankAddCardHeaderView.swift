//
//  AddCardTableViewCell.swift
//  QuickTutor
//
//  Created by Will Saults on 5/5/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class BankAddCardHeaderView: BaseView {
    var addCard: UILabel = {
        let label = UILabel()
        label.text = "Cards"
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    override func configureView() {
        addSubview(addCard)
        super.configureView()

        applyConstraints()
    }

    override func applyConstraints() {
        addCard.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
}

protocol BankManagerHeaderViewDelegate: class {
    func bankManagerHeaderViewDidTapAddBankButton(_ bankManagerHeaderView: BankManagerHeaderView)
}

class BankManagerHeaderView: UICollectionReusableView {
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Banks"
        label.textColor = .white
        label.font = Fonts.createBoldSize(16)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let addBankButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitleColor(Colors.purple, for: .normal)
        button.setTitle("Add new", for: .normal)
        button.titleLabel?.font = Fonts.createBlackSize(16)
        return button
    }()
    
    weak var delegate: BankManagerHeaderViewDelegate?
    
    func setupViews() {
        setupTitleLabel()
        setupAddBankButton()
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
        }
    }
    
    func setupAddBankButton() {
        addSubview(addBankButton)
        addBankButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(65)
        }
        addBankButton.addTarget(self, action: #selector(handleAddBank), for: .touchUpInside)
    }
    
    @objc func handleAddBank() {
        delegate?.bankManagerHeaderViewDidTapAddBankButton(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
