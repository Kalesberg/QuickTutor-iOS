//
//  RangeSliderView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/20/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class RangeSliderView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = Fonts.createBoldSize(16)
        return label
    }()
    
    let rangeSlider: RangeSlider = {
        let slider = RangeSlider()
        slider.trackTintColor = Colors.gray
        slider.trackHighlightTintColor = Colors.purple
        slider.maximumValue = 150
        return slider
    }()
    
    let lowerLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "$12/hr"
        label.textAlignment = .center
        label.textColor = Colors.grayText
        label.font = Fonts.createBoldSize(12)
        return label
    }()
    
    let upperLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "$45/hr"
        label.textAlignment = .center
        label.textColor = Colors.grayText
        label.font = Fonts.createBoldSize(12)
        return label
    }()
    
    var lowerLimitCenterXConstraint: NSLayoutConstraint?
    var upperLimitCenterXConstraint: NSLayoutConstraint?
    
    func setupViews() {
        setupTitleLabel()
        setupRangeSlider()
        setupLowerLimitLabel()
        setupUpperLimitLabel()
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 17)
    }
    
    func setupRangeSlider() {
        addSubview(rangeSlider)
        rangeSlider.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 5, paddingBottom: 0, paddingRight: 5, width: 0, height: 15)
        rangeSlider.layoutSubviews()
        //        rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
    }
    
    func setupLowerLimitLabel() {
        addSubview(lowerLimitLabel)
        lowerLimitLabel.anchor(top: rangeSlider.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 60, height: 30)
        lowerLimitCenterXConstraint = lowerLimitLabel.centerXAnchor.constraint(equalTo: rangeSlider.lowerThumbImageView.centerXAnchor, constant: 0)
        lowerLimitCenterXConstraint?.isActive = true
        lowerLimitLabel.layoutIfNeeded()
    }
    
    func setupUpperLimitLabel() {
        addSubview(upperLimitLabel)
        upperLimitLabel.anchor(top: rangeSlider.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 60, height: 30)
        upperLimitCenterXConstraint = upperLimitLabel.centerXAnchor.constraint(equalTo: rangeSlider.upperThumbImageView.centerXAnchor, constant: 0)
        upperLimitCenterXConstraint?.isActive = true
        upperLimitLabel.layoutIfNeeded()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
