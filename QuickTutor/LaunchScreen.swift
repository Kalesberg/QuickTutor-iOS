//
//  LaunchScreen.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/3/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class LaunchScreenView : BaseView {
	
	let imageView : UIImageView = {
		let imageView = UIImageView()
		
		imageView.image = #imageLiteral(resourceName: "social-email")
		
		return imageView
	}()
	
	
	override func configureView() {
		addSubview(imageView)
		super.configureView()
		backgroundColor = Colors.backgroundDark
		
		applyConstraints()
	}
	override func applyConstraints() {
		imageView.snp.makeConstraints { (make) in
			make.center.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.5)
			make.width.equalToSuperview().multipliedBy(0.5)
		}
	}
}

class LaunchScreen : BaseViewController {
	override var contentView: LaunchScreenView {
		return view as! LaunchScreenView
	}
	override func loadView() {
		view = LaunchScreenView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		//here.
	}
}
