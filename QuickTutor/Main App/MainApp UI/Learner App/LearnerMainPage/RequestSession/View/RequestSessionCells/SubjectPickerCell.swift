//
//  RequestSessionTableViewCells.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class RequestSessionSubjectPickerCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTableViewCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    let subjectPicker = UIPickerView()

    var datasource = [String]() {
        didSet {
            subjectPicker.reloadAllComponents()
        }
    }

    var delegate: RequestSessionDelegate?

    func configureTableViewCell() {
        addSubview(subjectPicker)

        subjectPicker.delegate = self
        subjectPicker.dataSource = self

        backgroundColor = Colors.navBarColor
        selectionStyle = .none

        applyConstraints()
    }

    func applyConstraints() {
        subjectPicker.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension RequestSessionSubjectPickerCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_: UIPickerView, attributedTitleForRow row: Int, forComponent _: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: datasource[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: Fonts.createSize(20)])
        return attributedString
    }

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return datasource.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return datasource[row]
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        delegate?.sessionSubjectChanged(subject: datasource[row])
    }
}
