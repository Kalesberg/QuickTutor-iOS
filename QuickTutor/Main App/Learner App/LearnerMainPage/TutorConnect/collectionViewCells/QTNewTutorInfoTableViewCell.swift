//
//  QTNewTutorInfoTableViewCell.swift
//  QuickTutor
//
//  Created by jcooperation0137 on 8/19/19.
//  Copyright © 2019 QuickTutor. All rights reserved.
//

import UIKit
import SkeletonView
import Lottie

class QTNewTutorInfoTableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: QTNewTutorInfoTableViewCell.self)
    }
    
    var tutor: AWTutor?
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.isSkeletonable = true
        iv.layer.cornerRadius = 30
        
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(16)
        label.textColor = UIColor.white
        label.isSkeletonable = true
        label.linesCornerRadius = 4
        
        return label
    }()
    
    let hourlyRateLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(16)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.isHidden = true
        
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 4
        stackView.isSkeletonable = true
        
        return stackView
    }()
    
    let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(14)
        label.textColor = Colors.purple
        label.isSkeletonable = true
        label.linesCornerRadius = 4
        
        return label
    }()
    
    let ratingImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "ic_star_filled")
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        
        return iv
    }()
    
    let ratingCaptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(14)
        label.textColor = Colors.purple
        label.text = "Rating"
        label.isHidden = true
        
        return label
    }()
    
    let subjectsLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createMediumSize(14)
        label.textColor = .white
        label.numberOfLines = 0
        label.isSkeletonable = true
        label.linesCornerRadius = 4
        
        return label
    }()
    
    var nameLabelWidthAnchor: NSLayoutConstraint?
    var nameLabelHeightAnchor: NSLayoutConstraint?
    var ratingLabelWidthAnchor: NSLayoutConstraint?
    var ratingLabelHeightAnchor: NSLayoutConstraint?
    var subjectsLabelHeightAnchor: NSLayoutConstraint?
    var subjectsLabelBottomAnchor: NSLayoutConstraint?
    
    func setupProfileImageView() {
        contentView.addSubview(profileImageView)
        
        profileImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, paddingTop: 22, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
    }
    
    func setupNameLabel() {
        contentView.addSubview(nameLabel)
        
        nameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        nameLabelWidthAnchor = nameLabel.widthAnchor.constraint(equalToConstant: 100)
        nameLabelWidthAnchor?.isActive = true
        nameLabelHeightAnchor = nameLabel.heightAnchor.constraint(equalToConstant: 14)
        nameLabelHeightAnchor?.isActive = true
    }
    
    func setupHorlyRateLabel() {
        contentView.addSubview(hourlyRateLabel)
        
        hourlyRateLabel.anchor(top: profileImageView.topAnchor, left: nil, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        hourlyRateLabel.leftAnchor.constraint(greaterThanOrEqualTo: nameLabel.rightAnchor, constant: -8).isActive = true
    }
    
    func setupStackView() {
        contentView.addSubview(stackView)
        
        stackView.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        stackView.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -20).isActive = true
    }
    
    func setupRatingImageView() {
        stackView.addArrangedSubview(ratingImageView)
        
        ratingImageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
    }
    
    func setupRatingLabel() {
        stackView.addArrangedSubview(ratingLabel)
        
        ratingLabelWidthAnchor = ratingLabel.widthAnchor.constraint(equalToConstant: 200)
        ratingLabelWidthAnchor?.isActive = true
        ratingLabelHeightAnchor = ratingLabel.heightAnchor.constraint(equalToConstant: 14)
        ratingLabelHeightAnchor?.isActive = true
    }
    
    func setupRatingCaptionLabel() {
        stackView.addArrangedSubview(ratingCaptionLabel)
    }
    
    func setupSubjectsLabel() {
        contentView.addSubview(subjectsLabel)
        
        subjectsLabel.anchor(top: stackView.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: contentView.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        subjectsLabelHeightAnchor = subjectsLabel.heightAnchor.constraint(equalToConstant: 14)
        subjectsLabelHeightAnchor?.isActive = true
        subjectsLabelBottomAnchor = subjectsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        subjectsLabelBottomAnchor?.isActive = true
    }
    
    func setupViews() {
        contentView.backgroundColor = Colors.newScreenBackground
        backgroundColor = Colors.newScreenBackground
        
        setupProfileImageView()
        setupNameLabel()
        setupHorlyRateLabel()
        setupStackView()
        setupRatingImageView()
        setupRatingLabel()
        setupRatingCaptionLabel()
        setupSubjectsLabel()
        
        isSkeletonable = true
    }
    
    func updateUI(_ tutor: AWTutor) {
        if isSkeletonActive {
            hideSkeleton()
        }
        nameLabelWidthAnchor?.isActive = false
        nameLabelHeightAnchor?.isActive = false
        ratingLabelWidthAnchor?.isActive = false
        ratingLabelHeightAnchor?.isActive = false
        subjectsLabelHeightAnchor?.isActive = false
        hourlyRateLabel.isHidden = false
        
        self.tutor = tutor
        profileImageView.sd_setImage(with: tutor.profilePicUrl, placeholderImage: #imageLiteral(resourceName: "registration-image-placeholder"))
        nameLabel.text = tutor.formattedName
        hourlyRateLabel.text = "$\(tutor.price ?? 5)/hr"
        
        if let rating = tutor.tRating, rating > 0 {
            ratingImageView.isHidden = false
            ratingCaptionLabel.isHidden = false
            ratingLabel.text = String(format: "%0.1f", rating)
        } else {
            ratingImageView.isHidden = true
            ratingCaptionLabel.isHidden = true
            
            if let experienceSubject = tutor.experienceSubject, let experiencePeriod = tutor.experiencePeriod, !experienceSubject.isEmpty {
                if experiencePeriod == 0.5 {
                    ratingLabel.text = "6 Months Experience in \(experienceSubject)"
                } else {
                    ratingLabel.text = "\(Int(experiencePeriod)) Years Experience in \(experienceSubject)"
                }
            } else if let address = tutor.region {
                ratingLabel.text = address
            }
        }
        
        if let featuredSubject = tutor.featuredSubject {
            var text = "Teaches "
            if let subjects = tutor.subjects {
                if subjects.count == 1 {
                    text += featuredSubject
                } else {
                    text += featuredSubject
                    let otherSubjects = subjects.filter({$0.compare(featuredSubject) != .orderedSame})
                    text += " & \(otherSubjects.count) other topics"
                }
                subjectsLabel.text = text
            }
        } else {
            if let subjects = tutor.subjects {
                var text = "Teaches "
                if subjects.count == 1 {
                    text += subjects.first!
                } else {
                    text += subjects.first! + " & \(subjects.count - 1) other topics"
                }
                subjectsLabel.text = text
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
}

class QTNewTutorLoadMoreTableViewCell: UITableViewCell {
    let loadingView: LOTAnimationView = {
        let lottieView = LOTAnimationView(name: "loading11")
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopAnimation = true
        return lottieView
    }()
    
    static var reuseIdentifier: String {
        return String(describing: QTNewTutorLoadMoreTableViewCell.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    func setupViews() {
        contentView.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalToSuperview()
        }
        
        contentView.backgroundColor = Colors.newScreenBackground
        backgroundColor = Colors.newScreenBackground
        loadingView.play()
    }
}
