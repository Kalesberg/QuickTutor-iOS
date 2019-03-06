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

class LaunchScreenView: UIView {

    let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "launchScreenImage")
        return imageView
    }()
    
    func setupViews() {
        setupMainView()
        setupIcon()
    }
    
    func setupMainView() {
        backgroundColor = Colors.purple
    }
    
    func setupIcon() {
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class LaunchScreen: UIViewController {
    
    let contentView: LaunchScreenView = {
        let view = LaunchScreenView()
        return view
    }()
    
    override func loadView() {
        view = contentView
    }

}
