//
//  EditListingView.swift
//  QuickTutor
//
//  Created by QuickTutor on 10/11/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class EditListingView: UIView {
	
	let tableView: UITableView = {
		let tableView = UITableView()
		tableView.estimatedRowHeight = 70
		tableView.showsVerticalScrollIndicator = false
		tableView.alwaysBounceVertical = true
		tableView.separatorStyle = .none
		tableView.backgroundColor = .clear
		return tableView
	}()
	
	let fakeBackground: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(hex: "484782")
		return view
	}()
	
    func configureView() {
        addSubview(fakeBackground)
        addSubview(tableView)
	}
	
    func applyConstraints() {
		fakeBackground.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.width.centerX.equalToSuperview()
			make.height.equalToSuperview().dividedBy(3)
		}
		tableView.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.width.centerX.equalToSuperview()
			if #available(iOS 11.0, *) {
				make.bottom.equalTo(safeAreaInsets.bottom)
			} else {
				make.bottom.equalTo(layoutMargins.bottom)
			}
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
