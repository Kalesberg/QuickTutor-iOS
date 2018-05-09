//
//  CountdownTimer.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/22/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol CountdownTimerDelegate {
    func didUpdateTime(_ time: Int)
}

class CountdownTimer: UIView {
    
    var timeInSeconds = 0
    var timer: Timer?
    
    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.text = "01:33:13"
        label.font = Fonts.createSize(15)
        return label
    }()
    
    var delegate: CountdownTimerDelegate?
    
    func setupViews() {
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    func stopTimer() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
    }
    
    @objc func updateTimeLabel() {
        timeInSeconds += 1
        
        let hours = timeInSeconds / 60 / 60
        let minutes = (timeInSeconds - hours * 60 * 60) / 60
        let seconds = timeInSeconds - (timeInSeconds - hours * 60 * 60) - (timeInSeconds - minutes * 60)
        
        label.text = "\(hours):\(minutes):\(seconds * -1)"
        
        delegate?.didUpdateTime(timeInSeconds)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        startTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

