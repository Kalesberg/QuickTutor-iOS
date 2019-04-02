//
//  SessionCellActionView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class SessionCellActionView: UIView {
    var delegate: SessionCellActionViewDelegate?

    let cellActionContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        return view
    }()

    let actionButton1: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "messageSessionButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.imageView?.contentMode = .scaleAspectFit
        button.tag = 1
        return button
    }()

    let actionButton2: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "messageSessionButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.imageView?.contentMode = .scaleAspectFit
        button.tag = 2
        return button
    }()

    let actionButton3: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "messageSessionButton"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.imageView?.contentMode = .scaleAspectFit
        button.tag = 3
        return button
    }()
    
    func setupViews() {
        self.alpha = 0
        setupActionContainerView()
        setupActionButtonTargets()
    }
    
    func setupActionContainerView() {
        addSubview(cellActionContainerView)
        cellActionContainerView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(didSelectbackground))
        cellActionContainerView.addGestureRecognizer(dismissTap)
    }
    
    private func setupActionButton1() {
        cellActionContainerView.addSubview(actionButton1)
        actionButton1.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 40, height: 40)
        addConstraint(NSLayoutConstraint(item: actionButton1, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        actionButton1.addTarget(self, action: #selector(didSelectButton(sender:)), for: .touchUpInside)
    }
    
    private func setupActionButton2() {
        cellActionContainerView.addSubview(actionButton2)
        actionButton2.anchor(top: nil, left: nil, bottom: nil, right: actionButton1.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 40, height: 40)
        addConstraint(NSLayoutConstraint(item: actionButton2, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        actionButton2.addTarget(self, action: #selector(didSelectButton(sender:)), for: .touchUpInside)
    }
    
    private func setupActionButton3() {
        cellActionContainerView.addSubview(actionButton3)
        actionButton3.anchor(top: nil, left: nil, bottom: nil, right: actionButton2.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 40, height: 40)
        addConstraint(NSLayoutConstraint(item: actionButton3, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        actionButton3.addTarget(self, action: #selector(didSelectButton(sender:)), for: .touchUpInside)
    }
    
    func setupActionButtonTargets() {
        
    }
    
    func showActionContainerView() {
        UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            self.alpha = 1
        }.startAnimation()
    }
    
    @objc func hideActionContainerView() {
        UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            self.alpha = 0
        }.startAnimation()
    }
    
    func updateButtonImages(_ images: [UIImage]) {
        let buttons = [actionButton1, actionButton2, actionButton3]
        for x in 0...images.count - 1 {
            buttons[buttons.count - (x + 1)].setImage(images[x], for: .normal)
        }
    }
    
    func setupAsSingleButton() {
        setupActionButton1()
    }
    
    func setupAsDoubleButton() {
        setupAsSingleButton()
        setupActionButton2()
    }
    
    func setupAsTripleButton() {
        setupAsDoubleButton()
        setupActionButton3()
    }
    
    @objc func didSelectButton(sender: UIButton) {
        hideActionContainerView()
        delegate?.cellActionView(self, didSelectButtonAt: sender.tag)
    }
    
    @objc func didSelectbackground() {
        hideActionContainerView()
        delegate?.cellActionViewDidSelectBackground(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

