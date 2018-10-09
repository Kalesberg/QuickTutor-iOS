//
//  InAppNotificationView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 9/21/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class InAppNotificationView: UIView {
    
    var customTopAnchor: NSLayoutConstraint?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(18)
        label.textAlignment = .left
        label.textColor = .white
        label.text = "Zach F."
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(12)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Do you have time for a session?"
        return label
    }()
    
    let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.currentUserColor().darker(by: 15)
        view.layer.cornerRadius = 3
        return view
    }()
    
    func show() {
        guard let window = UIApplication.shared.keyWindow else { return }
        customTopAnchor?.constant = UIApplication.shared.statusBarFrame.height
        UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            window.layoutIfNeeded()
        }.startAnimation()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func setupViews() {
        setupMainView()
        setupTitleLabel()
        setupMessageLabel()
        setupBottomLine()
    }
    
    func setupMainView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(self)
        self.anchor(top: nil, left: window.leftAnchor, bottom: nil, right: window.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 70)
        customTopAnchor = self.topAnchor.constraint(equalTo: window.topAnchor, constant: -75)
        customTopAnchor?.isActive = true
        backgroundColor = Colors.currentUserColor()
        addShadow()
    }
    
    func addShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 3
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 55, paddingBottom: 0, paddingRight: 40, width: 0, height: 20)
    }
    
    func setupMessageLabel() {
        addSubview(messageLabel)
        messageLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 6, paddingLeft: 40, paddingBottom: 15, paddingRight: 40, width: 0, height: 0)
    }
    
    func setupBottomLine() {
        addSubview(bottomLine)
        bottomLine.anchor(top: nil, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 6, paddingRight: 0, width: 40, height: 6)
        addConstraint(NSLayoutConstraint(item: bottomLine, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    
    func setupSwipeRecognizer() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipe.direction = .up
        addGestureRecognizer(swipe)
    }
    
    @objc func handleSwipe(_ recognizer: UISwipeGestureRecognizer) {
        guard let window = UIApplication.shared.keyWindow else { return }
        self.customTopAnchor?.constant = -75
        UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            window.layoutIfNeeded()
        }.startAnimation()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupSwipeRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
