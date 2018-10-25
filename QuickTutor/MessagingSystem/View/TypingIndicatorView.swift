//
//  TypingIndicatorView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 10/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import Lottie

class TypingIndicatorView: UIView {
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.layer.cornerRadius = 15
        iv.clipsToBounds = true
        iv.backgroundColor = .red
        return iv
    }()
    
    let lottieView: LOTAnimationView = {
        let view = LOTAnimationView(name: "typing")
        view.loopAnimation = true
        view.contentMode = .scaleAspectFit
        view.animationSpeed = 1.5
        return view
    }()
    
    func setupViews() {
        setupProfileImageView()
        setupLottieView()
        clipsToBounds = true
    }
    
    func setupLottieView() {
        addSubview(lottieView)
        lottieView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 52, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        lottieView.play()
    }
    
    func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 30, height: 30)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
