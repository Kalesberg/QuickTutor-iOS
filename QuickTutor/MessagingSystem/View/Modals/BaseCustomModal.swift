//
//  BaseCustomModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class BaseCustomModal: UIView {
    
    let backgroundBlurView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    let background: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 30.0 / 255.0, green: 30.0 / 255.0, blue: 38.0 / 255.0, alpha: 1.0)
        return view
    }()
    
    let titleBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 76.0 / 255.0, green: 94.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        view.layer.cornerRadius = 8
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ARE YOU SURE?"
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(18)
        label.numberOfLines = 0
        return label
    }()
    
    func setupViews() {
        setupBackgroundBlurView()
        setupBackground()
        setupTitleBackground()
        setupTitleLabel()
    }
    func setupBackground() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(background)
        background.anchor(top: nil, left: window.leftAnchor, bottom: nil, right: window.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 207)
        window.addConstraint(NSLayoutConstraint(item: background, attribute: .centerY, relatedBy: .equal, toItem: window, attribute: .centerY, multiplier: 1, constant: 0))
        background.alpha = 0
    }
    
    func setupBackgroundBlurView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(backgroundBlurView)
        backgroundBlurView.anchor(top: window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        backgroundBlurView.addGestureRecognizer(dismissTap)
        window.bringSubview(toFront: backgroundBlurView)
    }
    
    func setupTitleBackground() {
        background.addSubview(titleBackground)
        titleBackground.anchor(top: background.topAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
    }
    
    func setupTitleLabel() {
        background.addSubview(titleLabel)
        titleLabel.anchor(top: background.topAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 45)
    }
    
    func show() {
        background.alpha = 1
    }
    
    @objc func dismiss() {
        background.alpha = 0
        backgroundBlurView.alpha = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
