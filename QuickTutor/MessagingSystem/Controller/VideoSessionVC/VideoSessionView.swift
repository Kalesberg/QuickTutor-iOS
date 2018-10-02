//
//  VideoSessionView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 6/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import TwilioVideo
import UIKit

class VideoSessionView: UIView {
    lazy var sessionNavBar: SessionNavBar = {
        let bar = SessionNavBar()
        return bar
    }()

    var partnerCameraFeed: TVIVideoView = {
        let view = TVIVideoView()
        view.contentMode = .scaleAspectFill
        return view
    }()

    let cameraPreviewView: TVIVideoView = {
        let view = TVIVideoView()
        view.contentMode = .scaleAspectFill
        return view
    }()

    let flipCameraIcon: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "cameraFlipIcon"))
        iv.contentMode = .scaleAspectFit
        iv.alpha = 0.75
        iv.isUserInteractionEnabled = false
        return iv
    }()

    let statusBarCover: UIView = {
        let view = UIView()
        view.backgroundColor = AccountService.shared.currentUserType == .learner ? Colors.learnerPurple : Colors.tutorBlue
        view.alpha = 0.5
        return view
    }()

    let pauseSessionButton: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "pauseSessionButton"), for: .normal)
        return button
    }()

    let endSessionButton: UIButton = {
        let button = UIButton()
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "endSessionButton"), for: .normal)
        return button
    }()

    func setupViews() {
        setupMainView()
        setupPartnerCameraFeed()
        setupCameraPreviewView()
        setupFlipCameraIcon()
        setupNavBar()
        setupPauseSessionButton()
        setupEndSessionButton()
    }

    func setupMainView() {
        backgroundColor = .black
    }

    func setupNavBar() {
        addSubview(sessionNavBar)
        sessionNavBar.anchor(top: getTopAnchor(), left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 70)
        addSubview(statusBarCover)
        statusBarCover.anchor(top: topAnchor, left: leftAnchor, bottom: sessionNavBar.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        navigationController.navigationBar.isHidden = true
        sessionNavBar.setOpaque()
    }
    
    func setupPartnerCameraFeed() {
        addSubview(partnerCameraFeed)
        partnerCameraFeed.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupCameraPreviewView() {
        addSubview(cameraPreviewView)
        cameraPreviewView.anchor(top: nil, left: leftAnchor, bottom: getBottomAnchor(), right: nil, paddingTop: 0, paddingLeft: 3, paddingBottom: 3, paddingRight: 0, width: 112.5, height: 112.5 * (16 / 9) - 30)
        
    }
    
    func setupFlipCameraIcon() {
        addSubview(flipCameraIcon)
        flipCameraIcon.anchor(top: nil, left: nil, bottom: cameraPreviewView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 6, paddingRight: 0, width: 30, height: 20)
        addConstraint(NSLayoutConstraint(item: flipCameraIcon, attribute: .centerX, relatedBy: .equal, toItem: cameraPreviewView, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupPauseSessionButton() {
        addSubview(pauseSessionButton)
        pauseSessionButton.anchor(top: sessionNavBar.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 35, height: 35)
    }
    
    func setupEndSessionButton() {
        addSubview(endSessionButton)
        endSessionButton.anchor(top: nil, left: nil, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 15, width: 169.75, height: 61.25)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

