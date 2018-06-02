//
//  SessionStartVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase
import SocketIO

class BaseSessionStartVC: UIViewController {
    
    var partnerId: String?
    var sessionId: String?
    var initiatorId: String?
    var startType: String?
    var partner: User?
    var partnerUsername: String?
    var meetupConfirmed = false
    var socket: SocketIOClient!
    
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
    
    let senderBox: SessionProfileBox = {
        let box = SessionProfileBox()
        return box
    }()
    
    let receieverBox: SessionProfileBox = {
        let box = SessionProfileBox()
        return box
    }()
    
    let waveIcon: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "waveIcon"))
        iv.contentMode = .scaleAspectFit
        return iv
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
    
    let confirmButton: DimmableButton = {
        let button = DimmableButton()
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
    
    let cancelButton: DimmableButton = {
        let button = DimmableButton()
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
//            self.removeStartData()
            self.partnerId = self.session?.partnerId()
            self.subjectLabel.text = self.session?.subject
            self.infoLabel.text = self.getFormattedInfoLabelString()
            guard let partnerId = self.session?.partnerId(), let senderId = self.initiatorId else { return }
            self.senderBox.updateUI(uid: senderId)
            guard let receiverId = self.initiatorId == uid ? self.session?.partnerId() : uid else { return }
            self.receieverBox.updateUI(uid: receiverId)
            DataService.shared.getUserOfOppositeTypeWithId(partnerId, completion: { (user) in
                self.partner = user
                self.partnerUsername = user?.username
                self.updateTitleLabel()
            })
        }
    }
    
    func updateTitleLabel() {
        guard let _ = Auth.auth().currentUser?.uid, let _ = partnerUsername else { return }
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
        setupSenderBox()
        setupReceiverBox()
        setupWaveIcon()
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
    
    func setupSenderBox() {
        view.addSubview(senderBox)
        senderBox.anchor(top: infoBox.bottomAnchor, left: infoBox.leftAnchor, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 158)
    }
    
    func setupReceiverBox() {
        view.addSubview(receieverBox)
        receieverBox.anchor(top: infoBox.bottomAnchor, left: nil, bottom: nil, right: infoBox.rightAnchor, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 158)
    }
    
    func setupWaveIcon() {
        view.addSubview(waveIcon)
        waveIcon.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        view.addConstraint(NSLayoutConstraint(item: waveIcon, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: waveIcon, attribute: .centerY, relatedBy: .equal, toItem: senderBox, attribute: .centerY, multiplier: 1, constant: 0))
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
        confirmButton.addTarget(self, action: #selector(confirmManualStart), for: .touchUpInside)
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
    
    
    @objc func confirmManualStart() {
        let data = ["roomKey": sessionId!, "sessionId": sessionId!, "sessionType" : session?.type]
        socket.emit(SocketEvents.manualStartAccetped, data)
        print("ZACH: Data emiited when start accepted:", data, "\n\n\nFinished")
    }
    
    private func removeStartData() {
        guard let uid = Auth.auth().currentUser?.uid, let sessionId = session?.id else { return }
        Database.database().reference().child("sessionStarts").child(uid).child(sessionId).removeValue()
    }
    
    func setupSocket() {
        guard let id = sessionId else { return }
        socket = SocketClient.shared.socket
        socket.on(clientEvent: .connect) { (data, ack) in
            self.socket.emit("joinRoom", id);            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateUI()
        setupSocket()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = Colors.navBarColor
    }

}
