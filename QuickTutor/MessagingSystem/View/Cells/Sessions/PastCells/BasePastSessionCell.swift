//
//  BasePastSessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 4/9/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class BasePastSessionCell: BaseSessionCell {
    
    let darkenView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        return view
    }()
    
    let starView: StarView = {
        let sv = StarView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    func updateUI(_ session: Session) {
        self.session = session
    }
    
    override func setupViews() {
        super.setupViews()
        setupDarkenView()
        setupStarView()
        starIcon.removeFromSuperview()
        starLabel.removeFromSuperview()
    }
    
    override func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    private func setupDarkenView() {
        insertSubview(darkenView, belowSubview: actionView)
        darkenView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    private func setupStarView() {
        addSubview(starView)
        starView.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 8, paddingRight: 12, width: 40, height: 7)
    }
}
