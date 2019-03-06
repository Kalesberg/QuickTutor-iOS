//
//  QuickChatViewCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/24/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

class QuickChatCell: UICollectionViewCell {
    let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = false
        view.clipsToBounds = false
        view.applyDefaultShadow()
        view.backgroundColor = Colors.purple
        return view
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupBubbleView()
        setupTextLabel()
    }
    
    private func setupBubbleView() {
        addSubview(bubbleView)
        bubbleView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 6, paddingLeft: 0, paddingBottom: 6, paddingRight: 0, width: 0, height: 0)
    }
    
    private func setupTextLabel() {
        addSubview(textLabel)
        textLabel.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 8, paddingRight: 12, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
