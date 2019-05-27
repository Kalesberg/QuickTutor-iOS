//
//  EmptyConversationBackground.swift
//  QuickTutor
//
//  Created by Zach Fuller on 8/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class EmptyConversationBackground: UIView {
    
    let helpView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.purple.withAlphaComponent(0.1)
        view.layer.borderColor = Colors.purple.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        return view
    }()
    
    let helpIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_message"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let helpConfirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("Ok, got it", for: .normal)
        button.setTitleColor(Colors.purple, for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.titleLabel?.textAlignment = .right
        return button
    }()
    
    let helpDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Select a custom message or introduce yourself by typing a message. A tutor must accept your connection request before you are able to message them again!"
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.numberOfLines = 0
        label.font = Fonts.createSize(14)
        return label
    }()
    
    func setupViews() {
        setupHelpView()
        setupHelpIconImageView()
        setupHelpConfirmButton()
        setupHelpDescriptionLabel()
    }

    func setupHelpView() {
        addSubview(helpView)
        helpView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    func setupHelpIconImageView() {
        helpView.addSubview(helpIconImageView)
        helpIconImageView.anchor(top: helpView.topAnchor, left: helpView.leftAnchor, bottom: nil, right: nil, paddingTop: 25, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
    }
    
    func setupHelpConfirmButton() {
        helpView.addSubview(helpConfirmButton)
        helpConfirmButton.anchor(top: helpView.topAnchor, left: nil, bottom: nil, right: helpView.rightAnchor, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 25, width: 70, height: 17)
        helpConfirmButton.addTarget(self, action: #selector(handleConfirmButtonClicked), for: .touchUpInside)
    }
    
    func setupHelpDescriptionLabel() {
        helpView.addSubview(helpDescriptionLabel)
        helpDescriptionLabel.anchor(top: helpIconImageView.bottomAnchor, left: helpView.leftAnchor, bottom: helpView.bottomAnchor, right: helpView.rightAnchor, paddingTop: 10, paddingLeft: 25, paddingBottom: 25, paddingRight: 25, width: 0, height: 0)
    }
    
    @objc
    func handleConfirmButtonClicked() {
        UIView.animate(withDuration: 0.25) {
            self.helpView.alpha = 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
