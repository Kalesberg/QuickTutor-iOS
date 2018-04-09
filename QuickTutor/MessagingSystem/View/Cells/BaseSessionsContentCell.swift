//
//  SessionsContentCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Firebase

let userType = "learner"

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
        Database.database().reference().child("userSessions").child(uid).observeSingleEvent(of: .childAdded) { snapshot in
            DataService.shared.getSessionById(snapshot.key, completion: { session in
                if session.status != "pending" && session.date > Date().timeIntervalSince1970 {
                    self.pendingSessions.append(session)
                    self.collectionView.reloadData()
                    return
                }
                
                if session.date < Date().timeIntervalSince1970 {
                    self.pastSessions.append(session)
                    self.collectionView.reloadData()
                    return
                }
                
                self.upcomingSessions.append(session)
                self.collectionView.reloadData()
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
            //            cell.updateUI(session: pendingSessions[indexPath.item])
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

class LearnerSessionsContentCell: BaseSessionsContentCell {
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.register(LearnerPendingSessionCell.self, forCellWithReuseIdentifier: "pendingSessionCell")
        collectionView.register(LearnerPastSessionCell.self, forCellWithReuseIdentifier: "pastSessionCell")
        collectionView.register(LearnerUpcomingSessionCell.self, forCellWithReuseIdentifier: "upcomingSessionCell")
        collectionView.register(EmptySessionCell.self, forCellWithReuseIdentifier: "emptyCell")
        collectionView.register(SessionHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
    }
    
    override func setupViews() {
        super.setupViews()
        setupRequestSessionButton()
    }
    
    func setupRequestSessionButton() {
        addSubview(requestSessionButton)
        requestSessionButton.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 50, paddingRight: 20, width: 71, height: 60)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard !pendingSessions.isEmpty else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
                cell.setLabelToPending()
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pendingSessionCell", for: indexPath) as! LearnerPendingSessionCell
            //            cell.updateUI(session: pendingSessions[indexPath.item])
            return cell
        }
        
        if indexPath.section == 1 {
            guard !upcomingSessions.isEmpty else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
                cell.setLabelToUpcoming()
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingSessionCell", for: indexPath) as! LearnerUpcomingSessionCell
            return cell
        }
        
        guard !pastSessions.isEmpty else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
            cell.setLabelToPast()
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pastSessionCell", for: indexPath) as! LearnerPastSessionCell
        return cell
    }
}

class TutorSessionContentCell: BaseSessionsContentCell {
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.register(TutorPendingSessionCell.self, forCellWithReuseIdentifier: "pendingSessionCell")
        collectionView.register(TutorPastSessionCell.self, forCellWithReuseIdentifier: "pastSessionCell")
        collectionView.register(TutorUpcomingSessionCell.self, forCellWithReuseIdentifier: "upcomingSessionCell")
        collectionView.register(EmptySessionCell.self, forCellWithReuseIdentifier: "emptyCell")
        collectionView.register(SessionHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
    }
    
    override func setupViews() {
        super.setupViews()
        headerTitles[0] = "Requests"
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard !upcomingSessions.isEmpty else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
                cell.setLabelToPending()
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pendingSessionCell", for: indexPath) as! TutorPendingSessionCell
            //            cell.updateUI(session: pendingSessions[indexPath.item])
            return cell
        }
        
        if indexPath.section == 1 {
            guard !upcomingSessions.isEmpty else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
                cell.setLabelToUpcoming()
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingSessionCell", for: indexPath) as! TutorUpcomingSessionCell
            return cell
        }
        
        guard !upcomingSessions.isEmpty else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath) as! EmptySessionCell
            cell.setLabelToPast()
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pastSessionCell", for: indexPath) as! TutorPastSessionCell
        return cell
    }
    
}

class BasePendingSessionCell: BaseSessionCell {
    
    override func setupViews() {
        super.setupViews()
        //        actionView.setupActionButton2()
        //        actionView.updateButtonImages([#imageLiteral(resourceName: "messageButton"), #imageLiteral(resourceName: "cancelSessionButton")])
    }
}

class LearnerPendingSessionCell: BasePendingSessionCell, MessageButtonDelegate, CancelSessionButtonDelegate {
    
    override func setupViews() {
        super.setupViews()
        actionView.setupAsDoubleButton()
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "cancelSessionButton"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
    }
    
    override func handleButton1() {
        cancelSession()
    }
    
    override func handleButton2() {
        showConversationWithUID(session.partnerId())
    }
    
}

class TutorPendingSessionCell: BasePendingSessionCell {
    
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "acceptSessionButton"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "declineSessionButton"), for: .normal)
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
    }
}

class BaseUpcomingSessionCell: BaseSessionCell {
    
}

class LearnerUpcomingSessionCell: BaseUpcomingSessionCell, MessageButtonDelegate, CancelSessionButtonDelegate {
    
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "startSessionButton"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "cancelSessionButton"), for: .normal)
        
    }
    
    override func handleButton1() {
        cancelSession()
    }
    
    override func handleButton2() {
        showConversationWithUID(session.partnerId())
    }
    
}

class TutorUpcomingSessionCell: BaseUpcomingSessionCell {
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "viewProfileButton"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "cancelSessionButton"), for: .normal)
    }
}

class BasePastSessionCell: BaseSessionCell {
    
    let darkenView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        return view
    }()
    
    let starView: StarView = {
        let sv = StarView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    func updateUI(_ session: Session) {
        self.session = session
    }
    
    override func setupViews() {
        super.setupViews()
        setupDarkenView()
        setupStarView()
        starIcon.removeFromSuperview()
        starLabel.removeFromSuperview()
    }
    
    override func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    private func setupDarkenView() {
        insertSubview(darkenView, belowSubview: actionView)
        darkenView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    private func setupStarView() {
        addSubview(starView)
        starView.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 12, width: 40, height: 7)
    }
}

class LearnerPastSessionCell: BasePastSessionCell, MessageButtonDelegate {
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "viewProfileButton"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "requestSessionButton"), for: .normal)
    }
    
    override func handleButton2() {
        print(session.receiverId)
        print(session.senderId)
    }
}

class TutorPastSessionCell: BasePastSessionCell {
    override func setupViews() {
        super.setupViews()
        actionView.setupAsTripleButton()
        actionView.actionButton3.setImage(#imageLiteral(resourceName: "viewProfileButton"), for: .normal)
        actionView.actionButton2.setImage(#imageLiteral(resourceName: "messageButton"), for: .normal)
        actionView.actionButton1.setImage(#imageLiteral(resourceName: "requestSessionButton"), for: .normal)
    }
}

class PendingSessionCell: BaseSessionCell {
    
}

class UpcomingSessionCell: BaseSessionCell {
    
}

protocol MessageButtonDelegate {
    func showConversationWithUID(_ uid: String)
}

protocol CancelSessionButtonDelegate {
    func cancelSession()
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
