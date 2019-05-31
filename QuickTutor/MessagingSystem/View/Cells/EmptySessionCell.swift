//
//  EmptySessionCell.swift
//  QuickTutor
//
//  Created by Zach Fuller on 3/30/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import UIKit

class EmptySessionCell: UICollectionViewCell {
    let descriptions = ["You haven't sent any session requests.", "You have no upcoming sessions.", "Your previous sessions will appear here."]

    let requestsDescription = "You haven't received any sessions requests. Try adjusting your preferences or policies to increase requests."

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = Fonts.createSize(13)
        label.text = "You have no upcoming sessions"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = Colors.newScreenBackground
        setupDescriptionLabel()
    }
    
    private func setupDescriptionLabel() {
        addSubview(descriptionLabel)
        descriptionLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 60, paddingBottom: 0, paddingRight: 60, width: 0, height: 0)
    }

    func setLabelToRequests() {
        descriptionLabel.text = requestsDescription
    }

    func setLabelToPending() {
        descriptionLabel.text = descriptions[0]
    }

    func setLabelToUpcoming() {
        descriptionLabel.text = descriptions[1]
    }

    func setLabelToPast() {
        descriptionLabel.text = descriptions[2]
    }
}
