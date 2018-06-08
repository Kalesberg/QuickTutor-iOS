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

class LaunchScreenView : BaseLayoutView {
	
	let imageView : UIImageView = {
		let imageView = UIImageView()
		
		imageView.image = #imageLiteral(resourceName: "launchScreenImage")
		
		return imageView
	}()
	
	
	override func configureView() {
		addSubview(imageView)
		super.configureView()
        
        backgroundColor = UIColor.init(hex: "272730")
        
		applyConstraints()
	}
	override func applyConstraints() {
		imageView.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
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
