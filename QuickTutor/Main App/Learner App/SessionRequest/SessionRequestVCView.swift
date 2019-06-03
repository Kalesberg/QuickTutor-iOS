//
//  SessionRequestVCView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/12/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class SessionRequestVCView: UIView, TutorDataSource {
    
    var tutor: AWTutor?
    weak var parentViewController: SessionRequestVC?
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.canCancelContentTouches = true
        sv.isDirectionalLockEnabled = true
        sv.isExclusiveTouch = false
        sv.backgroundColor = Colors.newScreenBackground
        sv.layer.cornerRadius = 10
        return sv
    }()
    
    let tutorView: SessionRequestTutorView = {
        let view = SessionRequestTutorView()
        return view
    }()
    
    let subjectView: SessionRequestSubjectView = {
        let view = SessionRequestSubjectView()
        return view
    }()
    
    let dateView: SessionRequestDateView = {
        let view = SessionRequestDateView()
        return view
    }()
    
    let durationView: SessionRequestDurationView = {
        let view = SessionRequestDurationView()
        return view
    }()
    
    let paymentView: SessionRequestPaymentView = {
        let view = SessionRequestPaymentView()
        return view
    }()
    
    let sessionTypeView: SessionRequestTypeView = {
        let view = SessionRequestTypeView()
        view.collectionView.selectItem(at: IndexPath(item: 1, section: 0), animated: false, scrollPosition: [])
        return view
    }()
    
    let sendView: SessionRequestSendView = {
        let view = SessionRequestSendView()
        view.connectButton.backgroundColor = Colors.gray
        return view
    }()
    
    var subjectViewHeightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupScrollView()
        setupMainView()
        setupTutorView()
        setupSubjectView()
        setupDateView()
        setupDurationView()
        setupPaymentView()
        setupSessionTypeView()
        setupSendView()
    }
    
    func setupMainView() {
        backgroundColor = Colors.newScreenBackground
    }
    
    func setupScrollView() {
        addSubview(scrollView)
        scrollView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 84, paddingRight: 0, width: 0, height: 0)
        scrollView.delegate = self
    }
    
    func setupTutorView() {
        scrollView.addSubview(tutorView)
        tutorView.anchor(top: scrollView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 107)
    }
    
    func setupSubjectView() {
        scrollView.addSubview(subjectView)
        subjectView.anchor(top: tutorView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        subjectViewHeightAnchor = subjectView.heightAnchor.constraint(equalToConstant: 200)
        subjectViewHeightAnchor?.isActive = true
        subjectView.dataSource = self
        subjectView.delegate = self
        setupTemporaryDataSource()
    }
    
    func setupTemporaryDataSource() {
        let tempTutor = AWTutor(dictionary: [String : Any]())
        tempTutor.subjects = ["None"]
        tutor = tempTutor
        subjectView.collectionView.reloadData()
    }
    
    func setupDateView() {
        scrollView.addSubview(dateView)
        dateView.anchor(top: subjectView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 210)
    }
    
    func setupDurationView() {
        scrollView.addSubview(durationView)
        durationView.anchor(top: dateView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 134)
        durationView.collectionView.scrollToItem(at: IndexPath(item: 7, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    func setupPaymentView() {
        scrollView.addSubview(paymentView)
        paymentView.anchor(top: durationView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 220)
    }
    
    func setupSessionTypeView() {
        scrollView.addSubview(sessionTypeView)
        sessionTypeView.anchor(top: paymentView.bottomAnchor, left: leftAnchor, bottom: scrollView.bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 74)
    }
    
    func setupSendView() {
        addSubview(sendView)
        sendView.anchor(top: scrollView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 84)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tutor = CurrentUser.shared.tutor
        setupViews()
        
        sendView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.2, offset: CGSize(width: 0, height: -2), radius: 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SessionRequestVCView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if #available(iOS 11.0, *) {
            self.parentViewController?.navigationItem.largeTitleDisplayMode = .never
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.endEditing(true)
    }
}

extension SessionRequestVCView: SessionRequestSubjectsViewDeleagte {
    func sessionRequestSubjectView(_ subjectView: SessionRequestSubjectView, didUpdate height: CGFloat) {
        subjectViewHeightAnchor?.constant = height
        layoutIfNeeded()
    }
    
    func sessionRequestSubjectView(_ subjectView: SessionRequestSubjectView, didSelect subject: String) {
        parentViewController?.subject = subject
        parentViewController?.checkForErrors()
    }
}
