//
//  QTTutorDiscoverOpportunityCollectionViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 9/4/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView

class QTTutorDiscoverOpportunityCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    @IBOutlet weak var containerView: QTCustomView!
    @IBOutlet weak var avatarImageView: QTCustomImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var separatorView: QTCustomView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var applyButton: QTCustomButton!
    @IBOutlet weak var asapMarkView: QTCustomView!
    
    static var reuseIdentifier: String {
        return String(describing: QTTutorDiscoverOpportunityCollectionViewCell.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    var quickRequest: QTQuickRequestModel!
    var didApplyButtonClickHandler: ((QTQuickRequestModel) -> Void)?
    
    // MARK: - Functions
    func setSkeletionViews() {
        self.isSkeletonable = true
        containerView.isSkeletonable = true
        containerView.cornerRadius = 5
        avatarImageView.isSkeletonable = true
        avatarImageView.cornerRadius = 30
        nameLabel.isSkeletonable = true
        nameLabel.linesCornerRadius = 5
        subjectLabel.isSkeletonable = true
        subjectLabel.linesCornerRadius = 5
        durationLabel.isSkeletonable = true
        durationLabel.linesCornerRadius = 5
        priceLabel.isSkeletonable = true
        priceLabel.linesCornerRadius = 5
        applyButton.isSkeletonable = true
        
        separatorView.isHidden = true
        asapMarkView.isHidden = true
        durationLabel.isHidden = true
    }
    
    func setData(request: QTQuickRequestModel) {
        self.quickRequest = request
        
        if let avatarUrl = request.profileImageUrl {
            avatarImageView.setImage(url: avatarUrl)
        } else {
            avatarImageView.image = UIImage(named: "ic_avatar_placeholder")
        }
        
        nameLabel.text = request.userName
        subjectLabel.text = request.subject
        priceLabel.text = String(format: "$%.02f Budget", request.maxPrice)
        durationLabel.text = request.getDurationText()
        
        separatorView.isHidden = false
        asapMarkView.isHidden = false
        durationLabel.isHidden = false
        
        if isSkeletonActive {
            hideSkeleton()
        }
    }
    
    // MARK: - Actions
    @IBAction func onApplyButtonClicked(_ sender: Any) {
        didApplyButtonClickHandler?(quickRequest)
    }
    
    
    // MARk: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.applyDefaultShadow()
        
        setSkeletionViews()
    }

}
