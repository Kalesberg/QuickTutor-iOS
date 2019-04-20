//
//  ConversationCollectionView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 8/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit
import Lottie

class ConversationCollectionView: UICollectionView {
    
    let topInset: CGFloat = 8.0
    var chatPartner: User!
    var typingTopAnchor: NSLayoutConstraint?
    var typingHeightAnchor: NSLayoutConstraint?
    var keyboardBottomAdjustment: CGFloat?
    var isTypingIndicatorVisible: Bool = false
    
    let typingIndicatorView: TypingIndicatorView = {
        let view = TypingIndicatorView()
        return view
    }()
    
    override var contentSize: CGSize {
        didSet {
            typingTopAnchor?.constant += contentSize.height - oldValue.height
            layoutIfNeeded()
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = Colors.darkBackground
        alwaysBounceVertical = true
        keyboardDismissMode = .interactive
        contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        showsVerticalScrollIndicator = false
        keyboardBottomAdjustment = 0
        register(UserMessageCell.self, forCellWithReuseIdentifier: "textMessage")
        register(SystemMessageCell.self, forCellWithReuseIdentifier: "systemMessage")
        register(SessionRequestCell.self, forCellWithReuseIdentifier: "sessionMessage")
        register(ImageMessageCell.self, forCellWithReuseIdentifier: "imageMessage")
        register(ConnectionRequestCell.self, forCellWithReuseIdentifier: "connectionRequest")
        register(ConversationPaginationHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "paginationHeader")
        register(MessageGapTimestampCell.self, forCellWithReuseIdentifier: "timestampCell")
        addTypingIndicator()
    }
    
    func updateBottomValues(_ bottom: CGFloat) {
        keyboardBottomAdjustment = bottom
        updateContentInsetBottom(bottom)
    }
    
    func updateContentInsetBottom(_ bottom: CGFloat) {
        self.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: bottom, right: 0)
    }

    func addTypingIndicator() {
        addSubview(typingIndicatorView)
        typingIndicatorView.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        typingTopAnchor = typingIndicatorView.topAnchor.constraint(equalTo: topAnchor, constant: contentSize.height)
        typingHeightAnchor = typingIndicatorView.heightAnchor.constraint(equalToConstant: 0)
        typingHeightAnchor?.isActive = true
        typingTopAnchor?.isActive = true
        bringSubviewToFront(typingIndicatorView)
    }
    
    func scrollToBottom(animated: Bool) {
        guard contentSize.height > bounds.size.height else { return }
        scrollToItem(at: IndexPath(item: self.numberOfItems(inSection: 0) - 1, section: 0), at: .top, animated: animated)
    }
    
    func layoutTypingLabelIfNeeded() {
        
        // The definitive bottom of the collection view
        let bottom = contentOffset.y + bounds.size.height
        
        // Check the content size is greater than the bounds or use the bounds as the position for the y
        let y = contentSize.height > bounds.height ? contentSize.height : bounds.height - 80
        typingTopAnchor?.constant = y
        let seenIndictorPadding: CGFloat = 5
        let bottomInset = (self.typingHeightAnchor?.constant ?? 0) + (keyboardBottomAdjustment ?? 0) + seenIndictorPadding
        self.layoutIfNeeded()
        updateContentInsetBottom(bottomInset)
        
        // Only scroll the view if the user is already at the bottom
        if Int(bottom) >= Int(contentSize.height) && Int(contentSize.height) > Int(bounds.height) {
            scrollToBottom(animated: true)
        }
    }
    
    func showTypingIndicator() {
        if (isTypingIndicatorVisible) {
            return
        }
        
        isTypingIndicatorVisible = true
        if let profilePicUrl = chatPartner?.profilePicUrl {
            typingIndicatorView.profileImageView.sd_setImage(with: profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
        }
        typingHeightAnchor?.constant = 36.8
        layoutTypingLabelIfNeeded()
    }
    
    func hideTypingIndicator() {
        isTypingIndicatorVisible = false
        typingHeightAnchor?.constant = 0
        layoutTypingLabelIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
