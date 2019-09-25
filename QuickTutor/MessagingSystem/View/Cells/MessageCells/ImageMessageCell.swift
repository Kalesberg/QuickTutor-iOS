//
//  ImageMessageCell.swift
//  QuickTutorMessaging
//
//  Created by Zach Fuller on 2/27/18.
//  Copyright © 2018 Zach Fuller. All rights reserved.
//

import UIKit

protocol ImageMessageCellDelegate {
    func handleZoomFor(imageView: UIImageView, scrollDelegate: UIScrollViewDelegate, zoomableView: ((UIImageView) -> ())?)
    func messageCell (_ cell: ImageMessageCell, didTapImage imageUrl: String?)
}

class ImageMessageCell: UserMessageCell {
    var delegate: ImageMessageCellDelegate?
    var zoomableView: UIImageView?
    
    let imageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    override var bubbleWidthAnchor: NSLayoutConstraint? {
        return bubbleView.widthAnchor.constraint(equalToConstant: 200)
    }

    override func updateUI(message: UserMessage) {
        super.updateUI(message: message)
        bubbleView.layer.borderWidth = 0
        if let imageUrl = message.imageUrl,
            let url = URL(string: imageUrl) {
            imageView.isHidden = false
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "img_default"))
        } else {
            imageView.isHidden = true
        }
    }

    override func setupViews() {
        super.setupViews()
        setupImageView()
        if self is VideoMessageCell {
            addZoomGestureRecognizer()
        } else {
            addTapGestureRecognizer ()
        }
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

    private func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapImage))
        imageView.addGestureRecognizer(tap)
    }

    @objc func handleZoom() {
        delegate?.handleZoomFor(imageView: imageView, scrollDelegate: self, zoomableView: { (zoomableView) in
            self.zoomableView = zoomableView
        })
    }
    
    @objc
    private func onTapImage () {
        delegate?.messageCell(self, didTapImage: userMessage?.imageUrl)
    }
}

extension ImageMessageCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.zoomableView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)

        self.zoomableView?.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}
