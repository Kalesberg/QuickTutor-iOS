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
    var amountLabelLeft: NSLayoutConstraint?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(16)
        return label
    }()
    
    let slider: CustomSlider = {
        let slider = CustomSlider()
        slider.minimumValue = 0
        slider.maximumValue = 250
        return slider
    }()
    
    let amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.registrationGray
        label.font = Fonts.createBoldSize(16)
        label.textAlignment = .right
        return label
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
    
    func setupSlider() {
        addSubview(slider)
        slider.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 20)
    }
    
    func setupAmountLabel() {
        addSubview(amountLabel)
        amountLabel.anchor(top: slider.bottomAnchor, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 14, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        amountLabelLeft = amountLabel.leftAnchor.constraint(equalTo: slider.leftAnchor, constant: 0)
        amountLabelLeft?.isActive = true
    }
    
    func setupTargets() {
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func sliderValueChanged(_ slider: CustomSlider) {
        
        let trackRect = slider.trackRect(forBounds: slider.bounds)
        let thumbRect = slider.thumbRect(forBounds: slider.bounds, trackRect: trackRect, value: slider.value)
        amountLabelLeft?.constant = thumbRect.origin.x - amountLabel.bounds.size.width / 2
        delegate?.customSlider(slider, didChange: slider.value)
    }
    
    func setSliderValue(_ value: Float) {
        slider.value = max(value, 0)
        perform(#selector(sliderValueChanged(_:)), with: slider)
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
