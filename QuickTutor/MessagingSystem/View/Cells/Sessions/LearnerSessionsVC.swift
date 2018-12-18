//
//  LeanerSessionsVC.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

class LearnerSessionsVC: BaseSessionsVC {
    
    let requestSessionButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Request session", for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.currentUserColor()
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        setupRequestSessionButton()
    }
    
    func setupRequestSessionButton() {
        view.addSubview(requestSessionButton)
        requestSessionButton.anchor(top: nil, left: view.leftAnchor, bottom: view.getBottomAnchor(), right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 65)
        requestSessionButton.addTarget(self, action: #selector(handleRequestSession), for: .touchUpInside)
        collectionViewBottomAnchor?.constant = 65
        view.layoutIfNeeded()
    }
    
    @objc func handleRequestSession() {
        let vc = SessionRequestVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.register(LearnerPendingSessionCell.self, forCellWithReuseIdentifier: "pendingSessionCell")
        collectionView.register(LearnerPastSessionCell.self, forCellWithReuseIdentifier: "pastSessionCell")
        collectionView.register(LearnerUpcomingSessionCell.self, forCellWithReuseIdentifier: "upcomingSessionCell")
        collectionView.register(EmptySessionCell.self, forCellWithReuseIdentifier: "emptyCell")
        collectionView.register(SessionHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard !pendingSessions.isEmpty else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
                cell.setLabelToPending()
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pendingSessionCell", for: indexPath) as! LearnerPendingSessionCell
            cell.updateUI(session: pendingSessions[indexPath.item])
            return cell
        }

        if indexPath.section == 1 {
            guard !upcomingSessions.isEmpty else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
                cell.setLabelToUpcoming()
                return cell
            }

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingSessionCell", for: indexPath) as! LearnerUpcomingSessionCell
            cell.updateUI(session: upcomingSessions[indexPath.item])
            cell.delegate = self
            return cell
        }

        guard !pastSessions.isEmpty else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
            cell.setLabelToPast()
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pastSessionCell", for: indexPath) as! LearnerPastSessionCell
        cell.updateUI(session: pastSessions[indexPath.item])
        return cell
    }
}

extension LearnerSessionsVC: SessionCellDelgate {
    func sessionCell(_ sessionCell: BaseSessionCell, shouldReloadSessionWith id: String) {
        
    }
    
    func sessionCell(_ sessionCell: BaseSessionCell, shouldStart session: Session) {
        currentUserHasPayment { (hasPayment) in
            guard hasPayment else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let value = ["startedBy": uid, "startType": "manual", "sessionType": session.type]
            Database.database().reference().child("sessionStarts").child(uid).child(session.id).setValue(value)
            Database.database().reference().child("sessionStarts").child(session.partnerId()).child(session.id).setValue(value)
        }
    }
    
    func currentUserHasPayment(completion: @escaping (Bool) -> Void) {
        guard AccountService.shared.currentUserType == .learner else {
            completion(true)
            return
        }
        
        guard CurrentUser.shared.learner.hasPayment else {
            print("Needs card")
            completion(false)
            self.addPaymentModal.show()
            return
        }
        
        completion(true)
    }
    
}
