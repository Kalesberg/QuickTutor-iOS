//
//  CountdownTimer.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class CountdownTimer: UIView {
    
    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.text = "01:33:13"
        label.font = Fonts.createSize(15)
        return label
    }()
    
    
    func setupViews() {
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func listenForTimerChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabel(notification:)), name: NSNotification.Name("com.qt.updateTime"), object: nil)
    }
    
    @objc func updateLabel(notification: Notification) {
        guard let info = notification.userInfo as? [String: Any], let timeString = info["timeString"] as? String else { return }
        label.text = timeString
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        listenForTimerChanges()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

