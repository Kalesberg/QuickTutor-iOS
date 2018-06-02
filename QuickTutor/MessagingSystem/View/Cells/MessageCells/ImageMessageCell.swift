//
//  ImageMessageCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/27/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

protocol ImageMessageCellDelegate {
    func handleZoomFor(imageView: UIImageView)
}

class ImageMessageCell: UserMessageCell {
    
    var delegate: ImageMessageCellDelegate?
    
    let imageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 4
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    override func updateUI(message: UserMessage) {
        super.updateUI(message: message)
        
        if let imageUrl = message.imageUrl {
            imageView.isHidden = false
            imageView.loadImage(urlString: imageUrl)
        } else {
            imageView.isHidden = true
        }
    }
    
    override func setupViews() {
        super.setupViews()
        setupImageView()
        addZoomGestureRecognizer()
    }
    
    override func setupBubbleViewAsSentMessage() {
        super.setupBubbleViewAsSentMessage()
        bubbleView.backgroundColor = .clear
    }
    
    override func setupBubbleViewAsReceivedMessage() {
        super.setupBubbleViewAsReceivedMessage()
        bubbleView.backgroundColor = .clear
    }
    
    private func setupImageView() {
        bubbleView.addSubview(imageView)
        imageView.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
    func addZoomGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleZoom))
        imageView.addGestureRecognizer(tap)
    }
    
    @objc func handleZoom() {
        delegate?.handleZoomFor(imageView: imageView)
    }
}
