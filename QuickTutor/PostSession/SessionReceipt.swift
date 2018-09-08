//
//  File.swift
//  QuickTutor
//
//  Created by QuickTutor on 9/8/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

class SessionReceiptView : BaseView {
	
	override func configureView() {
		super.configureView()
	}
	override func applyConstraints() {
		super.applyConstraints()
	}
	override func layoutSubviews() {
		super.layoutSubviews()
	}
}

class SessionReceipt : BaseViewController {
	
	override var contentView: SessionReviewView {
		return view as! SessionReceiptView
	}
	
	override func loadView() {
		view = SessionReceiptView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
}
