//
//  SessionsContentCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class SessionsContentCell: BaseContentCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        collectionView.register(ConversationCell.self, forCellWithReuseIdentifier: "cellId")
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ConversationCell
        //        cell.updateUI(message: messages[indexPath.item])
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
