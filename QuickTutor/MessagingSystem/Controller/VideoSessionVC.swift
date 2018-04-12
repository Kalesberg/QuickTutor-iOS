//
//  VideoSessionVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class VideoSessionVC: UIViewController {
    
    let sessionNavBar: SessionNavBar = {
        let bar = SessionNavBar()
        return bar
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
    
    let cameraFeedView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    func setupViews() {
        setupNavBar()
        setupPauseSessionButton()
        setupEndSessionButton()
        setupCameraFeedView()
    }
    
    func setupNavBar()  {
        view.addSubview(sessionNavBar)
        sessionNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 70)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: sessionNavBar.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupPauseSessionButton() {
        view.addSubview(pauseSessionButton)
        pauseSessionButton.anchor(top: sessionNavBar.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 35, height: 35)
    }
    
    func setupEndSessionButton() {
        view.addSubview(endSessionButton)
        endSessionButton.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 15, width: 97, height: 35)
    }
    
    func setupCameraFeedView() {
        view.addSubview(cameraFeedView)
        cameraFeedView.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150 * (16/9) - 30)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}
