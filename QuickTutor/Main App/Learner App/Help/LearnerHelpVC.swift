//
//  Help.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.

import Foundation
import SnapKit
import UIKit

class LearnerHelpView: UIView {
    var subtitle = LeftTextLabel()
    var tableView = UITableView()
    var header = UIView()

    func configureView() {
        addSubview(subtitle)
        addSubview(tableView)
        addSubview(header)

        subtitle.label.text = "Choose an option"
        subtitle.label.font = Fonts.createSize(22)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.isScrollEnabled = false
        tableView.separatorInset.left = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = Colors.newBackground
        backgroundColor = Colors.newBackground
        header.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
    }

    func applyConstraints() {
        subtitle.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(70)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }

        subtitle.label.snp.remakeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.2)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(subtitle.snp.bottom).inset(-20)
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        header.snp.makeConstraints { make in
            make.width.equalTo(tableView.snp.width)
            make.top.equalTo(tableView.snp.top)
            make.left.equalTo(tableView.snp.left)
            make.height.equalTo(1)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        applyConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HelpHeaderScroll: MainLayoutTitleBackButton {
    var scrollView = BaseScrollView()
    var header = LeftTextLabel()

    override func configureView() {
        addSubview(scrollView)
        backgroundColor = Colors.darkBackground
        scrollView.addSubview(header)
        super.configureView()
        scrollView.backgroundColor = Colors.darkBackground
        header.label.font = Fonts.createSize(22)
    }

    override func applyConstraints() {
        super.applyConstraints()

        scrollView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
            make.centerX.equalToSuperview()
        }

        header.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(70)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }

        header.label.snp.remakeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.2)
        }
    }
}

class HelpSubmitButton: InteractableView, Interactable {
    var label = CenterTextLabel()

    override func configureView() {
        addSubview(label)
        super.configureView()

        backgroundColor = Colors.purple
        layer.cornerRadius = 20

        label.label.text = "SUBMIT"
        label.label.font = Fonts.createBoldSize(16)

        applyConstraints()
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

class SectionTitle: LeftTextLabel {
    override func configureView() {
        super.configureView()

        label.font = Fonts.createBoldSize(17)
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
            make.centerY.equalToSuperview().multipliedBy(1.4)
        }
    }

    func constrainSelf(top: ConstraintItem) {
        snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.top.equalTo(top)
        }
    }
}

class SectionSubTitle: LeftTextLabel {
    override func configureView() {
        super.configureView()

        label.font = Fonts.createBoldSize(16)
    }

    override func applyConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func constrainSelf(top: ConstraintItem) {
        snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.top.equalTo(top)
        }
    }
}

public class SectionBody: UILabel, BaseViewProtocol {
    public required init() {
        super.init(frame: .zero)
        configureView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }

    func configureView() {
        font = Fonts.createSize(15)
        textColor = Colors.grayText
        numberOfLines = 0
        sizeToFit()
    }

    func applyConstraints() {}

    func constrainSelf(top: ConstraintItem) {
        snp.makeConstraints { make in
            make.top.equalTo(top)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
        }
    }
}

class LearnerHelpVC: BaseViewController {
    override var contentView: LearnerHelpView {
        return view as! LearnerHelpView
    }

    var options = ["Account & Payments", "QuickTutor Guide", "Learner Handbook"]

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.tableView.register(CustomHelpTableViewCell.self, forCellReuseIdentifier: "helpCell")
        navigationItem.title = "Help"
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func loadView() {
        view = LearnerHelpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func handleNavigation() {}
}

extension LearnerHelpVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomHelpTableViewCell = tableView.dequeueReusableCell(withIdentifier: "helpCell") as! CustomHelpTableViewCell
        insertBorder(cell: cell)

        cell.textLabel?.text = options[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(AccountPaymentsVC(), animated: true)
        case 1:
            navigationController?.pushViewController(QTGuideVC(), animated: true)
        case 2:
            navigationController?.pushViewController(LearnerHandookVC(), animated: true)
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func insertBorder(cell: UITableViewCell) {
        let border = UIView(frame: CGRect(x: 0, y: cell.contentView.frame.size.height - 1.0, width: cell.contentView.frame.size.width, height: 1))
        border.backgroundColor = UIColor(red: 0.1180350855, green: 0.1170349047, blue: 0.1475356817, alpha: 1)
        cell.contentView.addSubview(border)
    }
}

class CustomHelpTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureTableViewCell() {
        let cellBackground = UIView()
        cellBackground.backgroundColor = UIColor.black
        selectedBackgroundView = cellBackground

        backgroundColor = Colors.registrationDark

        textLabel?.textColor = UIColor.white
        textLabel?.font = Fonts.createSize(17.0)

        accessoryType = .disclosureIndicator
    }
}
