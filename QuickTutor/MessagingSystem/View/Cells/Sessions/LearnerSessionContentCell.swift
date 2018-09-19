//
//  LearnerSessionContentCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class LearnerSessionsContentCell: BaseSessionsContentCell {
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.register(LearnerPendingSessionCell.self, forCellWithReuseIdentifier: "pendingSessionCell")
        collectionView.register(LearnerPastSessionCell.self, forCellWithReuseIdentifier: "pastSessionCell")
        collectionView.register(BaseUpcomingSessionCell.self, forCellWithReuseIdentifier: "upcomingSessionCell")
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
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingSessionCell", for: indexPath) as! BaseUpcomingSessionCell
            cell.updateUI(session: upcomingSessions[indexPath.item])
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
