//
//  CardFooterView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class CardFooterView: UIView {
    
    var leftAccessoryView: UIView! {
        didSet {
            setupLeftAccessoryView()
        }
    }
    
    let connectButton: DimmableButton = {
        let button = DimmableButton()
        button.backgroundColor = Colors.learnerPurple
        button.setTitle("CONNECT", for: .normal)
        button.titleLabel?.font = Fonts.createBoldSize(14)
        button.layer.cornerRadius = 4
        return button
    }()
    
    func setupViews() {
        setupMainView()
        setupConnectButton()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    private func setupLeftAccessoryView() {
        addSubview(leftAccessoryView)
        leftAccessoryView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 150, height: 0)
    }
    
    func setupConnectButton() {
        addSubview(connectButton)
        connectButton.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 20, paddingRight: 20, width: 168, height: 0)
    }
    
    func updateUI(_ tutor: AWTutor) {
        guard let price = tutor.price else { return }
        guard let priceView = leftAccessoryView as? TutorCardAccessoryView else { return }
        priceView.priceLabel.text = "$\(price) per hour"
        let rating = Int(tutor.tRating)
        priceView.starView.setRating(rating)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
