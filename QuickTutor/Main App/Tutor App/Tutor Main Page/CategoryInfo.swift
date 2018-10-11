//
//  CategoryInfo.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit

class CategoryInfoView: MainLayoutTitleBackButton {
    let tableView: UITableView = {
        let tableView = UITableView()

        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 250
        tableView.isScrollEnabled = true
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false

        return tableView
    }()

    override func configureView() {
        addSubview(tableView)
        super.configureView()
    }

    override func applyConstraints() {
        super.applyConstraints()

        tableView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }
}

class CategoryInfo: BaseViewController {
    override var contentView: CategoryInfoView {
        return view as! CategoryInfoView
    }

    override func loadView() {
        view = CategoryInfoView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.tableView.delegate = self
        contentView.tableView.dataSource = self

        contentView.title.label.text = category?.mainPageData.displayName

        contentView.tableView.register(PriceSuggesterTableCellView.self, forCellReuseIdentifier: "priceSuggesterTableCellView")
    }

    var category: Category?
}

class PriceSuggesterTableCellView: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }

    let bubble1: UILabel = {
        let view = UILabel()

        view.backgroundColor = .clear
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1.5
        view.layer.borderColor = Colors.learnerPurple.cgColor
        view.textAlignment = .center
        view.font = Fonts.createBoldSize(16)
        view.textColor = .white

        return view
    }()

    let bubble2: UILabel = {
        let view = UILabel()

        view.backgroundColor = .clear
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1.5
        view.layer.borderColor = Colors.gold.cgColor
        view.textAlignment = .center
        view.font = Fonts.createBoldSize(16)
        view.textColor = .white

        return view
    }()

    let bubble3: UILabel = {
        let view = UILabel()

        view.backgroundColor = .clear
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1.5
        view.layer.borderColor = Colors.tutorBlue.cgColor
        view.textAlignment = .center
        view.font = Fonts.createBoldSize(16)
        view.textColor = .white

        return view
    }()

    let advancedLabel: UILabel = {
        let label = UILabel()

        label.text = "Advanced"
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)

        return label
    }()

    let proLabel: UILabel = {
        let label = UILabel()

        label.text = "Pro"
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)

        return label
    }()

    let expertLabel: UILabel = {
        let label = UILabel()

        label.text = "Expert"
        label.textColor = .white
        label.font = Fonts.createBoldSize(18)

        return label
    }()

    let line1: UIView = {
        let view = UIView()

        view.backgroundColor = .white

        return view
    }()

    let line2: UIView = {
        let view = UIView()

        view.backgroundColor = .white

        return view
    }()

    let suggestionLabel: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.text = "Pricing Suggestions"
        label.font = Fonts.createSize(20)

        return label
    }()

    func configureView() {
        contentView.addSubview(bubble1)
        contentView.addSubview(bubble2)
        contentView.addSubview(bubble3)
        contentView.addSubview(line1)
        contentView.addSubview(line2)
        contentView.addSubview(advancedLabel)
        contentView.addSubview(proLabel)
        contentView.addSubview(expertLabel)
        contentView.addSubview(suggestionLabel)

        backgroundColor = .clear
        selectionStyle = .none

        applyConstraints()
    }

    func applyConstraints() {
        suggestionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        bubble1.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.height.equalTo(28)
            make.width.equalTo(79)
        }
        proLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.85)
            make.centerX.equalTo(bubble1)
        }
        line1.snp.makeConstraints { make in
            make.right.equalTo(bubble1.snp.left).inset(-11)
            make.width.equalTo(18)
            make.height.equalTo(1)
            make.centerY.equalToSuperview().multipliedBy(1.5)
        }
        line2.snp.makeConstraints { make in
            make.left.equalTo(bubble1.snp.right).inset(-11)
            make.width.equalTo(18)
            make.height.equalTo(1)
            make.centerY.equalToSuperview().multipliedBy(1.5)
        }
        bubble2.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.height.equalTo(28)
            make.width.equalTo(79)
            make.left.equalTo(line2.snp.right).inset(-11)
        }
        advancedLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.85)
            make.centerX.equalTo(bubble3)
        }
        bubble3.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.height.equalTo(28)
            make.width.equalTo(79)
            make.right.equalTo(line1.snp.left).inset(-11)
        }
        expertLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.85)
            make.centerX.equalTo(bubble2)
        }
    }
}

extension CategoryInfo: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 3
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 350
        case 1:
            return UITableView.automaticDimension
        case 2:
            return 110
        default:
            break
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:

            let cell = UITableViewCell()

            cell.selectionStyle = .none
            cell.backgroundColor = .clear

            let imageView: UIImageView = {
                let view = UIImageView()

                view.contentMode = .scaleAspectFill
                view.clipsToBounds = true
                view.layer.cornerRadius = 20
                view.layer.masksToBounds = true

                view.image = category?.mainPageData.image

                return view
            }()

            cell.contentView.addSubview(imageView)

            imageView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(225)
                make.height.equalTo(300)
            }

            return cell

        case 1:
            let cell = UITableViewCell()

            cell.backgroundColor = .clear
            cell.selectionStyle = .none

            let label: UILabel = {
                let label = UILabel()

                let formattedString = NSMutableAttributedString()

                formattedString
                    .bold((category?.mainPageData.displayName)! + "\n", 24, .white)
                    .regular("\n", 20, .clear)
                    .regular((category?.mainPageData.categoryInfo)! + "\n", 15, .white)
                    .regular("\n", 20, .clear)
                    .regular("Sub-Categories\n", 20, .white)
                    .regular("\n", 10, .clear)
                    .regular((category?.subcategory.subcategories.compactMap({ $0 }).joined(separator: ", "))! + "\n", 15, Colors.grayText)

                label.attributedText = formattedString
                label.numberOfLines = 0

                return label
            }()

            cell.contentView.addSubview(label)

            label.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.9)
                make.centerX.equalToSuperview()
            }

            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "priceSuggesterTableCellView", for: indexPath) as! PriceSuggesterTableCellView

            let prices = category?.mainPageData.suggestedPrices

            cell.bubble1.text = "$\(prices![1])"
            cell.bubble2.text = "$\(prices![2])"
            cell.bubble3.text = "$\(prices![0])"

            return cell
        default:
            break
        }

        return UITableViewCell()
    }
}
