//
//  VideoSessionView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 6/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import TwilioVideo
import UIKit
import Lottie

class VideoSessionView: UIView {
    
    let partnerFeed: TVIVideoView = {
        let view = TVIVideoView()
        view.contentMode = .scaleAspectFill
        return view
    }()

    let cameraPreviewView: TVIVideoView = {
        let view = TVIVideoView()
        view.layer.cornerRadius = 8
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    let bottomHudContainerView: UIView  = {
        let view = UIView()
        return view
    }()
    
    let buttonStackView: UIStackView = {
        let sv = UIStackView()
        sv.spacing = 35
        sv.distribution = .fillEqually
        return sv
    }()
    
    let pauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "newPauseSessionButton"), for: .normal)
        return button
    }()
    
    let endButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "newEndSessionButton"), for: .normal)
        return button
    }()
    
    let swapCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "newSwitchCameraButton"), for: .normal)
        return button
    }()
    
    let timer: CountdownTimer = {
        let timer = CountdownTimer()
        timer.label.textAlignment = .center
        timer.label.font = Fonts.createSize(12)
        return timer
    }()
    
    let swipeContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: effect)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: effect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        view.contentView.addSubview(vibrancyEffectView)
        vibrancyEffectView.anchor(top: view.contentView.topAnchor, left: view.contentView.leftAnchor, bottom: view.contentView.bottomAnchor, right: view.contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        view.alpha = 0
        return view
    }()
    
    var pausedSessionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Paused"
        label.font = Fonts.createBoldSize(16)
        return label
    }()
    
    var loadingIndicator: LOTAnimationView = {
        let view = LOTAnimationView(name: "connecting")
        view.loopAnimation = true
        return view
    }()
    
    var hudShown = true
    var behavior: VideoSessionPartnerFeedBehavior!
    
    var panRecognizer: UIPanGestureRecognizer!
    var fadeTapRecognizer: UITapGestureRecognizer!
    
    var swipeContainerViewBottomAnchor: NSLayoutConstraint?
    
    var cameraPreviewBottomAnchor: NSLayoutConstraint?
    var cameraPreviewTopAnchor: NSLayoutConstraint?
    var cameraPreviewLeftAnchor: NSLayoutConstraint?
    var cameraPreviewRightAnchor: NSLayoutConstraint?

    func setupViews() {
        setupMainView()
        setupLoadingIndicator()
        setupPartnerFeed()
        setupBlurView()
        setupPausedSessionLabel()
        setupBottomHudContainerView()
        setupButtonStackView()
        setupTimer()
        setupSwipeContainerView()
        setupCameraPreviewView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupPartnerFeed() {
        addSubview(partnerFeed)
        partnerFeed.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupBlurView() {
        addSubview(blurView)
        blurView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupPausedSessionLabel() {
        blurView.contentView.addSubview(pausedSessionLabel)
        pausedSessionLabel.anchor(top: nil, left: blurView.leftAnchor, bottom: nil, right: blurView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        addConstraint(NSLayoutConstraint(item: pausedSessionLabel, attribute: .centerY, relatedBy: .equal, toItem: blurView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func setupLoadingIndicator() {
        addSubview(loadingIndicator)
        loadingIndicator.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
        addConstraint(NSLayoutConstraint(item: loadingIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: loadingIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        loadingIndicator.play()
    }
    
    func setupBottomHudContainerView() {
        addSubview(bottomHudContainerView)
        bottomHudContainerView.anchor(top: nil, left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
    }
    
    func setupButtonStackView() {
        bottomHudContainerView.addSubview(buttonStackView)
        buttonStackView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 250, height: 60)
        addConstraint(NSLayoutConstraint(item: buttonStackView, attribute: .centerX, relatedBy: .equal, toItem: bottomHudContainerView, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: buttonStackView, attribute: .centerY, relatedBy: .equal, toItem: bottomHudContainerView, attribute: .centerY, multiplier: 1, constant: 0))
        buttonStackView.addArrangedSubview(pauseButton)
        buttonStackView.addArrangedSubview(endButton)
        buttonStackView.addArrangedSubview(swapCameraButton)
    }
    
    func setupTimer() {
        bottomHudContainerView.addSubview(timer)
        timer.anchor(top: nil, left: leftAnchor, bottom: buttonStackView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupSwipeContainerView() {
        addSubview(swipeContainerView)
        swipeContainerView.anchor(top: getTopAnchor(), left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        swipeContainerViewBottomAnchor = swipeContainerView.bottomAnchor.constraint(equalTo: getBottomAnchor(), constant: -110)
        swipeContainerViewBottomAnchor?.isActive = true
    }
    
    func setupCameraPreviewView() {
        swipeContainerView.addSubview(cameraPreviewView)
        cameraPreviewView.frame = CGRect(origin: center, size: CGSize(width: 100, height: 150))
        addConstraint(NSLayoutConstraint(item: cameraPreviewView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 100))
        addConstraint(NSLayoutConstraint(item: cameraPreviewView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 150))
        setupCornerConstraints()
        behavior = VideoSessionPartnerFeedBehavior()
        behavior.view = cameraPreviewView
        behavior.delegate = self
    }
    
    func setupCornerConstraints() {
        cameraPreviewTopAnchor = cameraPreviewView.topAnchor.constraint(equalTo: swipeContainerView.topAnchor, constant: 10)
        cameraPreviewRightAnchor = cameraPreviewView.rightAnchor.constraint(equalTo: swipeContainerView.rightAnchor, constant: -10)
        cameraPreviewBottomAnchor = cameraPreviewView.bottomAnchor.constraint(equalTo: swipeContainerView.bottomAnchor, constant: -10)
        cameraPreviewLeftAnchor = cameraPreviewView.leftAnchor.constraint(equalTo: swipeContainerView.leftAnchor, constant: 10)
        
        cameraPreviewBottomAnchor?.isActive = true
        cameraPreviewLeftAnchor?.isActive = true
    }
    
    func setupFadeTapRecognizer() {
        fadeTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(TestVC.handleTap(_:)))
        fadeTapRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(fadeTapRecognizer)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        hudShown ? hideHud() : showHud()
    }
    
    func showHud() {
        hudShown = true
        swipeContainerViewBottomAnchor?.constant = -110
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.bottomHudContainerView.alpha = 1
            if self.behavior.cardPosition == .bottomRight || self.behavior.cardPosition == .bottomLeft {
                self.behavior.view.center = CGPoint(x: self.behavior.view.center.x, y: self.behavior.view.center.y - 110)
            }
            self.layoutIfNeeded()
        })
    }
    
    func hideHud() {
        hudShown = false
        swipeContainerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.bottomHudContainerView.alpha = 0
            if self.behavior.cardPosition == .bottomRight || self.behavior.cardPosition == .bottomLeft {
                self.behavior.view.center = CGPoint(x: self.behavior.view.center.x, y: self.behavior.view.center.y + 110)
            }
            self.layoutIfNeeded()
        })
    }
    
    func disableAllCornerPinning() {
        cameraPreviewTopAnchor?.isActive = false
        cameraPreviewBottomAnchor?.isActive = false
        cameraPreviewRightAnchor?.isActive = false
        cameraPreviewLeftAnchor?.isActive = false
    }
    
    func pause() {
        UIView.animate(withDuration: 0.25) {
            self.blurView.alpha = 1
        }
    }
    
    func unpause() {
        UIView.animate(withDuration: 0.25) {
            self.blurView.alpha = 0
        }
    }
    
    func showLoadingAnimation() {
        bringSubviewToFront(loadingIndicator)
        loadingIndicator.play()
        loadingIndicator.isHidden = false
        pausedSessionLabel.isHidden = true
    }
    
    func hideLoadingAnimation() {
        sendSubviewToBack(loadingIndicator)
        loadingIndicator.stop()
        loadingIndicator.isHidden = true
        pausedSessionLabel.isHidden = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupFadeTapRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VideoSessionView: VideoSessionPartnerFeedBehaviorDelegate {
    func partnerFeedDidFinishAnimating(_ partnerFeed: UIView, to cornerPosition: CardPosition) {
        disableAllCornerPinning()
        switch cornerPosition {
        case .topLeft:
            cameraPreviewTopAnchor?.isActive = true
            cameraPreviewLeftAnchor?.isActive = true
        case .topRight:
            cameraPreviewTopAnchor?.isActive = true
            cameraPreviewRightAnchor?.isActive = true
        case .bottomRight:
            cameraPreviewBottomAnchor?.isActive = true
            cameraPreviewRightAnchor?.isActive = true
        case .bottomLeft:
            cameraPreviewBottomAnchor?.isActive = true
            cameraPreviewLeftAnchor?.isActive = true
        }
        
        layoutIfNeeded()
    }
}
