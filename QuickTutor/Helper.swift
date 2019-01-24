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

class CategorySearchSectionHeader: SectionHeader {
    override func applyConstraints() {
        category.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
}

class SectionHeader: UICollectionReusableView {
    
    var category: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = Fonts.createBoldSize(20)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    func configureView() {
        addSubview(category)        
        applyConstraints()
    }
    
    func applyConstraints() {
        category.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.centerY.equalToSuperview().inset(5)
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        applyConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FeaturedTutorView: UIView {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}
	
    let imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let subject: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = Fonts.createBoldSize(14)
        return label
    }()
    
    let region: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = Colors.grayText
        label.font = Fonts.createSize(12)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let namePrice: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = Colors.grayText
        label.font = Fonts.createSize(12)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let ratingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = Colors.gold
        label.font = Fonts.createSize(14)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let starImage: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "gold-star")
        view.scaleImage()
        return view
    }()
    
    let numOfRatingsLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gold
        label.font = Fonts.createSize(14)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
	func configureView() {
        addSubview(imageView)
        addSubview(subject)
        addSubview(region)
        addSubview(namePrice)
        addSubview(ratingLabel)
        addSubview(starImage)
        addSubview(numOfRatingsLabel)
		
        applyConstraints()
    }

	func applyConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.centerX.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.55)
        }
        subject.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).inset(-7)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.88)
        }
        region.snp.makeConstraints { make in
            make.top.equalTo(subject.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.88)
        }
        namePrice.snp.makeConstraints { make in
            make.top.equalTo(region.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.88)
        }
        ratingLabel.snp.makeConstraints { make in
            make.left.equalTo(namePrice.snp.left)
            make.bottom.equalToSuperview().inset(9)
        }
        starImage.snp.makeConstraints { make in
            make.left.equalTo(ratingLabel.snp.right).inset(-1)
            make.centerY.equalTo(ratingLabel.snp.centerY)
            make.height.width.equalTo(13)
        }
        numOfRatingsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(ratingLabel).inset(-1)
            make.left.equalTo(starImage.snp.right).inset(-3)
        }
    }
	override func layoutSubviews() {
		super.layoutSubviews()
		imageView.roundCorners([.topRight, .topLeft], radius: 6)
	}
}

struct SubjectStore {
    static func loadTotalSubjectList() -> [(String, String)]? {
        var totalSubjects: [(String, String)] = []
        for i in 0..<categories.count {
            do {
                guard let file = Bundle.main.url(forResource: categories[i].subcategory.fileToRead, withExtension: "json") else {
                    continue }
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                for key in categories[i].subcategory.subcategories {
                    guard let object = json as? [String: [String]], let subjectArray = object[key.title] else { continue }
					
                    for subject in subjectArray {
                        totalSubjects.append((subject, key.title))
                    }
                }
            } catch {
                return nil
            }
        }
        return totalSubjects
    }
    
    static func readSubcategory(resource: String, subjectString: String) -> [(String, String)]? {
        var subjects: [(String, String)] = []
        
        do {
            guard let file = Bundle.main.url(forResource: resource.lowercased(), withExtension: "json") else { return nil }
            
            let data = try Data(contentsOf: file)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let object = json as? [String: [String]], let subjectArray = object[subjectString] else { return nil }
			
            for subject in subjectArray {
                subjects.append((subject, subjectString))
            }
        } catch {
            return nil
        }
        return subjects
    }
    
    static func loadCategory(resource: String) -> [(String, String)]? {
        
        var subjects: [(String, String)] = []
        
        do {
            guard let file = Bundle.main.url(forResource: resource.lowercased(), withExtension: "json") else { return [] }
            
            let data = try Data(contentsOf: file)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
			
			for key in Category.category(for: resource)!.subcategory.subcategories {
                guard let object = json as? [String: [String]], let subjectArray = object[key.title] else { continue }
				
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
        for i in 0..<categories.count {
            for key in categories[i].subcategory.subcategories {
                if key.title.lowercased() == subcategory {
                    
                    let subcategories = categories[i].subcategory.subcategories.map { $0.title.lowercased() }
                    
                    let indexOfImage = subcategories.index(of: key.title.lowercased())
                    let image = categories[i].subcategory.subcategories[indexOfImage!].icon
                    
                    let indexOfSubcategory = subcategories.index(of: key.title.lowercased())
                    let subcategory = categories[i].subcategory.subcategories[indexOfSubcategory!].title
                    
                    return (subcategory, image)
                }
            }
        }
        return ("No top subject.", #imageLiteral(resourceName: "defaultProfileImage"))
    }
    
    static func findCategoryBy(subcategory: String) -> String? {
        for category in categories {
            let lowercased = category.subcategory.subcategories.map({ $0.title.lowercased() })
            if lowercased.contains(subcategory) {
                return category.subcategory.fileToRead
            }
        }
        return nil
    }
    
    static func findCategoryBy(subject: String) -> String? {
        for i in 0..<categories.count {
            do {
                guard let file = Bundle.main.url(forResource: categories[i].subcategory.fileToRead, withExtension: "json") else {
                    continue }
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                for key in categories[i].subcategory.subcategories {
                    guard let object = json as? [String: [String]], let subjectArray = object[key.title] else { continue }
                    for value in subjectArray {
                        if subject == value {
                            return categories[i].subcategory.fileToRead
                        }
                    }
                }
            } catch {
                return nil
            }
        }
        return nil
    }
    static func findSubCategory(resource: String, subject: String) -> String? {
        do {
            guard let file = Bundle.main.url(forResource: resource.lowercased(), withExtension: "json") else { return nil }
            
            let data = try Data(contentsOf: file)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            for key in Category.category(for: resource)!.subcategory.subcategories {
                guard let object = json as? [String: [String]], let subjectArray = object[key.title] else { continue }
				
                if subjectArray.contains(subject) {
                    return key.title
                }
            }
        } catch {
            return nil
        }
        return nil
    }

}

let categoryIcons = [UIImage(named: "academicsIcon"), UIImage(named: "businessIcon"), UIImage(named: "lifestyleIcon"), UIImage(named: "languageIcon"), UIImage(named: "artsIcon"), UIImage(named: "sportsIcon"), UIImage(named: "healthIcon"), UIImage(named: "techIcon"), UIImage(named: "outdoorsIcon"), UIImage(named: "autoIcon"), UIImage(named: "tradesIcon"), UIImage(named: "remedialIcon")]

enum Category {
    
    case academics, arts, auto, business, lifestyle, health, language, outdoors, remedial, sports, tech, trades
    static let categories: [Category] = [.academics, .business, .lifestyle, .language,  .arts,  .sports, .health, .tech, .outdoors, .auto, .trades,  .remedial]
    
    var subcategory: Subcategory {
        
        let searchBarPhrases: [String]
		let subcategories: [(title: String, icon: UIImage)]
        let fileToRead: String
        
        switch self {
            
        case .academics:
            searchBarPhrases = ["search any academic subject"]
			subcategories = [(title: "Extracurricular", icon: #imageLiteral(resourceName: "extracurricular")),
							 (title: "Language Arts", icon: #imageLiteral(resourceName: "language-arts")),
							 (title: "Mathematics", icon: #imageLiteral(resourceName: "mathematics")),
							 (title: "Social Studies", icon:  #imageLiteral(resourceName: "social-studies")),
							 (title: "Test Prep", icon: #imageLiteral(resourceName: "test-prep")),
							 (title: "The Sciences", icon: #imageLiteral(resourceName: "science"))]
		fileToRead = "academics"
            
        case .arts:
            searchBarPhrases = ["search for any art"]
			subcategories = [(title: "Applied Arts", icon: #imageLiteral(resourceName: "applied-arts")),
							 (title: "Art Criticism", icon: #imageLiteral(resourceName: "art-criticism")),
							 (title: "Art History", icon: #imageLiteral(resourceName: "history")),
							 (title: "Literary Arts", icon: #imageLiteral(resourceName: "literacy")),
							 (title: "Performing Arts", icon: #imageLiteral(resourceName: "performing")),
							 (title: "Visual Arts", icon: #imageLiteral(resourceName: "visual-arts"))]
            fileToRead = "arts"
            
        case .auto:
            searchBarPhrases = ["search anything auto-related"]
			subcategories = [(title: "Auto Design", icon: #imageLiteral(resourceName: "design")),
							 (title: "Auto Repairs", icon: #imageLiteral(resourceName: "repairs")),
							 (title: "Auto Upgrades", icon: #imageLiteral(resourceName: "upgrades")),
							 (title: "Automobiles", icon: #imageLiteral(resourceName: "automobiles")),
							 (title: "Motor Vehicles", icon: #imageLiteral(resourceName: "motor-vehicles")),
							 (title: "Vehicle Maintenance", icon: #imageLiteral(resourceName: "maintenance"))]
            fileToRead = "auto"
            
        case .business:
            searchBarPhrases = ["search any business topic"]
			subcategories = [(title: "Business Management", icon: #imageLiteral(resourceName: "management")),
							 (title: "Economics & Accounting", icon: #imageLiteral(resourceName: "economics-accounting")),
							 (title: "Entrepreneurship", icon: #imageLiteral(resourceName: "entrepreneurship")),
							 (title: "Finance & Law", icon: #imageLiteral(resourceName: "finance-law")),
							 (title: "Information Systems", icon: #imageLiteral(resourceName: "information-systems")),
							 (title: "Marketing & Hospitality", icon: #imageLiteral(resourceName: "marketing-hospitality"))]
            fileToRead = "business"
            
        case .lifestyle:
            searchBarPhrases = ["search for any lifestyle"]
			subcategories = [(title: "Careers", icon: #imageLiteral(resourceName: "volunteering")),
							 (title: "Cooking & Baking", icon: #imageLiteral(resourceName: "cooking-baking")),
							 (title: "Creations", icon: #imageLiteral(resourceName: "life_lessons")),
							 (title: "Fitness", icon: #imageLiteral(resourceName: "fitness")),
							 (title: "Motivation & Consulting", icon: #imageLiteral(resourceName: "motivation")),
							 (title: "Travel Destinations", icon: #imageLiteral(resourceName: "travel-destinations"))]
            fileToRead = "lifestyle"
            
        case .health:
            searchBarPhrases = ["search health and wellness"]
			subcategories = [(title: "General Health", icon: #imageLiteral(resourceName: "general-health")),
							 (title: "Illness", icon: #imageLiteral(resourceName: "illness")),
							 (title: "Medicine", icon: #imageLiteral(resourceName: "medicine")),
							 (title: "Nutrition", icon: #imageLiteral(resourceName: "nutrition")),
							 (title: "Physical Exercise", icon: #imageLiteral(resourceName: "physical-excercise")),
							 (title: "Self-Care", icon: #imageLiteral(resourceName: "selfcare"))]
            fileToRead = "health"
            
		case .language:
            searchBarPhrases = ["search for any language skill"]
			subcategories = [(title: "ESL", icon: #imageLiteral(resourceName: "esl")),
							 (title: "Listening", icon: #imageLiteral(resourceName: "listening")),
							 (title: "Reading", icon: #imageLiteral(resourceName: "reading")),
							 (title: "Sign Language", icon: #imageLiteral(resourceName: "sign-language")),
							 (title: "Speaking", icon: #imageLiteral(resourceName: "speech")),
							 (title: "Writing", icon: #imageLiteral(resourceName: "writing"))]
            fileToRead = "language"
            
        case .outdoors:
            searchBarPhrases = ["discover the outdoors"]
			subcategories = [(title: "Land & Water", icon: #imageLiteral(resourceName: "land-water")),
							 (title: "Life Identification", icon: #imageLiteral(resourceName: "life-identity")),
							 (title: "Outdoor Activities", icon: #imageLiteral(resourceName: "activities")),
							 (title: "Outdoors Prep", icon: #imageLiteral(resourceName: "preperation")),
							 (title: "Seasonal", icon: #imageLiteral(resourceName: "seasonal")),
							 (title: "Survival", icon: #imageLiteral(resourceName: "survival"))]
            fileToRead = "outdoors"
            
        case .remedial:
            searchBarPhrases = ["search for help in anything"]
			subcategories = [(title: "Conditions", icon: #imageLiteral(resourceName: "conditions")),
							 (title: "Development", icon: #imageLiteral(resourceName: "development")),
							 (title: "Disabilities", icon: #imageLiteral(resourceName: "disabilities")),
							 (title: "Impairments", icon: #imageLiteral(resourceName: "impairments")),
							 (title: "Injuries", icon: #imageLiteral(resourceName: "injuries")),
							 (title: "Special Education", icon: #imageLiteral(resourceName: "special-education"))]
            fileToRead = "remedial"
            
        case .sports:
            searchBarPhrases = ["search sports and games"]
			subcategories = [(title: "Extreme Sports", icon: #imageLiteral(resourceName: "extreme-sports")),
							 (title: "Fantasy Sports", icon: #imageLiteral(resourceName: "fantasy-sports")),
							 (title: "Mind Sports", icon: #imageLiteral(resourceName: "mind-sports")),
							 (title: "Physical Sports", icon: #imageLiteral(resourceName: "physical-sports")),
							 (title: "Skills Training", icon: #imageLiteral(resourceName: "skill-training")),
							 (title: "eSports", icon: #imageLiteral(resourceName: "esports"))]
            fileToRead = "sports"
            
        case .tech:
            searchBarPhrases = ["search topics in technology"]
			subcategories = [(title: "Gaming", icon: #imageLiteral(resourceName: "gaming")),
							 (title: "Hardware", icon: #imageLiteral(resourceName: "hardware")),
							 (title: "IT", icon: #imageLiteral(resourceName: "it")),
							 (title: "Programming", icon: #imageLiteral(resourceName: "programming")),
							 (title: "Software", icon: #imageLiteral(resourceName: "software")),
							 (title: "Tech Repairs", icon: #imageLiteral(resourceName: "tech-repairs"))]
            fileToRead = "tech"
            
        case .trades:
            searchBarPhrases = ["search for any trade"]
			subcategories = [(title: "Construction", icon: #imageLiteral(resourceName: "construction")),
							 (title: "General Trades", icon: #imageLiteral(resourceName: "general")),
							 (title: "Home Trades", icon: #imageLiteral(resourceName: "home")),
							 (title: "Industrial Trades", icon: #imageLiteral(resourceName: "industry")),
							 (title: "Motive Power", icon: #imageLiteral(resourceName: "motive-power")),
							 (title: "Service Trades", icon: #imageLiteral(resourceName: "services"))]
            fileToRead = "trades"
        }
		return Subcategory(subcategories: subcategories, phrase: searchBarPhrases[Int(arc4random_uniform(UInt32(searchBarPhrases.count)))], fileToRead: fileToRead)
    }
    
    var mainPageData: MainPageData {
        
        let displayName: String
        let image: UIImage
        let categoryInfo: String
        let suggestedPrices: [Int]
        
        switch self {
        case .academics: displayName = "Academics"
            image = #imageLiteral(resourceName: "academics")
            categoryInfo = "The classics. Whether you’re a master of mechanical engineering or a math wiz — we have a subject you can tutor. These are the core subjects that have been around since the beginning of time."
            suggestedPrices = [12, 40, 100]
            
        case .arts: displayName = "The Arts"
            image = #imageLiteral(resourceName: "arts")
            categoryInfo = "Does the renaissance sing out of your soul? Whether you're a dancer, singer or poet — you now have the ability to tutor others in poetry, drama, painting or phantom of the opera — this is where we get the creative juices flowin’."
            suggestedPrices = [10, 32, 65]
            
        case .auto: displayName = "Auto"
            image = #imageLiteral(resourceName: "auto")
            categoryInfo = "Interested in teaching others a thing or two about being a gear-head? Are you a skilled repairman or designer? In this category, you’ll be able to teach others anything about auto!"
            suggestedPrices = [12, 20, 45]
            
        case .business: displayName = "Business"
            image = #imageLiteral(resourceName: "business")
            categoryInfo = "Are you an entrepreneur, lawyer, accountant, marketer, or economist? Maybe the neighborhood excel expert? Let's talk business. "
            suggestedPrices = [16, 50, 100]
            
        case .lifestyle: displayName = "Lifestyle"
            image = #imageLiteral(resourceName: "experiences")
            categoryInfo = "The smell of baked lasagna coming out of the oven, the feel of clay between one’s fingers — music, yoga, travel, arts & crafts, and motivation are all found here. Lifestyle is where all can tutor the things that warm our hearts and drive our souls."
            suggestedPrices = [12, 25, 50]
            
        case .health: displayName = "Health & Wellness"
            image = #imageLiteral(resourceName: "health")
            categoryInfo = "Ever been told you’re a health nut? Well, whether you’re a doctor, dentist, gym-rat, nutritionist, or fitness model — you can tutor any subject in our health & wellness category."
            suggestedPrices = [18, 45, 90]
            
        case .language: displayName = "Language"
            image = #imageLiteral(resourceName: "languages")
            categoryInfo = "Run a tutoring business teaching others your native language or even a language you’ve adopted! Nearly every language in existence — available to tutor with just the tap of a button."
            suggestedPrices = [12, 20, 26]
            
        case .outdoors: displayName = "Outdoors"
            image = #imageLiteral(resourceName: "outdoors")
            categoryInfo = "Tutors, it’s time to take your learners outside of the classroom and office. Are you a survivalist? Expert in your neck of the woods? Dad of the year? If so, this is the category for you. "
            suggestedPrices = [7, 22, 45]
            
        case .remedial: displayName = "Remedial"
            image = #imageLiteral(resourceName: "remedial")
            categoryInfo = "QuickTutor is a learning and teaching community built for everyone. Remedial is provided and intended for people who experience learning difficulties, or who would like to teach others about special education."
            suggestedPrices = [16, 28, 65]
            
        case .sports: displayName = "Sports & Games"
            image = #imageLiteral(resourceName: "sports")
            categoryInfo = "Snowboarding, video games, chess, fantasy sports, or skydiving — The Sports & Games category is where competitive adrenaline junkies and gamers thrive. Tutor anything."
            suggestedPrices = [8, 19, 40]
            
        case .tech: displayName = "Technology"
            image = #imageLiteral(resourceName: "tech")
            categoryInfo = "Programmers, engineers, gamers, and the creators of the future, come all — here’s where you can share your passion and knowledge with those in need. "
            suggestedPrices = [15, 45, 90]
            
        case .trades: displayName = "Trades"
            image = #imageLiteral(resourceName: "trades")
            categoryInfo = "Time to become a hands-on tutor in construction, industrial, motive-power, services, home, or anything! Turn your everyday skills into a tutoring business."
            suggestedPrices = [15, 20, 40]
        }
        return MainPageData(displayName: displayName, image: image, categoryInfo: categoryInfo, suggestedPrices: suggestedPrices)
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
        case "lifestyle":
            return .lifestyle
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
    
    static func imageFor(category: Category) -> UIImage? {
        let index = categories.firstIndex(where: {$0.mainPageData.displayName == category.mainPageData.displayName})
        return categoryIcons[index ?? 0]
    }
}

extension Category {
    
    struct MainPageData {
        let displayName: String
        let image: UIImage
        let categoryInfo: String
        let suggestedPrices: [Int]
    }
    
    struct Subcategory {
		let subcategories: [(title: String, icon: UIImage)]
        let phrase: String
        let fileToRead: String
    }
}

enum CategoryType: String {
    case academics = "acedemics"
    case arts = "arts"
    case auto = "auto"
    case business = "business"
    case lifestyle = "lifestyle"
    case health = "health"
    case language = "language"
    case outdoors = "outdoors"
    case remedial = "remedial"
    case sports = "sports"
    case tech = "tech"
    case trades = "trades"
}

struct CategoryNew {
    var name: String!
    var image: UIImage!
    var subcategories = [SubcategoryNew]()

    init(name: String) {
        self.name = name
    }
    
}

struct SubcategoryNew {
    var name: String!
    var category: String!
    var subjects = [String]()
    
    init(name: String, category: String) {
        self.name = name
        self.category = category
    }

}

struct SubjectNew {
    var name: String!
    var category: CategoryNew!
    var subcategory: SubcategoryNew!
    
}

class CategoryFactory {
    
    static let shared = CategoryFactory()
    var allCategories = [CategoryNew]()
    
    private func loadAllCategories() {
        categories.forEach { (category) in
            guard let newCategory = self.getCategoryFor(category.subcategory.fileToRead) else { return }
            allCategories.append(newCategory)
        }
    }
    
    func getCategoryFor(_ title: String) -> CategoryNew? {
        var category = CategoryNew(name: title)
        
        guard let content = loadContentFrom(title) else { return nil}
        content.forEach { (subcategoryTitle, subjectList) in
            var subcategory = SubcategoryNew(name: subcategoryTitle, category: title)
            subjectList.forEach({subcategory.subjects.append($0)})
            category.subcategories.append(subcategory)
        }
        return category
 
    }
    
    func getCategoryFor(subcategoryTitle: String) -> CategoryNew? {
        return allCategories.first { (category) -> Bool in
            let contains = category.subcategories.contains(where: {$0.name == subcategoryTitle})
            return contains
        }
    }
    
    func getCategoryFor(subject: String) -> CategoryNew? {
        return allCategories.first(where: { (category) -> Bool in
            let contains = category.subcategories.contains(where: {$0.subjects.contains(subject)})
            return contains
        })
    }
    
    func getImageFor(subject: String) -> UIImage? {
        let parentCategory = allCategories.first { (category) -> Bool in
            return category.subcategories.contains(where: {$0.subjects.contains(where: {$0 == subject})})
        }
        
        let index = categories.firstIndex { (category2) -> Bool in
            print(category2.subcategory.fileToRead)
            print(parentCategory?.name)
            return category2.mainPageData.displayName == parentCategory?.name
        }
        
        return categoryIcons[index ?? 0]
    }
    
    private func loadContentFrom(_ fileName: String) -> [String: [String]]? {
        do {
            guard let file = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                return nil }
            let data = try Data(contentsOf: file)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let content = json as? [String: [String]] else { return nil }
            return content
        } catch {
            return nil
        }
    }
    
    private init() {
        loadAllCategories()
    }
}
