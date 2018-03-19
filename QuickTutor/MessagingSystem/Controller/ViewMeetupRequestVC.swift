//
//  ViewMeetupRequestVC.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/28/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit
import Firebase

class ViewMeetupRequestVC: UIViewController {
    
    var meetupRequestId: String!
    var meetupRequest: MeetupRequest?
    var senderId: String!
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.backgroundColor = Colors.darkBackground
        label.layer.cornerRadius = 25
        label.textAlignment = .center
        label.applyDefaultShadow()
        return label
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton()
        button.setTitle("Accept", for: .normal)
        button.backgroundColor = Colors.purple
        button.layer.cornerRadius = 25
        button.tag = 0
        button.applyDefaultShadow()
        return button
    }()
    
    let declineButton: UIButton = {
        let button = UIButton()
        button.setTitle("Decline", for: .normal)
        button.backgroundColor = Colors.lightGrey
        button.layer.cornerRadius = 25
        button.tag = 1
        button.applyDefaultShadow()
        return button
    }()
    
    func setupViews() {
        setupMainView()
        setupInfoLabel()
        setupActionButtons()
    }
    
    private func setupMainView() {
        view.backgroundColor = Colors.darkBackground
    }
    
    private func setupInfoLabel() {
        view.addSubview(infoLabel)
        infoLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        view.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    private func setupActionButtons() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard senderId != uid else { return }
        setupAcceptButton()
        setupDeclineButton()
    }
    
    private func setupAcceptButton() {
        view.addSubview(acceptButton)
        acceptButton.anchor(top: infoLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 75, paddingBottom: 0, paddingRight: 75, width: 0, height: 50)
        acceptButton.addTarget(self, action: #selector(handleButtonAction(sender:)), for: .touchUpInside)
    }
    
    private func setupDeclineButton() {
        view.addSubview(declineButton)
        declineButton.anchor(top: acceptButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 75, paddingBottom: 0, paddingRight: 75, width: 0, height: 50)
        declineButton.addTarget(self, action: #selector(handleButtonAction(sender:)), for: .touchUpInside)
    }
    
    @objc func handleButtonAction(sender: UIButton) {
        let valueToSet = sender.tag == 0 ? "accepted" : "declined"
        Database.database().reference().child("meetupRequests").child(meetupRequestId).child("status").setValue(valueToSet)
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadMeetupRequestFromId(meetupRequestId)
    }
    
    func loadMeetupRequestFromId(_ id: String) {
        Database.database().reference().child("meetupRequests").child(id).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else { return }
            let meetupRequest = MeetupRequest(data: value)
            self.meetupRequest = meetupRequest
            self.checkExpirationFor(meetupRequest)
            self.showStatusForMeetupRequest(self.meetupRequest!)
        }
    }
    
    func showStatusForMeetupRequest(_ meetupRequest: MeetupRequest) {
        guard meetupRequest.status != "pending" else {
            infoLabel.text = "This meetup request is pending"
            return
        }
        if meetupRequest.status == "declined" {
            infoLabel.text = "This meetup request was declined"
        }
        
        if meetupRequest.status == "accepted" {
            infoLabel.text = "This meetup request was accepted"
        }
        
        if meetupRequest.status == "expired" {
            infoLabel.text = "This meetup request has expired"
        }
        acceptButton.removeFromSuperview()
        declineButton.removeFromSuperview()
    }
    
    func checkExpirationFor(_ meetupRequest: MeetupRequest) {
        guard let expiration = meetupRequest.expiration, expiration < Date().timeIntervalSince1970 else {
            return
        }
        self.meetupRequest?.status = "expired"
    }
}
