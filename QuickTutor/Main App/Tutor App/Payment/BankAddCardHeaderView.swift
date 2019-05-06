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

    let footer = UIView()

    override func configureView() {
        addSubview(addCard)
        addSubview(footer)
        super.configureView()

        footer.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        applyConstraints()
    }

    override func applyConstraints() {
        addCard.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
        footer.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}

class BankAddCardTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var didTapAddCard: (() -> ())?
    
    let addCard: UILabel = {
        let label = UILabel()
        label.text = "Add debit or credit card"
        label.textColor = .white
        label.font = Fonts.createSize(18)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let footer = UIView()
    
    func configureTableViewCell() {
        addSubview(addCard)
        addSubview(footer)
        
        let cellBackground = UIView()
        cellBackground.backgroundColor = Colors.darkBackground
        selectedBackgroundView = cellBackground
        footer.backgroundColor = Colors.darkBackground
        backgroundColor = Colors.darkBackground
        applyConstraints()
        
        addCard.setupTargets(gestureState: { gestureState in
            if gestureState == .ended {
                if let didTapAddCard = self.didTapAddCard {
                    didTapAddCard()
                }
            }
        })
    }
    
    func applyConstraints() {
        addCard.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
        footer.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}
