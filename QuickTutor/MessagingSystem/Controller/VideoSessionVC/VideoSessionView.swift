//
//  VideoSessionView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 6/6/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import TwilioVideo

class VideoSessionView: UIView {
    
    lazy var sessionNavBar: SessionNavBar = {
        let bar = SessionNavBar()
        return bar
    }()
    
    var remoteView: TVIVideoView = {
        let view = TVIVideoView()
        view.contentMode = .scaleAspectFill
        view.shouldMirror = true
        return view
    }()
    
    let previewView: TVIVideoView = {
        let view = TVIVideoView()
        view.contentMode = .scaleAspectFill
        view.shouldMirror = true
        return view
    }()
    
    let previewBorderView: UIView = {
        let view = UIView()
        view.layer.borderColor = AccountService.shared.currentUserType == .learner ? Colors.learnerPurple.cgColor : Colors.tutorBlue.cgColor
        view.layer.borderWidth = 3
        return view
    }()
    
    let statusBarCover: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.learnerPurple
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
        button.contentMode = .scaleAspectFill
        button.setImage(#imageLiteral(resourceName: "endSessionButton"), for: .normal)
        return button
    }()
    
    func setupViews() {
        setupMainView()
        setupRemoteView()
        setupPreviewView()
        setupPreviewBorderView()
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
    }
    
    func setupRemoteView() {
        addSubview(remoteView)
        remoteView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupPreviewView() {
        addSubview(previewView)
        previewView.anchor(top: nil, left: leftAnchor, bottom: getBottomAnchor(), right: nil, paddingTop: 0, paddingLeft: 3, paddingBottom: 3, paddingRight: 0, width: 150, height: 150 * (16 / 9) - 30)
    }
    
    func setupPreviewBorderView() {
        insertSubview(previewBorderView, belowSubview: previewBorderView)
        previewBorderView.anchor(top: previewView.topAnchor, left: leftAnchor, bottom: getBottomAnchor(), right: previewView.rightAnchor, paddingTop: -3, paddingLeft: 0, paddingBottom: 0, paddingRight: -3, width: 0, height: 0)
    }
    
    func setupPauseSessionButton() {
        addSubview(pauseSessionButton)
        pauseSessionButton.anchor(top: sessionNavBar.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 35, height: 35)
    }
    
    func setupEndSessionButton() {
        addSubview(endSessionButton)
        endSessionButton.anchor(top: nil, left: nil, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 15, width: 97, height: 35)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

