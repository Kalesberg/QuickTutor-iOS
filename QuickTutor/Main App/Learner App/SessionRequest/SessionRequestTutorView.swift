//
//  SessionRequestTutorView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol SessionRequestTutorViewDelegate {
    func tutorViewShouldChooseTutor(_ tutorView: SessionRequestTutorView)
    func tutorView(_ tutorView: SessionRequestTutorView, didChoose tutor: AWTutor)
}

class SessionRequestTutorView: BaseSessionRequestViewSection, MockCollectionViewCellDelegate {
    
    var delegate: SessionRequestTutorViewDelegate?
    var numberOfConnections = 0
    let tutorSelectView: MockCollectionViewCell = {
        let cell = MockCollectionViewCell()
        cell.primaryButton.setTitle("Select", for: .normal)
        cell.titleLabel.font = Fonts.createSize(14)
        return cell
    }()
    
    let tutorCell: SessionRequestTutorCell = {
        let cell = SessionRequestTutorCell()
        cell.backgroundColor = Colors.darkBackground
        cell.alpha = 0
        return cell
    }()
    
    override func setupViews() {
        super.setupViews()
        setupTutorSelectView()
        setupTutorCell()
        setupObservers()
        titleLabel.text = "Tutor"
    }
    
    func setupTutorSelectView() {
        addSubview(tutorSelectView)
        tutorSelectView.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        tutorSelectView.delegate = self
        tutorSelectView.titleLabel.text = "Select a tutor from your connections"
    }
    
    func setupTutorCell() {
        addSubview(tutorCell)
        tutorCell.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTutorSelection(_:)), name: NSNotification.Name(rawValue: "com.quicktutor.didSelectTutor"), object: nil)
    }
    
    func mockCollectionViewCellDidSelectPrimaryButton(_ cell: MockCollectionViewCell) {
        delegate?.tutorViewShouldChooseTutor(self)
    }
    
    @objc func handleTutorSelection(_ notification: Notification) {
        if let tutor = notification.userInfo?["tutor"] as? User {
            tutorCell.updateUI(user: tutor)
            FirebaseData.manager.fetchTutor(tutor.uid, isQuery: false) { (tutorIn) in
                guard let tutor2 = tutorIn else { return }
                self.delegate?.tutorView(self, didChoose: tutor2)
            }
        }
    }
}

