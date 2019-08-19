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
        iv.layer.cornerRadius = 22
        
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createBoldSize(14)
        label.textColor = UIColor.white
        label.isSkeletonable = true
        label.linesCornerRadius = 4
        
        return label
    }()
    
    let hourlyRateLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(14)
        label.textColor = .white
        label.isSkeletonable = true
        label.linesCornerRadius = 4
        
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        
        return stackView
    }()
    
    let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(12)
        label.textColor = Colors.purple
        label.isSkeletonable = true
        label.linesCornerRadius = 4
        
        return label
    }()
    
    let ratingImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "ic_star_filled")
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    let ratingCaptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createSize(12)
        label.textColor = Colors.purple
        label.text = "Rating"
        
        return label
    }()
    
    let subjectsLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.createMediumSize(12)
        label.textColor = .white
        label.numberOfLines = 0
        
        return label
    }()
    
    func setupProfileImageView() {
        contentView.addSubview(profileImageView)
        
        profileImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, paddingTop: 22, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 44, height: 44)
    }
    
    func setupNameLabel() {
        contentView.addSubview(nameLabel)
        
        nameLabel.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func setupHorlyRateLabel() {
        contentView.addSubview(hourlyRateLabel)
        
        hourlyRateLabel.anchor(top: profileImageView.topAnchor, left: nameLabel.rightAnchor, bottom: nil, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    func setupStackView() {
        contentView.addSubview(stackView)
        
        stackView.anchor(top: nameLabel.bottomAnchor, left: nameLabel.leftAnchor, bottom: nil, right: nil, paddingTop: 7, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        stackView.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -20).isActive = true
    }
    
    func setupRatingLabel() {
        stackView.addArrangedSubview(ratingLabel)
    }
    
    func setupRatingImageView() {
        stackView.addArrangedSubview(ratingImageView)
        
        ratingImageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
        ratingImageView.heightAnchor.constraint(equalToConstant: 12).isActive = true
    }
    
    func setupRatingCaptionLabel() {
        stackView.addArrangedSubview(ratingCaptionLabel)
    }
    
    func setupSubjectsLabel() {
        contentView.addSubview(subjectsLabel)
        
        subjectsLabel.anchor(top: stackView.bottomAnchor, left: nameLabel.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 7, paddingLeft: 0, paddingBottom: 20, paddingRight: 20, width: 0, height: 0)
    }
    
    func setupViews() {
        contentView.backgroundColor = Colors.newScreenBackground
        backgroundColor = Colors.newScreenBackground
        
        setupProfileImageView()
        setupNameLabel()
        setupHorlyRateLabel()
        setupStackView()
        setupRatingLabel()
        setupRatingImageView()
        setupRatingCaptionLabel()
        setupSubjectsLabel()
        
        isSkeletonable = true
    }
    
    func updateUI(_ tutor: AWTutor) {
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
        
        if let subjects = tutor.subjects {
            var text = "Teaches "
            if subjects.count == 1 {
                text += subjects.first!
            } else if subjects.count == 2 {
                text += subjects.first! + " & " + subjects.last!
            } else if subjects.count > 2 {
                text += subjects.first! + ", " + subjects[1] + " & \(subjects.count - 2) other topics"
            }
            
            subjectsLabel.text = text
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
