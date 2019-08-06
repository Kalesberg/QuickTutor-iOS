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
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = Colors.newScreenBackground
        alwaysBounceVertical = true
        keyboardDismissMode = .interactive
        contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        showsVerticalScrollIndicator = false
        keyboardBottomAdjustment = 0
//        register(UserMessageCell.self, forCellWithReuseIdentifier: MessageType.text.rawValue)
        register(UserTextMessageCell.self, forCellWithReuseIdentifier: MessageType.text.rawValue)
        register(SystemMessageCell.self, forCellWithReuseIdentifier: MessageType.systemMessage.rawValue)
        register(SessionRequestCell.self, forCellWithReuseIdentifier: MessageType.sessionRequest.rawValue)
        register(ImageMessageCell.self, forCellWithReuseIdentifier: MessageType.image.rawValue)
        register(VideoMessageCell.self, forCellWithReuseIdentifier: MessageType.video.rawValue)
        register(ConnectionRequestCell.self, forCellWithReuseIdentifier: MessageType.connectionRequest.rawValue)
        register(DocumentMessageCell.self, forCellWithReuseIdentifier: MessageType.document.rawValue)
        register(ConversationPaginationHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "paginationHeader")
        register(MessageGapTimestampCell.self, forCellWithReuseIdentifier: "timestampCell")
        addTypingIndicator()
    }
    
    func updateBottomValues(_ bottom: CGFloat) {
        // Save keyboard height.
        keyboardBottomAdjustment = bottom
        
        // Update the content inset bottom of message collectoin view.
        updateContentInsetBottom(bottom + (isTypingIndicatorVisible ? 48 : 0))
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
        var y: CGFloat = 0
        let seenIndictorPadding: CGFloat = 5
        var bottomInset: CGFloat = 0
        let typingIndicatorHeight: CGFloat = 48
        if isTypingIndicatorVisible {
            y = (contentSize.height > bounds.height + typingIndicatorHeight + seenIndictorPadding) ? contentSize.height : bounds.height
            bottomInset = (self.typingHeightAnchor?.constant ?? 0) + (keyboardBottomAdjustment ?? 0) + seenIndictorPadding
        } else {
            y = (contentSize.height > bounds.height) ? contentSize.height : bounds.height
            bottomInset = keyboardBottomAdjustment ?? 0
        }
        typingTopAnchor?.constant = y
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
        typingHeightAnchor?.constant = 48
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

class ConversationFlowLayout : UICollectionViewFlowLayout {
    var insertingIndexPaths = [IndexPath]()
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        insertingIndexPaths.removeAll()
        
        for update in updateItems {
            if let indexPath = update.indexPathAfterUpdate,
                update.updateAction == .insert {
                insertingIndexPaths.append(indexPath)
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        insertingIndexPaths.removeAll()
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        
        if insertingIndexPaths.contains(itemIndexPath) {
            attributes?.transform = CGAffineTransform(translationX: 0, y: 100.0)
        }
        
        return attributes
    }
}
