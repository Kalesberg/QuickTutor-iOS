//
//  MessagingSystemToggleCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/19/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class MessagingSystemToggleCell: UICollectionViewCell {
    
    var unselectedColor = UIColor.white.withAlphaComponent(0.5)
    var selectedColor = UIColor.white
    
    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = Fonts.createLightSize(15)
        return label
    }()
    
    let gradientLayer: CAGradientLayer = {
        let firstColor = Colors.tutorBlue.cgColor
        let secondColor = Colors.learnerPurple.cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = 1
        gradientLayer.colors = [firstColor, secondColor]
        
        
        let x: Double! = 90 / 360.0
        let a = pow(sinf(Float(2.0 * .pi * ((x + 0.75) / 2.0))),2.0);
        let b = pow(sinf(Float(2 * .pi * ((x+0.0)/2))),2);
        let c = pow(sinf(Float(2 * .pi * ((x+0.25)/2))),2);
        let d = pow(sinf(Float(2 * .pi * ((x+0.5)/2))),2);
        
        gradientLayer.endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
        gradientLayer.startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
        gradientLayer.locations = [0, 0.7, 0.9, 1]
        gradientLayer.isHidden = true
        return gradientLayer
    }()
    
    override var isHighlighted: Bool {
        didSet {
            label.textColor = isHighlighted ? selectedColor : unselectedColor
            gradientLayer.isHidden = !isSelected
        }
    }
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? selectedColor : unselectedColor
            gradientLayer.isHidden = !isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        completeSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = .clear
        setupLabel()
        setupGradientLayer()
    }
    
    func setupLabel() {
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupGradientLayer() {
        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = bounds
    }
    
    func completeSetup() {
        
    }
}
