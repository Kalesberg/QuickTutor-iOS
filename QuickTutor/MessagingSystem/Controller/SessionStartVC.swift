//
//  SessionStartVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class SessionStartVC: UIViewController {
    
    var partnerId: String?
    var sessionId: String?
    var initiatorId: String?
    var startType: String?
    var partner: User?
    var partnerUsername: String?
    var meetupConfirmed = false
    
    var session: Session?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createSize(22)
        label.text = "Alex is Video Calling..."
        return label
    }()
    
    let infoBox: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.navBarColor
        view.layer.cornerRadius = 4
        return view
    }()
    
    let subjectLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createSize(18)
        label.text = "Botany"
        return label
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createSize(12)
        label.text = "Length: 120 mins, $17.00 / hr"
        return label
    }()
    
    let partnerBox: SessionProfileBox = {
        let box = SessionProfileBox()
        return box
    }()
    
    let currentUserBox: SessionProfileBox = {
        let box = SessionProfileBox()
        return box
    }()
    
    let waveIcon: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "waveIcon"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let messageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Message", for: .normal)
        button.setTitleColor(Colors.learnerPurple, for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = Colors.learnerPurple.cgColor
        button.titleLabel?.font = Fonts.createSize(16)
        button.layer.cornerRadius = 4
        button.backgroundColor = Colors.navBarColor
        button.isHidden = true
        return button
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createSize(16)
        label.text = "Waiting for your partner to accept the manual start..."
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true
        return label
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("Accept Manual Start", for: .normal)
        button.setTitleColor(UIColor(red: 31.0/255.0, green: 177.0/255.0, blue: 74.0/255.0, alpha: 1.0), for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor(red: 31.0/255.0, green: 177.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor
        button.titleLabel?.font = Fonts.createSize(18)
        button.layer.cornerRadius = 4
        button.backgroundColor = Colors.navBarColor
        button.isHidden = true
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor(red: 178.0/255.0, green: 27.0/255.0, blue: 74.0/255.0, alpha: 1.0), for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor(red: 178.0/255.0, green: 27.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor
        button.titleLabel?.font = Fonts.createSize(18)
        button.layer.cornerRadius = 4
        button.backgroundColor = Colors.navBarColor
        return button
    }()
    
    func updateUI() {
        guard let sessionId = sessionId, let uid = Auth.auth().currentUser?.uid else { return }
        DataService.shared.getSessionById(sessionId) { (sessionIn) in
            self.session = sessionIn
            self.partnerId = self.session?.partnerId()
            self.subjectLabel.text = self.session?.subject
            self.infoLabel.text = self.getFormattedInfoLabelString()
            guard let partnerId = self.session?.partnerId() else { return }
            self.partnerBox.updateUI(uid: partnerId)
            self.currentUserBox.updateUI(uid: uid)
            DataService.shared.getUserOfOppositeTypeWithId(partnerId, completion: { (user) in
                self.partner = user
                self.partnerUsername = user?.username
                self.updateTitleLabel()
            })
        }
    }
    
    func updateTitleLabel() {
        guard let uid = Auth.auth().currentUser?.uid, let username = partnerUsername else { return }
        
        //Online Automatic
        if startType == "automatic" && session?.type == "online" {
            self.titleLabel.text = "Video calling \(username)..."
        }
        
        //Online Manual Started By Current User
        if startType == "manual" && session?.type == "online" && initiatorId == uid {
            self.titleLabel.text = "Video calling \(username)..."
        }
        
        //Online Manual Started By Other User
        if startType == "manual" && session?.type == "online" && initiatorId != uid {
            self.titleLabel.text = "\(username) is Video Calling..."
            self.confirmButton.isHidden = false
        }

        //In-person Automatic
        if startType == "automatic" && session?.type == "in-person" {
            self.titleLabel.text = "Time to meet up!"
//            self.messageButton.
        }
        
        //In-person Manual Started By Current User
        if startType == "manual" && session?.type == "in-person" && initiatorId == uid {
            self.titleLabel.text = "Time to meet up!"
            self.statusLabel.text = "Waiting for your partner to accept the manual start..."
            self.statusLabel.isHidden = false
        }
        
        //In-person Manual Started By Other User
        if startType == "manual" && session?.type == "in-person" && initiatorId != uid {
            titleLabel.text = "\(username) wants to meet up early!"
            self.confirmButton.isHidden = false
        }
    }
    
    func getFormattedInfoLabelString() -> String {
        var finalString = ""
        guard let session = session else { return ""}
        let lengthInSeconds = session.endTime - session.startTime
        let lengthInMinutes = Int(lengthInSeconds / 60)

        let hourlyRate = session.price / Double(lengthInMinutes) * 60
        let formattedHourlyRate = String(format: "%.2f", hourlyRate)
        finalString = "Length: \(lengthInMinutes) min, $\(formattedHourlyRate) / hr"
        return finalString
    }
    
    func setupViews() {
        setupMainView()
        setupTitleLabel()
        setupInfoBox()
        setupSubjectLabel()
        setupInfoLabel()
        setupPartnerBox()
        setupCurrentUserBox()
        setupWaveIcon()
        setupMessageButton()
        setupCancelButton()
        setupConfirmButton()
        setupStatusLabel()
        setupNavBar()
    }
    
    func setupMainView() {
        view.backgroundColor = Colors.darkBackground
        navigationItem.hidesBackButton = true
        let backImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(pop))
    }
    
    @objc func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
    }
    
    func setupInfoBox() {
        view.addSubview(infoBox)
        infoBox.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 17.5, paddingBottom: 0, paddingRight: 17.5, width: 0, height: 55)
    }
    
    func setupSubjectLabel() {
        infoBox.addSubview(subjectLabel)
        subjectLabel.anchor(top: infoBox.topAnchor, left: infoBox.leftAnchor, bottom: nil, right: infoBox.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    }
    
    func setupInfoLabel() {
        infoBox.addSubview(infoLabel)
        infoLabel.anchor(top: subjectLabel.bottomAnchor, left: infoBox.leftAnchor, bottom: infoBox.bottomAnchor, right: infoBox.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupPartnerBox() {
        view.addSubview(partnerBox)
        partnerBox.anchor(top: infoBox.bottomAnchor, left: infoBox.leftAnchor, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 158)
    }
    
    func setupCurrentUserBox() {
        view.addSubview(currentUserBox)
        currentUserBox.anchor(top: infoBox.bottomAnchor, left: nil, bottom: nil, right: infoBox.rightAnchor, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 158)
    }
    
    func setupWaveIcon() {
        view.addSubview(waveIcon)
        waveIcon.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        view.addConstraint(NSLayoutConstraint(item: waveIcon, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: waveIcon, attribute: .centerY, relatedBy: .equal, toItem: partnerBox, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func setupMessageButton() {
        view.addSubview(messageButton)
        messageButton.anchor(top: currentUserBox.bottomAnchor, left: currentUserBox.leftAnchor, bottom: nil, right: currentUserBox.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 35)
    }
    
    func setupCancelButton() {
        view.addSubview(cancelButton)
        cancelButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 52.5, paddingRight: 0, width: 270, height: 50)
        view.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupConfirmButton() {
        view.addSubview(confirmButton)
        confirmButton.anchor(top: nil, left: nil, bottom: cancelButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 270, height: 50)
        view.addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupStatusLabel() {
        view.addSubview(statusLabel)
        statusLabel.anchor(top: nil, left: view.leftAnchor, bottom: confirmButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 50, paddingRight: 20, width: 0, height: 20)
    }
    
    func setupNavBar() {
        navigationController?.navigationBar.barTintColor = Colors.learnerPurple
        navigationItem.title = "Attempting to Start Session"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = Colors.navBarColor
    }
}
