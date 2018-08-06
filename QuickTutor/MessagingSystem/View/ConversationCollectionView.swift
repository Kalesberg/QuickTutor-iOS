//
//  ConversationCollectionView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 8/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class ConversationCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = Colors.darkBackground
        alwaysBounceVertical = true
        keyboardDismissMode = .interactive
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        showsVerticalScrollIndicator = false
        register(UserMessageCell.self, forCellWithReuseIdentifier: "textMessage")
        register(SystemMessageCell.self, forCellWithReuseIdentifier: "systemMessage")
        register(SessionRequestCell.self, forCellWithReuseIdentifier: "sessionMessage")
        register(ImageMessageCell.self, forCellWithReuseIdentifier: "imageMessage")
        register(ConnectionRequestCell.self, forCellWithReuseIdentifier: "connectionRequest")
        register(ConversationPaginationHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "paginationHeader")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
