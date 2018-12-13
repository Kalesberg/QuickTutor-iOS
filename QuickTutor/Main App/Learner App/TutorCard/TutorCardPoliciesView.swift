//
//  TutorCardPoliciesView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorCardPoliciesView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Policies"
        return label
    }()
    
    let sessionTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Tutor online or in-person"
        return label
    }()
    
    let travelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Travel up to 5 miles"
        return label
    }()
    
    let latePolicyLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Late Policy: 10 Minutes Notice"
        return label
    }()
    
    let lateFeeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Late Fee: $10.00"
        return label
    }()
    
    let cancellationPolicyLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Cancellation Policy: 24 Hours Notice"
        return label
    }()
    
    let cancellationFeeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Cancellation Fee: $5.00"
        return label
    }()
    
    func setupViews() {
        setupTitleLabel()
        setupSessionTypeLabel()
        setupTravelLabel()
        setupLatePolicyLabel()
        setupLateFeeLabel()
        setupCancellationPolicyLabel()
        setupCancellationFeeLabel()
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func setupSessionTypeLabel() {
        addSubview(sessionTypeLabel)
        sessionTypeLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func setupTravelLabel() {
        addSubview(travelLabel)
        travelLabel.anchor(top: sessionTypeLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func setupLatePolicyLabel() {
        addSubview(latePolicyLabel)
        latePolicyLabel.anchor(top: travelLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func setupLateFeeLabel() {
        addSubview(lateFeeLabel)
        lateFeeLabel.anchor(top: latePolicyLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func setupCancellationPolicyLabel() {
        addSubview(cancellationPolicyLabel)
        cancellationPolicyLabel.anchor(top: lateFeeLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func setupCancellationFeeLabel() {
        addSubview(cancellationFeeLabel)
        cancellationFeeLabel.anchor(top: cancellationPolicyLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func updateUI(_ tutor: AWTutor) {
        guard let policy = tutor.policy else { return }
        let policies = policy.split(separator: "_")
        sessionTypeLabel.text = tutor.preference.preferenceNormalization()
        travelLabel.text = tutor.distance.distancePreference(tutor.preference)
        latePolicyLabel.text = String(policies[0]).lateNotice()
        lateFeeLabel.text = String(policies[1]).lateFee().trimmingCharacters(in: .whitespacesAndNewlines)
        cancellationPolicyLabel.text = String(policies[2]).cancelNotice()
        cancellationFeeLabel.text = String(policies[3]).cancelFee().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
