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
			make.centerY.equalToSuperview().inset(5)
			make.height.equalToSuperview()
			make.width.equalToSuperview()
		}
	}
}

class FeaturedTutorView : BaseView {
	
	let imageView  : UIImageView = {
		let imageView = UIImageView()
		
		imageView.image = #imageLiteral(resourceName: "registration-image-placeholder")
		imageView.scaleImage()
		imageView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.6, offset: CGSize(width: 3, height: 2), radius: 5)
		
		return imageView
	}()
	
	let subject : UILabel = {
		let label = UILabel()
		
		label.textAlignment = .left
		label.textColor = .white
		label.font = Fonts.createSize(17)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let region : UILabel = {
		let label = UILabel()
		
		label.textAlignment = .left
		label.textColor = Colors.grayText
		label.font = Fonts.createSize(13)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let namePrice : UILabel = {
		let label = UILabel()
		
		label.textAlignment = .left
		label.textColor = Colors.grayText
		label.font = Fonts.createSize(13)
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	let ratingLabel : UILabel = {
        let label = UILabel()
		
		label.textAlignment = .left
		label.textColor = Colors.yellow
		label.font = Fonts.createSize(14)
		label.adjustsFontSizeToFitWidth = true
        label.text = "4.4"
        
		return label
	}()
    
    let starImage : UIImageView = {
        let view = UIImageView()
        
        view.image = #imageLiteral(resourceName: "yellow-star")
        view.scaleImage()
        
        return view
    }()
	
	override func configureView() {
		addSubview(imageView)
		addSubview(subject)
		addSubview(region)
		addSubview(namePrice)
		addSubview(ratingLabel)
        addSubview(starImage)
		super.configureView()
		
		backgroundColor = Colors.backgroundDark
		
		applyConstraints()
	}
    
	override func applyConstraints() {
		imageView.snp.makeConstraints { (make) in
			make.top.equalToSuperview().inset(14)
			make.centerX.equalToSuperview()
			make.height.equalToSuperview().multipliedBy(0.47)
			make.width.equalToSuperview().multipliedBy(0.77)
		}
		subject.snp.makeConstraints { (make) in
			make.top.equalTo(imageView.snp.bottom).inset(-2)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.92)
		}
		region.snp.makeConstraints { (make) in
			make.top.equalTo(subject.snp.bottom).inset(-2)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.92)
		}
		namePrice.snp.makeConstraints { (make) in
			make.top.equalTo(region.snp.bottom)
			make.centerX.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.92)
		}
        starImage.snp.makeConstraints { (make) in
            make.left.equalTo(namePrice)
            make.top.equalTo(namePrice.snp.bottom).inset(-2)
            make.height.equalTo(14)
        }
        ratingLabel.snp.makeConstraints { (make) in
            make.left.equalTo(starImage.snp.right).inset(-3)
            make.centerY.equalTo(starImage).inset(1)
        }
	}
}
struct BadWords {
	static func loadBadWords() -> [String] {
		do {
			guard let file = Bundle.main.url(forResource: "badwords", withExtension: "json") else { return [] }
			let data = try Data(contentsOf: file)
			let json = try JSONSerialization.jsonObject(with: data, options: [])
			
			guard let object = json as? [String : [String]] else { return [] }
			guard let words = object["badwords"] else { return [] }
			
			return words
		} catch {
			return []
		}
	}
}

struct SubjectStore {

	static func loadTotalSubjectList() -> [(String, String)]? {
		
		var totalSubjects : [(String, String)] = []
		
		for i in 0..<category.count {
			do {
				guard let file = Bundle.main.url(forResource: category[i].subcategory.fileToRead, withExtension: "json") else {
					continue }
				let data = try Data(contentsOf: file)
				let json = try JSONSerialization.jsonObject(with: data, options: [])
				
				for key in category[i].subcategory.subcategories {
					guard let object = json as? [String : [String]] else { continue }
					guard let subjectArray = object[key] else { continue }
			
					for subject in subjectArray {
						totalSubjects.append((subject, key))
					}
				}
			} catch {
				return nil
			}
		}
		return totalSubjects
	}
	
	static func readSubcategory(resource: String, subjectString: String) -> [(String, String)]? {
		
		var subjects : [(String, String)] = []
		
		do {
			guard let file = Bundle.main.url(forResource: resource.lowercased(), withExtension: "json") else { return nil }
			
			let data = try Data(contentsOf: file)
			
			let json = try JSONSerialization.jsonObject(with: data, options: [])
			
			guard let object = json as? [String : [String]] else { return nil }
			
			guard let subjectArray = object[subjectString] else { return nil }
			
			for subject in subjectArray {
				subjects.append((subject, subjectString))
			}
		} catch {
			return nil
		}
		return subjects
	}
	
	static func readCategory(resource: String) -> [(String, String)]? {
		
		var subjects : [(String, String)] = []

		do {
			guard let file =  Bundle.main.url(forResource: resource.lowercased(), withExtension: "json") else { return [] }
			
			let data = try Data(contentsOf: file)
			
			let json = try JSONSerialization.jsonObject(with: data, options: [])
			
			for key in Category.category(for: resource)!.subcategory.subcategories {
				
				guard let object = json as? [String : [String]] else { continue }
				
				guard let subjectArray = object[key] else { continue }
				
				for subject in subjectArray {
					subjects.append((subject, resource))
				}
			}
		} catch {
			return []
		}
		return subjects
	}
	
	static func findSubcategoryImage(subcategory: String) -> (String, UIImage) {
		
		for i in 0..<category.count {
			for key in category[i].subcategory.subcategories {
				if key.lowercased() == subcategory {

					let subcategories = category[i].subcategory.subcategories.map { $0.lowercased()}
					
					let indexOfImage = subcategories.index(of: key.lowercased())
					let image = category[i].subcategory.icon[indexOfImage!]
					
					let indexOfSubcategory = subcategories.index(of: key.lowercased())
					let subcategory = category[i].subcategory.subcategories[indexOfSubcategory!]
					
					return (subcategory, image)
				}
			}
		}
		return ("No top subject.", #imageLiteral(resourceName: "defaultProfileImage"))
	}
	
	static func findSubCategory(resource: String, subject: String) -> String? {
		do {
			guard let file = Bundle.main.url(forResource: resource.lowercased(), withExtension: "json") else { return nil }
			
			let data = try Data(contentsOf: file)
			
			let json = try JSONSerialization.jsonObject(with: data, options: [])
			
			for key in Category.category(for: resource)!.subcategory.subcategories {
				
				guard let object = json as? [String : [String]] else { continue }
				
				guard let subjectArray = object[key] else { continue }
				
				if subjectArray.contains(subject) {
					return key
				}
			}
		} catch {
			return nil
		}
		return nil
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
			
		case .academics:                displayName = "ACADEMICS"
		searchBarPhrases = ["search any academic subject"]
		subcategories = ["Mathematics", "Language Arts", "Social Studies", "The Sciences", "Extracurricular","Test Preparation"]
		icon = [#imageLiteral(resourceName: "mathematics"),#imageLiteral(resourceName: "language-arts"),#imageLiteral(resourceName: "social-studies"),#imageLiteral(resourceName: "science"),#imageLiteral(resourceName: "extracurricular"),#imageLiteral(resourceName: "test-prep")]
		fileToRead = "academics"
			
		case .arts:                        displayName = "THE ARTS"
		searchBarPhrases = ["search for any art"]
		subcategories = ["Literary Arts", "Visual Arts", "Performing Arts", "Art History", "Applied Arts", "Arts Criticism"]
		icon = [#imageLiteral(resourceName: "literacy"),#imageLiteral(resourceName: "visual-arts"),#imageLiteral(resourceName: "performing"),#imageLiteral(resourceName: "history"),#imageLiteral(resourceName: "applied-arts"),#imageLiteral(resourceName: "art-criticism")]
		fileToRead = "arts"
			
		case .auto:                     displayName = "AUTO"
		searchBarPhrases = ["search anything auto-related"]
		subcategories = ["Automobiles", "Motor Vehicles", "Maintenance", "Repairs", "Upgrades", "Design"]
		icon = [#imageLiteral(resourceName: "automobiles"),#imageLiteral(resourceName: "motor-vehicles"),#imageLiteral(resourceName: "maintenance"),#imageLiteral(resourceName: "repairs"),#imageLiteral(resourceName: "upgrades"),#imageLiteral(resourceName: "design")]
		fileToRead = "auto"
			
		case .business:                    displayName = "BUSINESS"
		searchBarPhrases = ["search any business topic"]
		subcategories = ["Entrepreneurship", "Finance & Law", "Economics & Accounting", "Business Management", "Information Systems","Marketing & Hospitality"]
		icon = [#imageLiteral(resourceName: "entrepreneurship"),#imageLiteral(resourceName: "finance-law"),#imageLiteral(resourceName: "economics-accounting"),#imageLiteral(resourceName: "management"),#imageLiteral(resourceName: "information-systems"),#imageLiteral(resourceName: "marketing-hospitality")]
		fileToRead = "business"
			
		case .experiences:                displayName = "EXPERIENCES"
		searchBarPhrases = ["search for any experience"]
		subcategories = ["Motivation/Consulting", "Creations", "Cooking & Baking","Fitness", "Travel Destinations","Careers"]
		icon = [#imageLiteral(resourceName: "motivation"),#imageLiteral(resourceName: "life_lessons"),#imageLiteral(resourceName: "cooking-baking"),#imageLiteral(resourceName: "fitness"),#imageLiteral(resourceName: "travel-destinations"),#imageLiteral(resourceName: "volunteering")]
		fileToRead = "experiences"
			
		case .health:                    displayName = "HEALTH"
		searchBarPhrases = ["search health and wellness"]
		subcategories = ["General", "Self-Care", "Nutrition", "Medicines", "Physical Exercise","Illness"]
		icon = [#imageLiteral(resourceName: "general-health"),#imageLiteral(resourceName: "selfcare"),#imageLiteral(resourceName: "nutrition"),#imageLiteral(resourceName: "medicine"),#imageLiteral(resourceName: "physical-excercise"),#imageLiteral(resourceName: "illness")]
		fileToRead = "health"
			
		case .language:                    displayName = "LANGUAGE"
		searchBarPhrases = ["search for any language skill"]
		subcategories = ["ESL", "Listening", "Reading", "Sign Language", "Speech","Writing"]
		icon = [#imageLiteral(resourceName: "esl"),#imageLiteral(resourceName: "listening"),#imageLiteral(resourceName: "reading"),#imageLiteral(resourceName: "sign-language"),#imageLiteral(resourceName: "speech"),#imageLiteral(resourceName: "writing")]
		fileToRead = "language"
			
		case .outdoors:                 displayName = "OUTDOORS"
		searchBarPhrases = ["discover the outdoors"]
		subcategories = ["Survival", "Life Identification", "Preparation", "Activities", "Land & Water","Seasonal"]
		icon = [#imageLiteral(resourceName: "survival"),#imageLiteral(resourceName: "life-identity"),#imageLiteral(resourceName: "preperation"),#imageLiteral(resourceName: "activities"),#imageLiteral(resourceName: "land-water"),#imageLiteral(resourceName: "seasonal")]
		fileToRead = "outdoors"
			
		case .remedial:                 displayName = "REMEDIAL"
		searchBarPhrases = ["search for help in anything"]
		subcategories = ["Development", "Conditions", "Impairments", "Disabilities", "Injuries","Special Education"]
		icon = [#imageLiteral(resourceName: "development"),#imageLiteral(resourceName: "conditions"),#imageLiteral(resourceName: "disabilities"),#imageLiteral(resourceName: "impairments"),#imageLiteral(resourceName: "injuries"),#imageLiteral(resourceName: "special-education")]
		fileToRead = "remedial"
			
		case .sports:                     displayName = "SPORTS"
		searchBarPhrases = ["search sports and games"]
		subcategories = ["Physical Sports", "Mind Sports", "Skills Training", "E-Sports", "Fantasy Sports","Extreme Sports"]
		icon = [#imageLiteral(resourceName: "physical-sports"),#imageLiteral(resourceName: "mind-sports"),#imageLiteral(resourceName: "skill-training"),#imageLiteral(resourceName: "esports"),#imageLiteral(resourceName: "fantasy-sports"),#imageLiteral(resourceName: "extreme-sports")]
		fileToRead = "sports"
			
		case .tech:                        displayName = "TECH"
		searchBarPhrases = ["search technological topics"]
		subcategories = ["Programming", "Gaming", "Hardware", "Software", "IT", "Repairs"]
		icon = [#imageLiteral(resourceName: "programming"),#imageLiteral(resourceName: "gaming"),#imageLiteral(resourceName: "hardware"),#imageLiteral(resourceName: "software"),#imageLiteral(resourceName: "it"),#imageLiteral(resourceName: "repairs")]
		fileToRead = "tech"
			
		case .trades:                    displayName = "TRADES"
		searchBarPhrases = ["search for any trade"]
		subcategories = ["Construction", "Industrial", "Motive Power", "Services", "Home", "General"]
		icon = [#imageLiteral(resourceName: "construction"),#imageLiteral(resourceName: "industry"),#imageLiteral(resourceName: "motive-power"),#imageLiteral(resourceName: "services"),#imageLiteral(resourceName: "home"),#imageLiteral(resourceName: "general")]
		fileToRead = "trades"
		}
		
		return Subcategory(subcategories: subcategories, icon: icon, phrase: searchBarPhrases[Int(arc4random_uniform(UInt32(searchBarPhrases.count)))], displayName: displayName, fileToRead: fileToRead)
	}
	
	var mainPageData : MainPageData {
		
		let displayName : String
		let image : UIImage
		let categoryInfo : String
		
		switch self {
		case .academics:                displayName = "Academics"
		image = #imageLiteral(resourceName: "academics")
		categoryInfo = "The classics. Whether you’re a master of mechanical engineering or a math wiz — we have a subject you can tutor. These are the core subjects that have been around since the beginning of time."
			
		case .arts:                        displayName = "The Arts"
		image = #imageLiteral(resourceName: "arts")
		categoryInfo = "Does the renaissance sing out of your soul? Whether your a dancer, singer or poet — you now have the ability to tutor others in poetry, drama, painting or phantom of the opera — this is where we get the creative juices flowin’."
			
		case .auto:                     displayName = "Auto"
		image = #imageLiteral(resourceName: "auto")
		categoryInfo = "Interested in teaching others a thing or two about being a gear-head? Are you a skilled repairman or designer? In this category you’ll be able to teach others anything about auto or just make some side cash fixing stuff! "
			
		case .business:                    displayName = "Business"
		image = #imageLiteral(resourceName: "business")
		categoryInfo = "Are you an entrepreneur, lawyer, accountant, marketer, or economist? Maybe the neighborhood excel expert? Lets talk business. "
			
		case .experiences:                displayName = "Experiences"
		image = #imageLiteral(resourceName: "experiences")
		categoryInfo = "The smell of baked lasagna coming out of the oven, the feel of clay between one’s fingers — music, yoga, travel, arts & crafts, and motivation are all found here. Experiences is where all can tutor the things that warm our hearts and drive our souls."
			
		case .health:                    displayName = "Health & Wellness"
		image = #imageLiteral(resourceName: "health")
		categoryInfo = "Ever been told you’re a health nut? Well, whether you’re a doctor, dentist, gym-rat, nutritionist, or fitness model — you can tutor any subject in our health & wellness category."
			
		case .language:                    displayName = "Language"
		image = #imageLiteral(resourceName: "languages")
		categoryInfo = "Run a tutoring business teaching others your native language or even a language you’ve adopted! Nearly every language in existence — available to tutor with just the tap of a button."
			
		case .outdoors:                 displayName = "Outdoors"
		image = #imageLiteral(resourceName: "outdoors")
		categoryInfo = "Tutors, it’s time to take your learners outside of the classroom and office. Are you a survivalist? Expert in your neck of the woods? Dad of the year? If so, this is the category for you. "
			
		case .remedial:                 displayName = "Remedial"
		image = #imageLiteral(resourceName: "remedial")
		categoryInfo = "QuickTutor is for everyone. Remedial is provided and intended for learners who experience difficulties."
			
		case .sports:                     displayName = "Sports & Games"
		image = #imageLiteral(resourceName: "sports")
		categoryInfo = "Snowboarding, football, chess, fantasy sports, or skydiving — The Sports & Games category is where competitive adrenaline junkies and gamers thrive. Tutor anything."
			
		case .tech:                        displayName = "Tech"
		image = #imageLiteral(resourceName: "tech")
		categoryInfo = "Programmers, engineers, gamers, and the creators of the future, come all — here’s where you can share your passion and knowledge with those in need. "
			
		case .trades:                    displayName = "Trades"
		image = #imageLiteral(resourceName: "trades")
		categoryInfo = "Time to become a hands-on tutor in construction, industrial, motive-power, services, home, or anything! Turn your everyday skills into a tutoring business."
		}
		return MainPageData(displayName: displayName, image: image, categoryInfo: categoryInfo)
	}
	static func category(for string: String) -> Category? {
		
		switch string {
			
		case "academics":
			return .academics
		case "arts":
			return .arts
		case "auto":
			return .auto
		case "business":
			return .business
		case "experiences":
			return .experiences
		case "health":
			return .health
		case "language":
			return .language
		case "outdoors":
			return .outdoors
		case "remedial":
			return .remedial
		case "sports":
			return .sports
		case "tech":
			return .tech
		case "trades":
			return .trades
		default:
			return nil
		}
	}
}

extension Category {
	
	struct MainPageData {
		let displayName : String
		let image : UIImage
		let categoryInfo : String
	}
	
	struct Subcategory {
		let subcategories : [String]
		let icon : [UIImage]
		let phrase : String
		let displayName : String
		let fileToRead : String
	}
}
