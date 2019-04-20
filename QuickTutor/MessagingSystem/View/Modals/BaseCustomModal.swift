//
//  BaseCustomModal.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class BaseCustomModal: UIView {
    var isShown = false

    let backgroundBlurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let visualEffectsView = UIVisualEffectView(effect: blur)
        visualEffectsView.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        return visualEffectsView
    }()

    let background: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.darkBackground
        view.alpha = 0
        view.layer.cornerRadius = 4
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Are you sure?"
        label.textColor = .white
        label.textAlignment = .center
        label.font = Fonts.createBoldSize(16)
        label.numberOfLines = 0
        return label
    }()

    var backgroundCenterYAnchor: NSLayoutConstraint?
    var backgroundHeightAnchor: NSLayoutConstraint?

    func setupViews() {
        setupBackgroundBlurView()
        setupBackground()
        setupTitleLabel()
    }
    
    func removeViews() {
        titleLabel.removeFromSuperview()
        background.removeFromSuperview()
        backgroundBlurView.removeFromSuperview()
    }

    func setupBackground() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(background)
        background.anchor(top: nil, left: window.leftAnchor, bottom: nil, right: window.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 0)
        backgroundCenterYAnchor = background.centerYAnchor.constraint(equalTo: window.centerYAnchor, constant: 500)
        backgroundCenterYAnchor?.isActive = true
    }

    func setupBackgroundBlurView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(backgroundBlurView)
        backgroundBlurView.anchor(top: window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        backgroundBlurView.addGestureRecognizer(dismissTap)
        window.bringSubviewToFront(backgroundBlurView)
    }
    
    func setupTitleLabel() {
        background.addSubview(titleLabel)
        titleLabel.anchor(top: background.topAnchor, left: background.leftAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    }
    
    func setHeightTo(_ height: CGFloat) {
        backgroundHeightAnchor = background.heightAnchor.constraint(equalToConstant: height)
        backgroundHeightAnchor?.isActive = true
        background.layoutIfNeeded()
    }
    
    func show() {
        guard !isShown else { return }
        isShown = true
        let backgroundAnimator = UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.backgroundBlurView.alpha = 1
        }
        
        let contentAnimator = UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.background.alpha = 1
            self.background.transform = CGAffineTransform(translationX: 0, y: -500)
        }
        
        backgroundAnimator.addCompletion { (position) in
            contentAnimator.startAnimation()
        }
        backgroundAnimator.startAnimation()
    }
    
    @objc func dismiss() {
        isShown = false
        let backgroundAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            self.backgroundBlurView.alpha = 0
        }
        
        let contentAnimator = UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.background.alpha = 0
            self.background.transform = CGAffineTransform(translationX: 0, y: 500)
        }
        
        backgroundAnimator.addCompletion { (position) in
            self.removeViews()
        }
        
        contentAnimator.startAnimation()
        backgroundAnimator.startAnimation()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
