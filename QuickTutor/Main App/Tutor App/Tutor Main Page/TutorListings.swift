//
//  TutorListings.swift
//  QuickTutor
//
//  Created by QuickTutor on 6/26/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit


class TutorListingsView : MainLayoutTitleOneButton {

	var backButton = NavbarButtonX()
	
	override var leftButton: NavbarButton {
		get {
			return backButton
		}
		set {
			backButton = newValue as! NavbarButtonX
		}
	}
	
    let titleLabel : UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.font = Fonts.createBoldSize(22)
        label.text = "Hitting the front page"
        
        return label
    }()
    
    let imageView : UIImageView = {
        let view = UIImageView()
        
        view.image = #imageLiteral(resourceName: "orange-gradient-person")
        
        return view
    }()
    
    let backgroundImageView : UIImageView = {
        let view = UIImageView()
        
        view.image = #imageLiteral(resourceName: "dark-pattern").alpha(0.6)
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    let bodyLabel : UILabel = {
        let label = UILabel()
        
        label.font = Fonts.createSize(14)
        label.textColor = .white
        label.numberOfLines = 0
        label.sizeToFit()
        label.text = "The QuickTutor marketplace is currently structured to ensure learners can find the best tutors and that active tutors receive learner leads with a high connection rate.\n\nBeing on the front page of the learner side of the app will highly increase your chances of receiving connection requests and earning money for tutoring.\n\nTo get featured on the front page you must have completed at least 10 hours of tutoring and consistently maintain a 4.7 rating.\n\nCurrently, we are working on building a tab for all tutors on the Tutor Menu which will allow you to customize how learners view your listing on the main feed.\n"
        
        return label
    }()
    
    let scrollView : UIScrollView = {
        let view = UIScrollView()
        
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        
        return view
    }()
    
    override func configureView() {
        addSubview(scrollView)
        addSubview(backgroundImageView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(imageView)
        scrollView.addSubview(bodyLabel)
        super.configureView()
        
        backButton.image.image = #imageLiteral(resourceName: "back-button")
        insertSubview(backgroundImageView, belowSubview: statusbarView)
        title.label.text = "Getting Featured"
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        
        backgroundImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.top.equalTo(navbar.snp.bottom)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(navbar.snp.bottom)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalToSuperview().inset(25)
            make.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).inset(-20)
        }
        
        bodyLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).inset(-25)
        }
    }
}

class TutorListings : BaseViewController {
    
    override var contentView: TutorListingsView {
        return view as! TutorListingsView
    }
    override func loadView() {
        view = TutorListingsView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.layoutIfNeeded()
        contentView.scrollView.contentSize = CGSize(width: 280, height: contentView.bodyLabel.frame.maxY)
    }
    override func handleNavigation() {
		if touchStartView is NavbarButtonX {
			contentView.backgroundImageView.isHidden = true
			self.navigationController?.popViewController(animated: true)
		}
    }
}
