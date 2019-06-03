//
//  TutorManagePoliciesVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 1/10/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit

class TutorManagePoliciesVCView: UIView {
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = Colors.newScreenBackground
        return scrollView
    }()
    
    let latePolicy: EditProfilePolicyView = {
        let view = EditProfilePolicyView()
        view.infoLabel.label.text = "Late Policy"
        view.textField.attributedPlaceholder = NSAttributedString(string: "Enter how many minutes",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
        view.label.text = "How much time will you allow to pass before a learner is late to a session?"
        return view
    }()
    
    let lateFee: EditProfilePolicyView = {
        let view = EditProfilePolicyView()
        
        view.infoLabel.label.text = "Late Fee"
        view.textField.attributedPlaceholder = NSAttributedString(string: "Enter a late fee",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
        view.label.text = "How much a learner pays if they arrive late to a session."
        
        return view
    }()
    
    let cancelNotice: EditProfilePolicyView = {
        let view = EditProfilePolicyView()
        view.infoLabel.label.text = "Cancellation Notice"
        view.textField.attributedPlaceholder = NSAttributedString(string: "Enter how many hours",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
        view.label.text = "How many hours before a session should a learner notify you of a cancellation?"
        return view
        
    }()
    
    let cancelFee: EditProfilePolicyView = {
        let view = EditProfilePolicyView()
        view.infoLabel.label.text = "Cancellation Fee"
        view.textField.attributedPlaceholder = NSAttributedString(string: "Enter cancellation fee",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: Colors.grayText])
        view.label.text = "How much a learner pays if they cancel a session after the above time."
        return view
    }()
    
    let subTitle: UILabel = {
        let label = UILabel()
        label.text = "Policies"
        label.font = Fonts.createBoldSize(22)
        label.textColor = .white
        return label
    }()
    
    let emptySpace = UIView()
    
    func setupViews() {
        setupMainView()
        setupScrollView()
        setupSubtitle()
        setupLatePolicy()
        setupLateFee()
        setupCancelNotice()
        setupCancelFee()
        setupEmptySpace()
    }
    
    func setupMainView() {
        backgroundColor = Colors.newScreenBackground
    }
    
    func setupScrollView() {
        addSubview(scrollView)
        scrollView.anchor(top: getTopAnchor(), left: leftAnchor, bottom: getBottomAnchor(), right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    func setupSubtitle() {
        scrollView.addSubview(subTitle)
        subTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.height.equalTo(50)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    func setupLatePolicy() {
        scrollView.addSubview(latePolicy)
        latePolicy.snp.makeConstraints { make in
            make.top.equalTo(subTitle.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(120)
        }
    }
    
    func setupLateFee() {
        scrollView.addSubview(lateFee)
        lateFee.snp.makeConstraints { make in
            make.top.equalTo(latePolicy.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(120)
        }
    }
    
    func setupCancelNotice() {
        scrollView.addSubview(cancelNotice)
        cancelNotice.snp.makeConstraints { make in
            make.top.equalTo(lateFee.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(120)
        }
    }
    
    func setupCancelFee() {
        scrollView.addSubview(cancelFee)
        cancelFee.snp.makeConstraints { make in
            make.top.equalTo(cancelNotice.snp.bottom)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(120)
        }
    }
    
    func setupEmptySpace() {
        scrollView.addSubview(emptySpace)
        emptySpace.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(cancelFee.snp.bottom)
            make.height.equalTo(250)
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
