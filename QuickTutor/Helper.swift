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
    
    var subcategory: Subcategory {
        
        let searchBarPhrases: [String]
		let subcategories: [(title: String, icon: UIImage)]
        let fileToRead: String
        let defaultImage = UIImage(named: "uploadImageDefaultImage")!
        switch self {
            
        case .academics:
            searchBarPhrases = ["search any academic topic"]
			subcategories = [(title: "Extracurricular", icon: defaultImage),
							 (title: "Language Arts", icon: defaultImage),
							 (title: "Mathematics", icon: defaultImage),
							 (title: "Social Studies", icon:  defaultImage),
							 (title: "Test Prep", icon: defaultImage),
							 (title: "The Sciences", icon: defaultImage)]
		fileToRead = "academics"
            
        case .arts:
            searchBarPhrases = ["search for any art"]
			subcategories = [(title: "Applied Arts", icon: defaultImage),
							 (title: "Art Criticism", icon: defaultImage),
							 (title: "Literary Arts", icon: defaultImage),
							 (title: "Performing Arts", icon: defaultImage),
							 (title: "Visual Arts", icon: defaultImage)]
            fileToRead = "arts"
            
        case .auto:
            searchBarPhrases = ["search anything auto-related"]
			subcategories = [(title: "Auto Design", icon: defaultImage),
							 (title: "Auto Repairs", icon: defaultImage),
							 (title: "Auto Upgrades", icon: defaultImage),
							 (title: "Automobiles", icon: defaultImage),
							 (title: "Motor Vehicles", icon: defaultImage),
							 (title: "Vehicle Maintenance", icon: defaultImage)]
            fileToRead = "auto"
            
        case .business:
            searchBarPhrases = ["search any business topic"]
			subcategories = [(title: "Business Management", icon: defaultImage),
							 (title: "Economics & Accounting", icon: defaultImage),
							 (title: "Entrepreneurship", icon: defaultImage),
							 (title: "Finance & Law", icon: defaultImage),
							 (title: "Information Systems", icon: defaultImage),
							 (title: "Marketing & Hospitality", icon: defaultImage)]
            fileToRead = "business"
            
        case .lifestyle:
            searchBarPhrases = ["search for any lifestyle"]
			subcategories = [(title: "Careers", icon: defaultImage),
							 (title: "Cooking & Baking", icon: defaultImage),
							 (title: "Creations", icon: defaultImage),
							 (title: "Fitness", icon: defaultImage),
							 (title: "Motivation & Consulting", icon: defaultImage),
							 (title: "Travel Destinations", icon: defaultImage)]
            fileToRead = "lifestyle"
            
        case .health:
            searchBarPhrases = ["search health and wellness"]
			subcategories = [(title: "General Health", icon: defaultImage),
							 (title: "Illness", icon: defaultImage),
							 (title: "Medicine", icon: defaultImage),
							 (title: "Nutrition", icon: defaultImage),
							 (title: "Physical Exercise", icon: defaultImage),
							 (title: "Self-Care", icon: defaultImage)]
            fileToRead = "health"
            
		case .language:
            searchBarPhrases = ["search for any language skill"]
			subcategories = [(title: "ESL", icon: defaultImage),
							 (title: "Listening", icon: defaultImage),
							 (title: "Reading", icon: defaultImage),
							 (title: "Sign Language", icon: defaultImage),
							 (title: "Speaking", icon: defaultImage),
							 (title: "Writing", icon: defaultImage)]
            fileToRead = "language"
            
        case .outdoors:
            searchBarPhrases = ["discover the outdoors"]
			subcategories = [(title: "Land & Water", icon: defaultImage),
							 (title: "Life Identification", icon: defaultImage),
							 (title: "Outdoor Activities", icon: defaultImage),
							 (title: "Outdoors Prep", icon: defaultImage),
							 (title: "Seasonal", icon: defaultImage),
							 (title: "Survival", icon: defaultImage)]
            fileToRead = "outdoors"
            
        case .remedial:
            searchBarPhrases = ["search for help in anything"]
			subcategories = [(title: "Conditions", icon: defaultImage),
							 (title: "Development", icon: defaultImage),
							 (title: "Disabilities", icon: defaultImage),
							 (title: "Impairments", icon: defaultImage),
							 (title: "Injuries", icon: defaultImage),
							 (title: "Special Education", icon: defaultImage)]
            fileToRead = "remedial"
            
        case .sports:
            searchBarPhrases = ["search sports and games"]
			subcategories = [(title: "Extreme Sports", icon: defaultImage),
							 (title: "Fantasy Sports", icon: defaultImage),
							 (title: "Mind Sports", icon: defaultImage),
							 (title: "Physical Sports", icon: defaultImage),
							 (title: "Skills Training", icon: defaultImage),
							 (title: "eSports", icon: defaultImage)]
            fileToRead = "sports"
            
        case .tech:
            searchBarPhrases = ["search topics in technology"]
			subcategories = [(title: "Gaming", icon: defaultImage),
							 (title: "Hardware", icon: defaultImage),
							 (title: "IT", icon: defaultImage),
							 (title: "Programming", icon: defaultImage),
							 (title: "Software", icon: defaultImage),
							 (title: "Tech Repairs", icon: defaultImage)]
            fileToRead = "tech"
            
        case .trades:
            searchBarPhrases = ["search for any trade"]
			subcategories = [(title: "Construction", icon: defaultImage),
							 (title: "General Trades", icon: defaultImage),
							 (title: "Home Trades", icon: defaultImage),
							 (title: "Industrial Trades", icon: defaultImage),
							 (title: "Motive Power", icon: defaultImage),
							 (title: "Service Trades", icon: defaultImage)]
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
