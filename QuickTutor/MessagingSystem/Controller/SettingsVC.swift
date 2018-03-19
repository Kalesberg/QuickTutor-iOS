//
//  SettingsVC.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/20/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class SettingsVC: UIViewController {
    
    let connectionRequestSwitch: UISwitch = {
        let control = UISwitch()
        control.accessibilityIdentifier = "connectionRequests"
        return control
    }()
    
    let newMessageSwitch: UISwitch = {
        let control = UISwitch()
        control.accessibilityIdentifier = "messages"
        return control
    }()
    
    let meetupRequestSwitch: UISwitch = {
        let control = UISwitch()
        control.accessibilityIdentifier = "meetupRequests"
        return control
    }()
    
    let connectionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.text = "Connection Requests"
        return label
    }()
    
    let messagesLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.text = "Messages"
        return label
    }()
    
    let meetupRequestsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.text = "Meetup Requests"
        return label
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Logout", for: .normal)
        button.backgroundColor = Colors.purple
        button.applyDefaultShadow()
        button.layer.cornerRadius = 25
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSwitchStates()
    }
    
    func setupViews() {
        setupMainView()
        setupNavBar()
        setupConnectionRequesSwitch()
        setupConnectionLabel()
        setupNewMessageSwitch()
        setupMessageLabel()
        setupMeetupRequestSwitch()
        setupMeetupLabel()
        setupLogoutButton()
    }
    
    func setupMainView() {
        view.backgroundColor = Colors.darkBackground
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func setupNavBar() {
        navigationItem.setRightBarButton(UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(close)) , animated: false)
        navigationItem.title = "Notification Preferences"
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupConnectionRequesSwitch() {
        view.addSubview(connectionRequestSwitch)
        connectionRequestSwitch.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 60, height: 40)
        connectionRequestSwitch.addTarget(self, action: #selector(updateNotificationPreferenceForSwitch(sender:)), for: .valueChanged)
    }
    
    func setupConnectionLabel() {
        view.addSubview(connectionLabel)
        connectionLabel.anchor(top: connectionRequestSwitch.topAnchor, left: connectionRequestSwitch.rightAnchor, bottom: connectionRequestSwitch.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 4, paddingRight: 0, width: 200, height: 0)
    }
    
    func setupNewMessageSwitch() {
        view.addSubview(newMessageSwitch)
        newMessageSwitch.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 100, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 60, height: 40)
        newMessageSwitch.addTarget(self, action: #selector(updateNotificationPreferenceForSwitch(sender:)), for: .valueChanged)

    }
    
    func setupMessageLabel() {
        view.addSubview(messagesLabel)
        messagesLabel.anchor(top: newMessageSwitch.topAnchor, left: newMessageSwitch.rightAnchor, bottom: newMessageSwitch.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 4, paddingRight: 0, width: 200, height: 0)
    }
    
    func setupMeetupRequestSwitch() {
        view.addSubview(meetupRequestSwitch)
        meetupRequestSwitch.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 150, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 60, height: 40)
        meetupRequestSwitch.addTarget(self, action: #selector(updateNotificationPreferenceForSwitch(sender:)), for: .valueChanged)

    }
    
    func setupMeetupLabel() {
        view.addSubview(meetupRequestsLabel)
        meetupRequestsLabel.anchor(top: meetupRequestSwitch.topAnchor, left: meetupRequestSwitch.rightAnchor, bottom: meetupRequestSwitch.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 4, paddingRight: 0, width: 200, height: 0)
    }
    
    func setupLogoutButton() {
        view.addSubview(logoutButton)
        logoutButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 75, paddingBottom: 50, paddingRight: 75, width: 0, height: 45)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
    }
    
    @objc func logout() {
        try? Auth.auth().signOut()
        guard let window = UIApplication.shared.keyWindow else { return }
        window.rootViewController = LoginVC()
    }
    
    @objc func updateNotificationPreferenceForSwitch(sender: UISwitch) {
        guard let id = sender.accessibilityIdentifier else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("notificationPreferences").child(uid).child(id).setValue(sender.isOn)
    }
    
    func updateSwitchStates() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("notificationPreferences").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let preferenceDictionary = snapshot.value as? [String: Any] else { return }
            let connectionRequests = preferenceDictionary["connectionRequests"] as? Bool ?? false
            let meetupRequests = preferenceDictionary["meetupRequests"] as? Bool ?? false
            let messages = preferenceDictionary["messages"] as? Bool ?? false
            
            self.connectionRequestSwitch.setOn(connectionRequests, animated: false)
            self.meetupRequestSwitch.setOn(meetupRequests, animated: false)
            self.newMessageSwitch.setOn(messages, animated: false)
        }
    }
}

