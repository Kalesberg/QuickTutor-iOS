//
//  SendRequestView.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/10/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class CancelRequestView: UIView {
    let container: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.navBarColor
        return view
    }()

    let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .center
        label.font = Fonts.createItalicSize(13)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.isHidden = true
        return label
    }()

    let cancelRequestButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(16)
        button.titleLabel?.textColor = .white
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = Colors.qtRed
        return button
    }()

    let requestSessionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send Request", for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(16)
        button.titleLabel?.textColor = .white
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = Colors.green
        return button
    }()
	
	let minimumSessionPriceLabel: UILabel = {
		let label = UILabel()
		label.text = "There is a $5.00 minimum to every session"
		label.textColor = Colors.grayText
		label.textAlignment = .center
		label.font = Fonts.createItalicSize(13)
		label.adjustsFontSizeToFitWidth = true
		label.numberOfLines = 1
		return label
	}()


    func configureView() {
        addSubview(container)
        container.addSubview(errorLabel)
        container.addSubview(cancelRequestButton)
        container.addSubview(requestSessionButton)
		container.addSubview(minimumSessionPriceLabel)
        isUserInteractionEnabled = true
        applyConstraints()
    }

    func applyConstraints() {
        container.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(1)
            make.width.centerX.equalToSuperview()
        }
        cancelRequestButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(35)
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview().multipliedBy(0.98)
        }
        requestSessionButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(35)
            make.right.equalToSuperview().inset(10)
			make.centerY.equalToSuperview().multipliedBy(0.98)
		}
        errorLabel.snp.makeConstraints { make in
            make.top.width.centerX.equalToSuperview()
            make.bottom.equalTo(cancelRequestButton.snp.top)
        }
		minimumSessionPriceLabel.snp.makeConstraints { (make) in
			make.centerX.width.bottom.equalToSuperview()
			make.top.equalTo(cancelRequestButton.snp.bottom)
		}
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override init(frame _: CGRect) {
        super.init(frame: .zero)
        configureView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
