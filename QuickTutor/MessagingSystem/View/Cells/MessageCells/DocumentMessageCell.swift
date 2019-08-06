//
//  DocumentMessageCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/25/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class DocumentMessageCell: UserMessageCell {
    let fileIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "fileIcon")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = Colors.purple
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let fileNameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(14)
        label.textColor = .white
        return label
    }()
    
    override var bubbleWidthAnchor: NSLayoutConstraint? {
        return bubbleView.widthAnchor.constraint(equalToConstant: 285)
    }
    
    override func setupViews() {
        super.setupViews()
        setupFileIcon()
        setupFileNameLabel()
        textView.removeFromSuperview()
    }
    
    func setupFileIcon() {
        addSubview(fileIcon)
        fileIcon.anchor(top: bubbleView.topAnchor, left: bubbleView.leftAnchor, bottom: bubbleView.bottomAnchor, right: nil, paddingTop: 15, paddingLeft: 15, paddingBottom: 15, paddingRight: 0, width: 15, height: 15)
    }
    
    func setupFileNameLabel() {
        addSubview(fileNameLabel)
        fileNameLabel.anchor(top: bubbleView.topAnchor, left: fileIcon.rightAnchor, bottom: bubbleView.bottomAnchor, right: bubbleView.rightAnchor, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
    }
    
    override func updateUI(message: UserMessage) {
        super.updateUI(message: message)
        guard let url = message.documenUrl else { return }
        let fileNameUrl = (url as NSString).lastPathComponent
        let fileName = fileNameUrl.components(separatedBy: "?")[0].removingPercentEncoding
        fileNameLabel.text = fileName
        
        bubbleView.backgroundColor = Colors.newScreenBackground
    }
}
