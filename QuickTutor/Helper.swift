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

class SubjectStore {
    static let shared = SubjectStore()
    
    private var totalSubjects: [(String, String)]?
    
    func loadTotalSubjectList() -> [(String, String)]? {
        if let totalSubjects = totalSubjects {
            return totalSubjects
        }
        
        totalSubjects = []
        for i in 0 ..< categories.count {
            guard let file = Bundle.main.url(forResource: categories[i].subcategory.fileToRead, withExtension: "json"),
                let data = try? Data(contentsOf: file),
                let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                continue }
            
            for key in categories[i].subcategory.subcategories {
                guard let object = json as? [String: [String]], let subjectArray = object[key.title] else { continue }
                
                for subject in subjectArray {
                    totalSubjects?.append((subject, key.title))
                }
            }
        }
        
        return totalSubjects
    }
    
    func findCategoryBy(subcategory: String) -> String? {
        for category in categories {
            let lowercased = category.subcategory.subcategories.map({ $0.title.lowercased() })
            if lowercased.contains(subcategory.lowercased()) {
                return category.subcategory.fileToRead
            }
        }
        return nil
    }
    
    func findSubCategory(subject: String) -> String? {
        guard let totalSubjects = loadTotalSubjectList() else { return nil }
        
        return totalSubjects.first(where: { $0.0 == subject })?.1
    }
    
    func findCategoryBy(subject: String) -> String? {
        guard let subCategory = findSubCategory(subject: subject) else { return nil }
        
        return findCategoryBy(subcategory: subCategory)
    }

}

let categoryIcons = [UIImage(named: "academicsIcon"), UIImage(named: "businessIcon"), UIImage(named: "lifestyleIcon"), UIImage(named: "languageIcon"), UIImage(named: "artsIcon"), UIImage(named: "sportsIcon"), UIImage(named: "healthIcon"), UIImage(named: "techIcon"), UIImage(named: "outdoorsIcon"), UIImage(named: "autoIcon"), UIImage(named: "tradesIcon"), UIImage(named: "remedialIcon")]

enum Category {
    
    case academics, arts, auto, business, lifestyle, health, language, outdoors, remedial, sports, tech, trades
    static let categories: [Category] = [.academics, .business, .lifestyle, .language,  .arts,  .sports, .health, .tech, .outdoors, .auto, .trades, .remedial]
    
    var color: UIColor {
        switch self {
        case .academics:
            return UIColor(hex: "5CD074")
        case .arts:
            return UIColor(hex: "30328E")
        case .auto:
            return UIColor(hex: "E47D3A")
        case .business:
            return UIColor(hex: "429479")
        case .lifestyle:
            return UIColor(hex: "3BACA7")
        case .health:
            return UIColor(hex: "A2318A")
        case .language:
            return UIColor(hex: "479FF8")
        case .outdoors:
            return UIColor(hex: "DA3832")
        case .remedial:
            return UIColor(hex: "FDF251")
        case .sports:
            return UIColor(hex: "6C318C")
        case .tech:
            return UIColor(hex: "D92F8B")
        case .trades:
            return UIColor(hex: "F1B644")
        }
    }
    
    var subcategory: Subcategory {
        
        let searchBarPhrases: [String]
		let subcategories: [(title: String, icon: UIImage?)]
        let fileToRead: String
        switch self {
            
        case .academics:
            searchBarPhrases = ["search any academic topic"]
            subcategories = [(title: "Extracurricular", icon: UIImage(named: "ic_extracurricular")),
							 (title: "Language Arts", icon: UIImage(named: "ic_language_arts")),
							 (title: "Mathematics", icon: UIImage(named: "ic_mathematics")),
							 (title: "Social Studies", icon:  UIImage(named: "ic_social_studies")),
							 (title: "Test Prep", icon: UIImage(named: "ic_test_prep")),
							 (title: "The Sciences", icon: UIImage(named: "ic_the_sciences"))]
		fileToRead = "academics"
            
        case .arts:
            searchBarPhrases = ["search for any art"]
			subcategories = [(title: "Applied Arts", icon: UIImage(named: "ic_applied_arts")),
							 (title: "Art Criticism", icon: UIImage(named: "ic_art_criticism")),
                             (title: "Art History", icon: UIImage(named: "ic_art_history")),
							 (title: "Literary Arts", icon: UIImage(named: "ic_literary_arts")),
							 (title: "Performing Arts", icon: UIImage(named: "ic_performing_arts")),
							 (title: "Visual Arts", icon: UIImage(named: "ic_visual_arts"))]
            fileToRead = "arts"
            
        case .auto:
            searchBarPhrases = ["search anything auto-related"]
			subcategories = [(title: "Auto Design", icon: UIImage(named: "ic_auto_design")),
							 (title: "Auto Repairs", icon: UIImage(named: "ic_auto_repairs")),
							 (title: "Auto Upgrades", icon: UIImage(named: "ic_auto_upgrades")),
							 (title: "Automobiles", icon: UIImage(named: "ic_auto_mobiles")),
							 (title: "Motor Vehicles", icon: UIImage(named: "ic_motor_vehicles")),
							 (title: "Vehicle Maintenance", icon: UIImage(named: "ic_vehicle_maintenance"))]
            fileToRead = "auto"
            
        case .business:
            searchBarPhrases = ["search any business topic"]
			subcategories = [(title: "Business Management", icon: UIImage(named: "ic_business_management")),
							 (title: "Economics & Accounting", icon: UIImage(named: "ic_economics_and_accounting")),
							 (title: "Entrepreneurship", icon: UIImage(named: "ic_entrepreneurship")),
							 (title: "Finance & Law", icon: UIImage(named: "ic_finance_and_law")),
							 (title: "Information Systems", icon: UIImage(named: "ic_information_systems")),
							 (title: "Marketing & Hospitality", icon: UIImage(named: "ic_marketing_and_hospitality"))]
            fileToRead = "business"
            
        case .lifestyle:
            searchBarPhrases = ["search for any lifestyle"]
			subcategories = [(title: "Careers", icon: UIImage(named: "ic_careers")),
							 (title: "Cooking & Baking", icon: UIImage(named: "ic_cooking_and_baking")),
							 (title: "Creations", icon: UIImage(named: "ic_creations")),
							 (title: "Fitness", icon: UIImage(named: "ic_fitness")),
							 (title: "Motivation & Consulting", icon: UIImage(named: "ic_motivation_and_consulting")),
							 (title: "Travel Destinations", icon: UIImage(named: "ic_travel_destinations"))]
            fileToRead = "lifestyle"
            
        case .health:
            searchBarPhrases = ["search health and wellness"]
			subcategories = [(title: "General Health", icon: UIImage(named: "ic_general_health")),
							 (title: "Illness", icon: UIImage(named: "ic_illness")),
							 (title: "Medicine", icon: UIImage(named: "ic_medicine")),
							 (title: "Nutrition", icon: UIImage(named: "ic_nutrition")),
							 (title: "Physical Exercise", icon: UIImage(named: "ic_physical_exercise")),
							 (title: "Self-Care", icon: UIImage(named: "ic_self-care"))]
            fileToRead = "health"
            
		case .language:
            searchBarPhrases = ["search for any language skill"]
			subcategories = [(title: "ESL", icon: UIImage(named: "ic_ESL")),
							 (title: "Listening", icon: UIImage(named: "ic_listening")),
							 (title: "Reading", icon: UIImage(named: "ic_reading")),
							 (title: "Sign Language", icon: UIImage(named: "ic_sign_language")),
							 (title: "Speaking", icon: UIImage(named: "ic_speaking")),
							 (title: "Writing", icon: UIImage(named: "ic_writing"))]
            fileToRead = "language"
            
        case .outdoors:
            searchBarPhrases = ["discover the outdoors"]
			subcategories = [(title: "Land & Water", icon: UIImage(named: "ic_land_and_water")),
							 (title: "Life Identification", icon: UIImage(named: "ic_life_identification")),
							 (title: "Outdoor Activities", icon: UIImage(named: "ic_outdoor_activities")),
							 (title: "Outdoors Prep", icon: UIImage(named: "ic_outdoors_prep")),
							 (title: "Seasonal", icon: UIImage(named: "ic_seasonal")),
							 (title: "Survival", icon: UIImage(named: "ic_survival"))]
            fileToRead = "outdoors"
            
        case .remedial:
            searchBarPhrases = ["search for help in anything"]
			subcategories = [(title: "Conditions", icon: UIImage(named: "ic_conditions")),
							 (title: "Development", icon: UIImage(named: "ic_development")),
							 (title: "Disabilities", icon: UIImage(named: "ic_disabilities")),
							 (title: "Impairments", icon: UIImage(named: "ic_impairments")),
							 (title: "Injuries", icon: UIImage(named: "ic_injuries")),
							 (title: "Special Education", icon: UIImage(named: "ic_special_education"))]
            fileToRead = "remedial"
            
        case .sports:
            searchBarPhrases = ["search sports and games"]
			subcategories = [(title: "Extreme Sports", icon: UIImage(named: "ic_extreme_sports")),
							 (title: "Fantasy Sports", icon: UIImage(named: "ic_fantasy_sports")),
							 (title: "Mind Sports", icon: UIImage(named: "ic_mind_sports")),
							 (title: "Physical Sports", icon: UIImage(named: "ic_physical_sports")),
							 (title: "Skills Training", icon: UIImage(named: "ic_skills_training")),
							 (title: "eSports", icon: UIImage(named: "ic_eSports"))]
            fileToRead = "sports"
            
        case .tech:
            searchBarPhrases = ["search topics in technology"]
			subcategories = [(title: "Gaming", icon: UIImage(named: "ic_gaming")),
							 (title: "Hardware", icon: UIImage(named: "ic_hardware")),
							 (title: "IT", icon: UIImage(named: "ic_IT")),
							 (title: "Programming", icon: UIImage(named: "ic_programming")),
							 (title: "Software", icon: UIImage(named: "ic_software")),
							 (title: "Tech Repairs", icon: UIImage(named: "ic_tech_repairs"))]
            fileToRead = "tech"
            
        case .trades:
            searchBarPhrases = ["search for any trade"]
			subcategories = [(title: "Construction", icon: UIImage(named: "ic_construction")),
							 (title: "General Trades", icon: UIImage(named: "ic_general_trades")),
							 (title: "Home Trades", icon: UIImage(named: "ic_home_trades")),
							 (title: "Industrial Trades", icon: UIImage(named: "ic_industrial_trades")),
							 (title: "Motive Power", icon: UIImage(named: "ic_motive_power")),
							 (title: "Service Trades", icon: UIImage(named: "ic_service_trades"))]
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
            categoryInfo = "The classics. Whether you’re a master of mechanical engineering or a math wiz — we have a topic you can tutor. These are the core topics that have been around since the beginning of time."
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
            
        case .health: displayName = "Health"
            image = #imageLiteral(resourceName: "health")
            categoryInfo = "Ever been told you’re a health nut? Well, whether you’re a doctor, dentist, gym-rat, nutritionist, or fitness model — you can tutor any topic in our health category."
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
		let subcategories: [(title: String, icon: UIImage?)]
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

extension CategoryType {
    var title: String {
        switch self {
        case .tech:
            return "Technology"
        case .arts:
            return "The Arts"
        case .sports:
            return "Sports & Games"
        case .health:
            return "Health"
        default:
            return rawValue
        }
    }
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
    
    func getSubcategoryFor(subject: String) -> SubcategoryNew? {
        let category = allCategories.first { (categoryIn) -> Bool in
            return categoryIn.subcategories.contains(where: {$0.subjects.contains(subject)})
        }

        let subcategory = category?.subcategories.first(where: {$0.subjects.contains(subject)})
        return subcategory
    }
    
    func getImageFor(subject: String) -> UIImage? {
        let parentCategory = allCategories.first { (category) -> Bool in
            return category.subcategories.contains(where: {$0.subjects.contains(where: {$0 == subject})})
        }
        
        let index = categories.firstIndex { (category2) -> Bool in
            print(category2.subcategory.fileToRead)
            return category2.mainPageData.displayName == parentCategory?.name
        }
        
        return categoryIcons[index ?? 0]
    }
    
    /**
     Get a list of of all subjects belonging to a specific subcategory
     
     
     - Parameter subcategoryName: The name of the subcategory
     - Returns: List of subjects
     */
    
    func getSubjectsFor(subcategoryName: String) -> [String]? {
        let categoryIn = allCategories.first(where: {$0.subcategories.contains(where: {$0.name == subcategoryName})})
        guard let category = categoryIn else { return nil }
        let subcategoryIn = category.subcategories.first(where: {$0.name == subcategoryName})
        guard let subcategory = subcategoryIn else { return nil }
        return subcategory.subjects.sorted(by: { $0 < $1 })
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

class PostSessionHelper {
    static let shared = PostSessionHelper()
    
    func ratingViewControllerForSession(_ session: Session?, sessionId: String?) -> QTRatingReviewViewController? {
        guard let session = session, let sessionId = sessionId else {
            return nil
        }
        
        let cost = calculateCostOfSession(price: session.price, runtime: session.runTime, duration: session.duration)
        
        let vc = QTRatingReviewViewController.controller
        vc.session = session
        vc.sessionId = sessionId
        vc.costOfSession = cost
        return vc
    }
    
    private func calculateCostOfSession(price: Double, runtime: Int, duration: Int) -> Double {
        let minimumSessionPrice = 5.0
        var cost: Double = 0
        if duration != 0 && runtime != 0 {
            cost = price / Double(duration) * Double(runtime)
        }
        
        return cost < minimumSessionPrice ? minimumSessionPrice : round(cost * 1000) / 1000
    }
}
