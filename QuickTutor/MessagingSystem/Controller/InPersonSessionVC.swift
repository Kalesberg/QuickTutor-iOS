//
//  InPersonSessionVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/18/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class InPersonSessionVC: UIViewController {
    
    var endSessionModal: EndSessionModal?
    
    let sessionNavBar: SessionNavBar = {
        let bar = SessionNavBar()
        bar.sessionTypeIcon.image = #imageLiteral(resourceName: "inPersonIcon")
        bar.sessionTypeLabel.text = "In-Person"
        return bar
    }()
    
    let statusBarCover: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.learnerPurple
        return view
    }()
    
    let receieverBox: SessionProfileBox = {
        let box = SessionProfileBox()
        return box
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createSize(16)
        label.text = "Session In Progress..."
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("End Session", for: .normal)
        button.setTitleColor(UIColor(red: 178.0/255.0, green: 27.0/255.0, blue: 74.0/255.0, alpha: 1.0), for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor(red: 178.0/255.0, green: 27.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor
        button.titleLabel?.font = Fonts.createSize(18)
        button.layer.cornerRadius = 4
        button.backgroundColor = Colors.navBarColor
        return button
    }()
    
    func setupViews() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        setupMainView()
        setupNavBar()
        setupReceiverBox()
        setupCancelButton()
        receieverBox.updateUI(uid: uid)
    }
    
    func setupMainView() {
        view.backgroundColor = Colors.darkBackground
    }
    
    func setupNavBar()  {
        view.addSubview(sessionNavBar)
        sessionNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 70)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: sessionNavBar.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupReceiverBox() {
        view.addSubview(receieverBox)
        receieverBox.anchor(top: sessionNavBar.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 158)
        view.addConstraint(NSLayoutConstraint(item: receieverBox, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupCancelButton() {
        view.addSubview(cancelButton)
        cancelButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 52.5, paddingRight: 0, width: 270, height: 50)
        view.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        cancelButton.addTarget(self, action: #selector(showModal), for: .touchUpInside)
    }
    
    @objc func showModal() {
        endSessionModal = EndSessionModal(frame: .zero)
        endSessionModal?.show()
    }
    
    func removeStartData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("sessionStarts").child(uid).removeValue()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        removeStartData()
    }
}

