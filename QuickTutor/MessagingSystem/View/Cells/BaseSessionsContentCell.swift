//
//  SessionsContentCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

let userType = "tutor"

class BaseSessionsContentCell: BaseContentCell {
    
    var pendingSessions = [Session]()
    var upcomingSessions = [Session]()
    var pastSessions = [Session]()
    
    let requestSessionButton: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "requestSessionButton"), for: .normal)
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        fetchSessions()
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.register(BasePendingSessionCell.self, forCellWithReuseIdentifier: "pendingSessionCell")
        collectionView.register(BasePastSessionCell.self, forCellWithReuseIdentifier: "pastSessionCell")
        collectionView.register(BaseUpcomingSessionCell.self, forCellWithReuseIdentifier: "upcomingSessionCell")
        collectionView.register(EmptySessionCell.self, forCellWithReuseIdentifier: "emptyCell")
        collectionView.register(SessionHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
    }
    
    func fetchSessions() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Database.database().reference().child("userSessions").child(uid).observe(.childAdded) { (snapshot) in
            DataService.shared.getSessionById(snapshot.key, completion: { session in
                if session.status == "pending" && session.startTime > Date().timeIntervalSince1970 {
                    self.pendingSessions.append(session)
                    self.collectionView.reloadData()
                    return
                }
                
                if session.startTime < Date().timeIntervalSince1970 {
                    self.pastSessions.append(session)
                    self.collectionView.reloadData()
                    return
                }
                
                if session.status == "accepted" {
                    self.upcomingSessions.append(session)
                    self.collectionView.reloadData()
                }
            })
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            guard !pendingSessions.isEmpty else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
                cell.setLabelToPending()
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pendingSessionCell", for: indexPath) as! BasePendingSessionCell
            cell.updateUI(session: pendingSessions[indexPath.item])
            return cell
        }
        
        if indexPath.section == 1 {
            guard !upcomingSessions.isEmpty else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
                cell.setLabelToUpcoming()
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingSessionCell", for: indexPath) as! BaseUpcomingSessionCell
            return cell
        }
        
        guard !pastSessions.isEmpty else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
            cell.setLabelToPast()
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pastSessionCell", for: indexPath) as! BasePastSessionCell
        return cell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return pendingSessions.isEmpty ? 1 : pendingSessions.count
        } else if section == 1 {
            return upcomingSessions.isEmpty ? 1 : upcomingSessions.count
        } else {
            return pastSessions.isEmpty ? 1 : pastSessions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    var headerTitles = ["Pending", "Upcoming", "Past"]
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId", for: indexPath) as! SessionHeaderCell
        header.titleLabel.text = headerTitles[indexPath.section]
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? BaseSessionCell else { return }
        cell.actionView.showActionContainerView()
    }
}

class PendingSessionCell: BaseSessionCell {
    
}

class UpcomingSessionCell: BaseSessionCell {
    
}

protocol MessageButtonDelegate {
    func showConversationWithUID(_ uid: String)
}

protocol RequestSessionButtonDelegate {
    func requestSession(_ uid: String)
}

protocol CancelSessionButtonDelegate {
    func cancelSession()
}

extension RequestSessionButtonDelegate {
    func requestSession(_ uid: String) {
        let userInfo = ["uid": uid]
        let notification = Notification(name: NSNotification.Name(rawValue: "requestSession"), object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
}

extension CancelSessionButtonDelegate {
    func cancelSession() {
        let notification = Notification(name: NSNotification.Name(rawValue: "cancelSession"), object: nil, userInfo: nil)
        NotificationCenter.default.post(notification)
    }
}

protocol ViewProfileButtonDelegate {
    func viewProfile()
}

protocol AcceptSessionButtonDelegate {
    func acceptSession()
}

protocol DeclineSessionButtonDelegate {
    func declineSession()
}

extension MessageButtonDelegate {
    func showConversationWithUID(_ uid: String) {
        let userInfo = ["uid": uid]
        let notification = Notification(name: NSNotification.Name(rawValue: "sendMessage"), object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
}
