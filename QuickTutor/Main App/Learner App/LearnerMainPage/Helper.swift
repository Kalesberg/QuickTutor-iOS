//
//  Helper.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class SectionHeader : BaseView {
	
	var category = UILabel()
	
	override func configureView() {
		addSubview(category)
		super.configureView()
		
		category.textAlignment = .left
		category.font = Fonts.createBoldSize(20)
		category.textColor = .white
		category.adjustsFontSizeToFitWidth = true
		
		applyConstraints()
	}
	
	override func applyConstraints() {
		category.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(15)
			make.centerY.equalToSuperview()
			make.height.equalToSuperview()
			make.width.equalToSuperview()
		}
	}
}

class FeaturedTutorView : BaseView {
	
	let imageView = UIImageView()
	let subject = UILabel()
	let region = UILabel()
	let namePrice = UILabel()
	let stars = UILabel()
	
	override func configureView() {
		addSubview(imageView)
		addSubview(subject)
		addSubview(region)
		addSubview(namePrice)
		addSubview(stars)
		
		super.configureView()
		
		backgroundColor = Colors.backgroundDark
		
		imageView.image = #imageLiteral(resourceName: "registration-image-placeholder")
		subject.textAlignment = .left
		subject.textColor = .white
		subject.text = "German Tutoring"
		subject.font = Fonts.createSize(17)
		subject.adjustsFontSizeToFitWidth = true
		
		region.textAlignment = .left
		region.textColor = .white
		region.text = "Wyandotte, MI"
		region.font = Fonts.createSize(14)
		region.adjustsFontSizeToFitWidth = true
		
		namePrice.textAlignment = .left
		namePrice.textColor = Colors.grayText
		namePrice.text = "Garry, M | $195/hr"
		namePrice.font = Fonts.createSize(14)
		namePrice.adjustsFontSizeToFitWidth = true
		
		stars.textAlignment = .left
		stars.textColor = Colors.grayText
		stars.text = "+ + + + + +"
		stars.font = Fonts.createSize(14)
		stars.adjustsFontSizeToFitWidth = true
		
		applyConstraints()
	}
	override func applyConstraints() {
		imageView.snp.makeConstraints { (make) in
			make.bottom.equalTo(subject.snp.top)
			make.centerX.equalToSuperview()
			make.height.equalToSuperview().dividedBy(2.5)
			make.width.equalToSuperview().multipliedBy(0.6)
		}
		stars.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.width.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.1)
			make.centerX.equalToSuperview()
		}
		namePrice.snp.makeConstraints { (make) in
			make.bottom.equalTo(stars.snp.top)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.1)
		}
		region.snp.makeConstraints { (make) in
			make.bottom.equalTo(namePrice.snp.top)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.1)
		}
		subject.snp.makeConstraints { (make) in
			make.bottom.equalTo(region.snp.top)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.1)
		}
	}
}


enum Category {
	
	case academics
	case arts
	case auto
	case business
	case experiences
	case health
	case language
	case outdoors
	case remedial
	case sports
	case tech
	case trades
	
	static let categories : [Category] = [.academics, .arts, .auto, .business, .experiences, .health, .language, .outdoors, .remedial, .sports, .tech, .trades]
	
	var subcategory : Subcategory {
		
		let searchBarPhrases : [String]
		let subcategories : [String]
		let icon : [UIImage]
		let displayName : String
		let fileToRead : String
		
		switch self {
		case .academics:				displayName = "ACADEMICS"
										searchBarPhrases = ["Enter Any 'Academic' Subject"]
										subcategories = ["Mathematics", "Language Arts", "History", "The Sciences", "Extracurricular","Test Preparation"]
										icon = [#imageLiteral(resourceName: "registration-add-image"),#imageLiteral(resourceName: "sidebar-payment"),#imageLiteral(resourceName: "yellow-star"),#imageLiteral(resourceName: "back-button"),#imageLiteral(resourceName: "fb-signin"),#imageLiteral(resourceName: "navbar-x")]
										fileToRead = "Academics"

		case .arts:						displayName = "THE ARTS"
										searchBarPhrases = ["Enter Any 'The Arts' Subject"]
										subcategories = ["Applied Arts", "Art History", "Performing Arts", "Arts Critism", "Visual Arts","Literary Arts"]
										icon = [#imageLiteral(resourceName: "registration-add-image"),#imageLiteral(resourceName: "sidebar-payment"),#imageLiteral(resourceName: "yellow-star"),#imageLiteral(resourceName: "navbar-search"),#imageLiteral(resourceName: "fb-signin"),#imageLiteral(resourceName: "navbar-x")]
										fileToRead = "arts"
			
		case .auto: 					displayName = "AUTO"
										searchBarPhrases = ["Enter Any 'Auto' Subject"]
										subcategories = ["Automobiles", "Motor vehicles", "Maintenance", "Repairs", "Upgrades","Design"]
										icon = [#imageLiteral(resourceName: "registration-add-image"),#imageLiteral(resourceName: "sidebar-payment"),#imageLiteral(resourceName: "yellow-star"),#imageLiteral(resourceName: "navbar-search"),#imageLiteral(resourceName: "fb-signin"),#imageLiteral(resourceName: "navbar-x")]
										fileToRead = "auto"
			
		case .business:					displayName = "BUSINESS"
										searchBarPhrases = ["Enter Any 'Business' Subject"]
										subcategories = ["Entrepreneurship", "Finance | Law", "Economics | Accounting", "Management", "Information Systems","Marketing | Hospitality"]
										icon = [#imageLiteral(resourceName: "registration-add-image"),#imageLiteral(resourceName: "sidebar-payment"),#imageLiteral(resourceName: "yellow-star"),#imageLiteral(resourceName: "navbar-search"),#imageLiteral(resourceName: "fb-signin"),#imageLiteral(resourceName: "navbar-x")]
										fileToRead = "business"
			
		case .experiences:				displayName = "EXPERIENCES"
										searchBarPhrases = ["Enter Any 'Experiences' Subject"]
										subcategories = ["Career", "Cooking | Baking", "Creations", "Motivation | Consulting", "Travel Destinations","Fitness"]
										icon = [#imageLiteral(resourceName: "registration-add-image"),#imageLiteral(resourceName: "sidebar-payment"),#imageLiteral(resourceName: "yellow-star"),#imageLiteral(resourceName: "navbar-search"),#imageLiteral(resourceName: "fb-signin"),#imageLiteral(resourceName: "navbar-x")]
										fileToRead = "experiences"
			
		case .health:					displayName = "HEALTH"
										searchBarPhrases = ["Enter Any 'Health' Subject"]
										subcategories = ["General", "Illness", "Medicines", "Nutrition", "Physical Exercise","Self Care"]
										icon = [#imageLiteral(resourceName: "registration-add-image"),#imageLiteral(resourceName: "sidebar-payment"),#imageLiteral(resourceName: "yellow-star"),#imageLiteral(resourceName: "navbar-search"),#imageLiteral(resourceName: "fb-signin"),#imageLiteral(resourceName: "navbar-x")]
										fileToRead = "health"
			
		case .language:					displayName = "LANGUAGE"
										searchBarPhrases = ["Enter Any 'Language' Subject"]
										subcategories = ["ESL", "Listening", "Reading", "Sign Language", "Speech","Writing"]
										icon = [#imageLiteral(resourceName: "registration-add-image"),#imageLiteral(resourceName: "sidebar-payment"),#imageLiteral(resourceName: "yellow-star"),#imageLiteral(resourceName: "navbar-search"),#imageLiteral(resourceName: "fb-signin"),#imageLiteral(resourceName: "navbar-x")]
										fileToRead = "language"
			
		case .outdoors: 				displayName = "OUTDOORS"
										searchBarPhrases = ["Enter Any 'Academic' Subject"]
										subcategories = ["Activities", "Land | Water", "Life Identification", "Survival", "Preparation", "Seasonal"]
										icon = [#imageLiteral(resourceName: "registration-add-image"),#imageLiteral(resourceName: "sidebar-payment"),#imageLiteral(resourceName: "yellow-star"),#imageLiteral(resourceName: "navbar-search"),#imageLiteral(resourceName: "fb-signin"),#imageLiteral(resourceName: "navbar-x")]
										fileToRead = "outdoors"
			
		case .remedial: 				displayName = "REMEDIAL"
										searchBarPhrases = ["Enter Any 'Academic Subject"]
										subcategories = ["Conditions", "Development", "Disabilities", "Impairments", "Injuries","Special Education"]
										icon = [#imageLiteral(resourceName: "registration-add-image"),#imageLiteral(resourceName: "sidebar-payment"),#imageLiteral(resourceName: "yellow-star"),#imageLiteral(resourceName: "navbar-search"),#imageLiteral(resourceName: "fb-signin"),#imageLiteral(resourceName: "navbar-x")]
										fileToRead = "remedial"
			
		case .sports: 					displayName = "SPORTS"
										searchBarPhrases = ["Enter Any 'Academic Subject"]
										subcategories = ["E-Sports", "Extreme Sports", "Fantasy Sports", "Mind Sports", "Physical Sports","Skills Training"]
										icon = [#imageLiteral(resourceName: "registration-add-image"),#imageLiteral(resourceName: "sidebar-payment"),#imageLiteral(resourceName: "yellow-star"),#imageLiteral(resourceName: "navbar-search"),#imageLiteral(resourceName: "fb-signin"),#imageLiteral(resourceName: "navbar-x")]
										fileToRead = "sports"
			
		case .tech:						displayName = "TECH"
										searchBarPhrases = ["Enter Any 'Academic Subject"]
										subcategories = ["Gaming", "Hardware", "IT", "Programming", "Repairs", "Software"]
										icon = [#imageLiteral(resourceName: "registration-add-image"),#imageLiteral(resourceName: "sidebar-payment"),#imageLiteral(resourceName: "yellow-star"),#imageLiteral(resourceName: "navbar-search"),#imageLiteral(resourceName: "fb-signin"),#imageLiteral(resourceName: "navbar-x")]
										fileToRead = "tech"
			
		case .trades:					displayName = "TRADES"
										searchBarPhrases = ["Enter Any 'Academic Subject"]
										subcategories = ["Construction", "General", "Home", "Industrial", "Motive Power", "Services"]
										icon = [#imageLiteral(resourceName: "registration-add-image"),#imageLiteral(resourceName: "sidebar-payment"),#imageLiteral(resourceName: "yellow-star"),#imageLiteral(resourceName: "navbar-search"),#imageLiteral(resourceName: "fb-signin"),#imageLiteral(resourceName: "navbar-x")]
										fileToRead = "trades"
		}
		
		return Subcategory(subcategories: subcategories, icon: icon, phrase: searchBarPhrases[Int(arc4random_uniform(UInt32(searchBarPhrases.count)))], displayName: displayName, fileToRead: fileToRead)
	}
	
	var mainPageData : MainPageData {
		let displayName : String
		let image : UIImage
		
		switch self {
		case .academics:				displayName = "Academics"
										image = #imageLiteral(resourceName: "academics")
			
		case .arts:						displayName = "The Arts"
										image = #imageLiteral(resourceName: "arts")
		case .auto: 					displayName = "Auto"
										image = #imageLiteral(resourceName: "auto")
			
		case .business:					displayName = "Business"
										image = #imageLiteral(resourceName: "business")
			
		case .experiences:				displayName = "Experiences"
										image = #imageLiteral(resourceName: "experiences")
			
		case .health:					displayName = "Health"
										image = #imageLiteral(resourceName: "health")
		case .language:					displayName = "Language"
										image = #imageLiteral(resourceName: "languages")
			
		case .outdoors: 				displayName = "Outdoors"
										image = #imageLiteral(resourceName: "outdoors")
			
		case .remedial: 				displayName = "Remedial"
										image = #imageLiteral(resourceName: "remedial")
			
		case .sports: 					displayName = "Sports"
										image = #imageLiteral(resourceName: "sports")
			
		case .tech:						displayName = "Tech"
										image = #imageLiteral(resourceName: "tech")
		case .trades:					displayName = "Trades"
										image = #imageLiteral(resourceName: "trades")
		}
		return MainPageData(displayName: displayName, image: image)
	}
}

extension Category {
	
	struct MainPageData {
		let displayName : String
		let image : UIImage
	}
	
	struct Subcategory {
		let subcategories : [String]
		let icon : [UIImage]
		let phrase : String
		let displayName : String
		let fileToRead : String
	}
}
