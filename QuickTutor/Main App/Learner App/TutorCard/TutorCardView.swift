//
//  TutorCardView.swift
//  QuickTutor
//
//  Created by Zach Fuller on 12/13/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class TutorCardView: UIView, TutorDataSource {
    
    var tutor: AWTutor?
    var subject: String?
    var parentViewController: UIViewController?
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.canCancelContentTouches = true
        sv.isDirectionalLockEnabled = true
        sv.isExclusiveTouch = false
        sv.backgroundColor = Colors.darkBackground
        sv.layer.cornerRadius = 10
        return sv
    }()
    
    let headerView: TutorCardHeaderView = {
        let view = TutorCardHeaderView()
        return view
    }()
    
    let infoView: TutorCardInfoView = {
        let view = TutorCardInfoView()
        return view
    }()
    
    let reviewsView: TutorCardReviewsView = {
        let view = TutorCardReviewsView()
        return view
    }()
    
    let policiesView: TutorCardPoliciesView = {
        let view = TutorCardPoliciesView()
        return view
    }()
    
    let connectView: TutorCardConnectView = {
        let view = TutorCardConnectView()
        return view
    }()
    
    var infoHeightAnchor: NSLayoutConstraint?
    var reviewsHeightAnchor: NSLayoutConstraint?
    
    func setupViews() {
        setupScrollView()
        setupHeaderView()
        setupInfoView()
        setupReviewsView()
        setupPoliciesView()
        setupConnectView()
    }
    
    func setupScrollView() {
        addSubview(scrollView)
        scrollView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupHeaderView() {
        scrollView.addSubview(headerView)
        headerView.anchor(top: scrollView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    func setupInfoView() {
        scrollView.addSubview(infoView)
        infoView.anchor(top: headerView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        infoHeightAnchor = infoView.heightAnchor.constraint(equalToConstant: 0)
        infoHeightAnchor?.isActive = true
    }
    
    func setupReviewsView() {
        scrollView.addSubview(reviewsView)
        reviewsView.anchor(top: infoView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        reviewsHeightAnchor = reviewsView.heightAnchor.constraint(equalToConstant: 200)
        reviewsHeightAnchor?.isActive = true
    }
    
    func setupPoliciesView() {
        scrollView.addSubview(policiesView)
        policiesView.anchor(top: reviewsView.bottomAnchor, left: leftAnchor, bottom: scrollView.bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 50, paddingRight: 20, width: 0, height: 300)
    }
    
    func setupConnectView() {
        addSubview(connectView)
        connectView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 84)
        connectView.connectButton.addTarget(self, action: #selector(connect), for: .touchUpInside)
    }
    
    @objc func connect() {
        guard let tutor = tutor else { return }
        DataService.shared.getTutorWithId(tutor.uid) { tutor in
            let vc = ConversationVC()
            vc.receiverId = tutor?.uid
            vc.chatPartner = tutor
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func seeAllReviews(_ sender: UIButton) {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        headerView.sizeToFit()
        infoView.sizeToFit()
        reviewsView.sizeToFit()
        reviewsView.delegate = self
    }
    
    func updateUI(_ tutor: AWTutor) {
        headerView.updateUI(tutor)
        infoView.updateUI(tutor)
        reviewsView.updateUI(tutor)
        policiesView.updateUI(tutor)
        connectView.updateUI(tutor)
        self.tutor = tutor
        infoView.dataSource = self
        infoView.delegate = self
        infoView.subjectsCV.reloadData()
        if tutor.reviews?.count == 0 {
            reviewsHeightAnchor?.constant = 0
            reviewsView.clipsToBounds = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TutorCardView: TutorCardInfoViewDelegate {
    func infoView(_ infoView: TutorCardInfoView, didUpdate height: CGFloat) {
        infoHeightAnchor?.constant = height
        layoutIfNeeded()
    }
}

extension TutorCardView: TutorCardReviewsViewDelegate {
    func reviewsView(_ reviewsView: TutorCardReviewsView, didUpdate height: CGFloat) {
        reviewsHeightAnchor?.constant = height
        layoutIfNeeded()
    }
}

