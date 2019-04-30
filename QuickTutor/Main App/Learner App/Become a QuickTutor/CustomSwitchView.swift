//
//  CustomSwitchView.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 4/30/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

protocol CustomSwitchViewDelegate: class {
    func customSwitchValueChanged(_ isOn: Bool)
}
class CustomSwitchView: QTCustomView {

    var isOn = false {
        didSet {
            setValue()
        }
    }
    
    var delegate: CustomSwitchViewDelegate?
    
    let switchOnImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_switch_on")
        return imageView
    }()

    let switchOffImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_switch_off")
        return imageView
    }()
    
    func setupSwitchOnImageView() {
        addSubview(switchOnImageView)
        switchOnImageView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 2, width: 32, height: 32)
        switchOnImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func setupSwitchOffImageView() {
        addSubview(switchOffImageView)
        switchOffImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 2, paddingBottom: 0, paddingRight: 0, width: 32, height: 32)
        switchOffImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func setupViews() {
        
        cornerRadius = 18
        borderWidth = 1
        borderColor = Colors.gray
        
        setupSwitchOnImageView()
        setupSwitchOffImageView()
    }
    
    func setupTargets() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDidTap)))
    }
    
    @objc
    func handleDidTap() {
        isOn = !isOn
        delegate?.customSwitchValueChanged(isOn)
    }
    
    func setValue() {
        if isOn {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                self.switchOnImageView.alpha = 1.0
                self.switchOffImageView.alpha = 0.0
            }, completion: { finished in
                
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                self.switchOnImageView.alpha = 0.0
                self.switchOffImageView.alpha = 1.0
            }, completion: { finished in
                
            })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupTargets()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
