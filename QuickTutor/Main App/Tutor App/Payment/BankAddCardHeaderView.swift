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
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 1, paddingBottom: 0, paddingRight: 0, width: 100, height: 0)
    }
    
    func setupAddBankButton() {
        addSubview(addBankButton)
        addBankButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 1, width: 65, height: 0)
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
