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
    
    let background : UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = #imageLiteral(resourceName: "launchScreenBackground")
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
	
	let icon : UIImageView = {
		let imageView = UIImageView()
		
		imageView.image = #imageLiteral(resourceName: "launchScreenImage")
		
		return imageView
	}()
	
	
	override func configureView() {
		addSubview(background)
        addSubview(icon)
		super.configureView()
        
		applyConstraints()
	}
	override func applyConstraints() {
        background.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
		icon.snp.makeConstraints { (make) in
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
