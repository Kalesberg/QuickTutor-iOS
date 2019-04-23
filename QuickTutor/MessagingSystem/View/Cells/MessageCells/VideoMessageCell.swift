//
//  VideoMessageCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/22/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class VideoMessageCell: ImageMessageCell {
    
    let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "playIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        imageView.isUserInteractionEnabled = false
        setupPlayButton()
    }
    
    func setupPlayButton() {
        addSubview(playButton)
        playButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        addConstraint(NSLayoutConstraint(item: playButton, attribute: .centerX, relatedBy: .equal, toItem: imageView, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: playButton, attribute: .centerY, relatedBy: .equal, toItem: imageView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
}
