//
//  InPersonSessionVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/18/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class InPersonSessionVC: BaseSessionVC {
    
    let statusBarCover: UIView = {
        let view = UIView()
        view.backgroundColor = AccountService.shared.currentUserType == .learner ? Colors.learnerPurple : Colors.tutorBlue
        return view
    }()
    
    let receieverBox: InPersonProfileBox = {
        let box = InPersonProfileBox()
        return box
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createSize(20)
        label.text = "Session In Progress..."
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let cancelButton: DimmableButton = {
        let button = DimmableButton()
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
        setupStatusLabel()
        receieverBox.updateUI(uid: uid)
    }
    
    func setupMainView() {
        view.backgroundColor = Colors.darkBackground
    }
    
    func setupNavBar()  {
        view.addSubview(sessionNavBar)
        sessionNavBar.anchor(top: view.getTopAnchor(), left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 70)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: sessionNavBar.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        navigationController?.navigationBar.isHidden = true
        sessionNavBar.sessionTypeIcon.image = #imageLiteral(resourceName: "inPersonIcon")
        sessionNavBar.sessionTypeLabel.text = "In-Person"
    }
    
    func setupReceiverBox() {
        view.addSubview(receieverBox)
        receieverBox.anchor(top: sessionNavBar.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 175, height: 197.5)
        view.addConstraint(NSLayoutConstraint(item: receieverBox, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupCancelButton() {
        view.addSubview(cancelButton)
        cancelButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 52.5, paddingRight: 0, width: 270, height: 50)
        view.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        cancelButton.addTarget(self, action: #selector(showModal), for: .touchUpInside)
    }
    
    func setupStatusLabel() {
        view.addSubview(statusLabel)
        statusLabel.anchor(top: receieverBox.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 120, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
    }
    
    @objc func showModal() {
        endSessionModal = EndSessionModal(frame: .zero)
        endSessionModal?.delegate = self
        endSessionModal?.show()
    }
    
    func removeStartData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("sessionStarts").child(uid).removeValue()
    }
    
    func updateUI() {
        guard let id = sessionId else { return }
        DataService.shared.getSessionById(id) { (session) in
            self.receieverBox.infoLabel.text = session.getFormattedInfoLabelString()
            self.receieverBox.subjectLabel.text = session.subject
            self.receieverBox.updateUI(uid: session.partnerId())
            self.partnerId = session.partnerId()
            self.expireSession()
        }
    }
    
    func expireSession() {
        guard let id = sessionId else { return }
        Database.database().reference().child("sessions").child(id).child("status").setValue("expired")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        removeStartData()
        updateUI()
    }
}

