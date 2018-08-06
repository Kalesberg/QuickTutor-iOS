//
//  ConversationPaginationHeader.swift
//  QuickTutor
//
//  Created by Zach Fuller on 8/5/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class ConversationPaginationHeader: UICollectionReusableView {
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.color = Colors.grayText
        return indicator
    }()
    
    func setupViews() {
        setupMainView()
        setupActivityIndicator()
    }
    
    func setupMainView() {
        backgroundColor = Colors.darkBackground
    }
    
    func setupActivityIndicator() {
        addSubview(activityIndicator)
        activityIndicator.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 10, height: 0)
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        activityIndicator.startAnimating()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
