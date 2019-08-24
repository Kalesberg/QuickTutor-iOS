//
//  QTQuickRequestAlertModal.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/20/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class QTQuickRequestAlertModal: BaseCustomModal {

    let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = Fonts.createSize(12)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.numberOfLines = 0
        
        return label
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray
        view.layer.cornerRadius = 0.6
        
        return view
    }()
    
    let callToActionButton: DimmableButton = {
        let button = DimmableButton()
        button.setTitle("Okay", for: .normal)
        button.setTitleColor(Colors.purple, for: .normal)
        button.titleLabel?.font = Fonts.createBlackSize(17)
        
        return button
    }()
    
    func setupMessageLabel() {
        background.addSubview(messageLabel)
        
        messageLabel.anchor(top: titleLabel.bottomAnchor,
                            left: background.leftAnchor,
                            bottom: nil,
                            right: background.rightAnchor,
                            paddingTop: 20,
                            paddingLeft: 20,
                            paddingBottom: 0,
                            paddingRight: 20,
                            width: 0,
                            height: 0)
    }
    
    func setupSeparatorView() {
        background.addSubview(separatorView)
        
        separatorView.anchor(top: messageLabel.bottomAnchor,
                             left: background.leftAnchor,
                             bottom: nil,
                             right: background.rightAnchor,
                             paddingTop: 20,
                             paddingLeft: 20,
                             paddingBottom: 0,
                             paddingRight: 20,
                             width: 0,
                             height: 1)
    }
    
    func setupCallToActionButton() {
        background.addSubview(callToActionButton)
        
        callToActionButton.anchor(top: separatorView.bottomAnchor, left: background.leftAnchor, bottom: background.bottomAnchor, right: background.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 58)
        
        callToActionButton.addTarget(self, action: #selector(handleCTAButtonClicked(_:)), for: .touchUpInside)
    }
    
    override func setupViews() {
        super.setupViews()
        
        setupMessageLabel()
        setupSeparatorView()
        setupCallToActionButton()
        
    }
    
    func set(_ title: String? = nil, _ message: String? = nil, _ ctaButtonTitle: String? = nil) {
        if let title = title {
            titleLabel.text = title
        }
        
        if let message = message {
            messageLabel.text = message
        }
        
        if let ctaButtonTitle = ctaButtonTitle {
            callToActionButton.setTitle(ctaButtonTitle, for: .normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc
    func handleCTAButtonClicked(_ sender: UIButton) {
        dismiss()
    }
}
