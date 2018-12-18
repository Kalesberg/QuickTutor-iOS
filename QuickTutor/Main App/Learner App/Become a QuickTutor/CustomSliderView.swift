//
//  CustomSliderView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/18/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

protocol CustomSliderViewDelegate: class {
    func customSlider(_ slider: CustomSlider, didChange value: Float)
}

class CustomSliderView: UIView {
    
    weak var delegate: CustomSliderViewDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(16)
        return label
    }()
    
    let amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.registrationGray
        label.font = Fonts.createBoldSize(16)
        label.textAlignment = .right
        return label
    }()
    
    let slider: CustomSlider = {
        let slider = CustomSlider()
        slider.minimumValue = 0
        slider.maximumValue = 250
        return slider
    }()
    
    func setupViews() {
        setupTitleLabel()
        setupSlider()
        setupAmountLabel()
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 17)
    }
    
    func setupAmountLabel() {
        addSubview(amountLabel)
        amountLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 17)
    }
    
    func setupSlider() {
        addSubview(slider)
        slider.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    }
    
    func setupTargets() {
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func sliderValueChanged(_ slider: CustomSlider) {
        delegate?.customSlider(slider, didChange: slider.value)
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
