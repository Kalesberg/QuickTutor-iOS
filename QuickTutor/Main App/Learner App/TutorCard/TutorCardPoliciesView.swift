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
    
    let sessionTypeIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "sessionTypePolicyIcon")
        return iv
    }()
    
    let sessionTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Tutor online or in-person"
        return label
    }()
    
    let travelIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "travelPolicyIcon")
        return iv
    }()
    
    let travelLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = Fonts.createSize(16)
        label.text = "Travel up to 5 miles"
        return label
    }()
    
    let latePolicyIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "latePolicyIcon")
        return iv
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
    
    let cancellationPolicyIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "cancellationPolicyIcon")
        return iv
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
        setupSessionTypeIcon()
        setupSessionTypeLabel()
        setupTravelIcon()
        setupTravelLabel()
        setupLatePolicyIcon()
        setupLatePolicyLabel()
        setupLateFeeLabel()
        setupCancellationPolicyIcon()
        setupCancellationPolicyLabel()
        setupCancellationFeeLabel()
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func setupSessionTypeIcon() {
        addSubview(sessionTypeIcon)
        sessionTypeIcon.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
    }
    
    func setupSessionTypeLabel() {
        addSubview(sessionTypeLabel)
        sessionTypeLabel.anchor(top: titleLabel.bottomAnchor, left: sessionTypeIcon.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
    }
    
    func setupTravelIcon() {
        addSubview(travelIcon)
        travelIcon.anchor(top: sessionTypeLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
    }
    
    func setupTravelLabel() {
        addSubview(travelLabel)
        travelLabel.anchor(top: sessionTypeLabel.bottomAnchor, left: travelIcon.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 15, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
    }
    
    func setupLatePolicyIcon() {
        addSubview(latePolicyIcon)
        latePolicyIcon.anchor(top: travelLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
    }
    
    func setupLatePolicyLabel() {
        addSubview(latePolicyLabel)
        latePolicyLabel.anchor(top: travelLabel.bottomAnchor, left: latePolicyIcon.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 15, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
    }
    
    func setupLateFeeLabel() {
        addSubview(lateFeeLabel)
        lateFeeLabel.anchor(top: latePolicyLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
    }
    
    func setupCancellationPolicyIcon() {
        addSubview(cancellationPolicyIcon)
        cancellationPolicyIcon.anchor(top: lateFeeLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
    }
    
    func setupCancellationPolicyLabel() {
        addSubview(cancellationPolicyLabel)
        cancellationPolicyLabel.anchor(top: lateFeeLabel.bottomAnchor, left: cancellationPolicyIcon.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 15, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 15)
    }
    
    func setupCancellationFeeLabel() {
        addSubview(cancellationFeeLabel)
        cancellationFeeLabel.anchor(top: cancellationPolicyLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 0, height: 22)
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
