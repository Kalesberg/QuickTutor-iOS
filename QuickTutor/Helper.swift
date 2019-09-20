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
            searchBarPhrases = ["search any academic subject"]
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
        let description: String
        
        switch self {
        case .academics: displayName = "Academics"
            image = #imageLiteral(resourceName: "academics")
            categoryInfo = "The classics. Whether you’re a master of mechanical engineering or a math wiz — we have a subject you can tutor. These are the core subjects that have been around since the beginning of time."
            suggestedPrices = [12, 30, 80]
            description = "Oh, the classics. From astrophysics and anatomy to poetry and polynomials. These are the core topics that have been around since the beginning of time. \n\nSam was in class earlier today. He spent the entire time on a popular social networking site – the one that they made a movie about, with the twin characters played by the same actor. Anyhow, the point is – Sam wasn’t concentrating; and of course, as the story goes and as luck would have it, he had a paper due the next morning, based on today’s class!\n\nInstead of freaking out: he does QuickTutor and chill. There he finds Jem. She knows a thing or two about Equity & Trusts. After only 45 minutes, Sam has gotten his head around the key concepts; so, Jem uses the remaining 15 minutes of their session to share with Sam another bit of wisdom – her spaghetti Bolognese recipe!\n\nThat’s the thing: with QuickTutor, you really can learn anything and teach anyone. Anything. Anytime. Anywhere. Share what you know. Or learn what you don’t. Or do both — [Either way: chill]."
            
        case .arts: displayName = "The Arts"
            image = #imageLiteral(resourceName: "arts")
            categoryInfo = "Does the renaissance sing out of your soul? Whether you're a dancer, singer or poet — you now have the ability to tutor others in poetry, drama, painting or phantom of the opera — this is where we get the creative juices flowin’."
            suggestedPrices = [10, 26, 55]
            description = "Does the Renaissance sing out of your soul? You can now learn or teach painting, poetry, drama, and even phantom of the opera — this is where we get the creative juices flowing.\n\nEver read Shakespeare? Nope? Neither had Sal, but he wanted to get down with the classics and needed a bit of help deciphering some of that oldy, worldy, and somewhat wordy, English. So, he logged into QuickTutor, and within minutes, he had scheduled a session with Pete. Now Sal's a bit obsessed (to put it politely) with Shakespeare and is even planning a trip to London to visit the Globe Theatre! Nice one, Sal. (Don't forget your toothbrush!).\n\nAs for Nidya, she considers herself a future Banksy. However, instead of getting in trouble with the 5-0 (as her folks weren't too keen on her using the exterior walls of the family crib either) she connected with Daniel. Daniel does one-on-one sessions at his studio and, as luck would have it, it's only a mile away from Nidya.\n\nDaniel earns some extra cash, and Nidya gets all the advice and blank surfaces an artist-in-the-making could need. We'll talk about Tommy another day (he's the actor who connects with an acting QuickTutor every time he has an audition. What a smart cookie!). Don't be shy. Get Arty-Farty (but more arty than farty, please)."
            
        case .auto: displayName = "Auto"
            image = #imageLiteral(resourceName: "auto")
            categoryInfo = "Interested in teaching others a thing or two about being a gear-head? Are you a skilled repairman or designer? In this category, you’ll be able to teach others anything about auto!"
            suggestedPrices = [17, 52, 80]
            description = "If you’re a gearhead or excellent at building, designing, and repairing vehicles, this is the category for you.\n\nMeet Freddie: he wants to install an aftermarket stereo system and change the rims on his new Taco. Meet Sarah: she works as a mechanic and makes extra cash on the side by sharing her knowledge on QuickTutor.\n\nWhile Freddie replaces the stereo and rims, Sarah will oversee and instruct him – all from within QuickTutor’s in-app video calling feature! Oh yeah, while we’re at it – meet Matt: he wants to know what a Taco is.\n\np.s. - You can also visit the user app to learn anything about Auto!"
            
        case .business: displayName = "Business"
            image = #imageLiteral(resourceName: "business")
            categoryInfo = "Are you an entrepreneur, lawyer, accountant, marketer, or economist? Maybe the neighborhood excel expert? Let's talk business. "
            suggestedPrices = [18, 40, 135]
            description = "If business is your thing; or, if you want it to be; then, you're in the right place.\n\nWe've been wondering where aspiring Belfort's or Fiorina's will now go for bespoke learning since Trump University has closed. Where will those with goals to join the Forbes Billionaires list learn? Let's not forget about the many who have watched Wolf of Wall Street and the series, Billions – millions of times. Last but certainly not least, we can't forget about the MBA and even high school DECA students.\n\nWhen people need support with their current business classes or endeavors, QuickTutor's business magnates, social media superstars, legal professionals, and top-tier business students are more than willing to help. If you've got a thing or two to share about your startup or corporate empire, let's talk biz."
            
        case .lifestyle: displayName = "Lifestyle"
            image = UIImage(named: "lifestyle")!
            categoryInfo = "The smell of baked lasagna coming out of the oven, the feel of clay between one’s fingers — music, yoga, travel, arts & crafts, and motivation are all found here. Lifestyle is where all can tutor the things that warm our hearts and drive our souls."
            suggestedPrices = [10, 20, 45]
            description = "The smell of baked lasagna coming out of the oven, the feel of clay between one's fingers — yoga, travel, arts & crafts, and motivation. A place that all can learn & enjoy the things that warm our hearts — live life with style; your style, and on your terms. There's only one life to live after all; so, what're you waiting for? Whether it's fashion or grooming, makeup or Feng Shui, the lifestyle category holds an abundance of possibilities. Your only limitation is your imagination – let us feed it!"
            
        case .health: displayName = "Health"
            image = #imageLiteral(resourceName: "health")
            categoryInfo = "Ever been told you’re a health nut? Well, whether you’re a doctor, dentist, gym-rat, nutritionist, or fitness model — you can tutor any subject in our health category."
            suggestedPrices = [19, 55, 98]
            description = "Ever been told you're a health nut? Well, whether you're a doctor, athlete, dentist, gym-rat, nutritionist, or a fitness model — we have something you can work out with (no pun intended).\n\nHealth is an essential place to get inspired. Perhaps you're feeling like you’re in a bit of a rut and want to break some bad habits. Or maybe you want to switch over to a vegan diet in smooth manner.  Perhaps you need a little inspiration for leading a healthier way of life. Or, you could do with weekly sessions with your very own QuickTutor to achieve your current health and wellness goals. Whatever you're looking for, the health category is bound to satisfy the needs of everyone looking to make the very most of their lives."
            
        case .language: displayName = "Language"
            image = #imageLiteral(resourceName: "languages")
            categoryInfo = "Run a tutoring business teaching others your native language or even a language you’ve adopted! Nearly every language in existence — available to tutor with just the tap of a button."
            suggestedPrices = [12, 30, 86]
            description = "Now, with QuickTutor, anyone can earn a living teaching other people their native language or a language they've adopted! We offer nearly every language known to humanity, and they're all just a few taps away.\n\nDo you know the difference between pollo and polla in Spanish? Not knowing might cause you some embarrassment on the dating scene or while ordering food in a restaurant. Be sure to stay on the up and up with your Spanish spelling skills! It could be irresponsible not to. [This has been a public service announcement from QuickTutor. xoxo]"
            
        case .outdoors: displayName = "Outdoors"
            image = #imageLiteral(resourceName: "outdoors")
            categoryInfo = "Tutors, it’s time to take your learners outside of the classroom and office. Are you a survivalist? Expert in your neck of the woods? Dad of the year? If so, this is the category for you. "
            suggestedPrices = [9, 20, 41]
            description = ""
            
        case .remedial: displayName = "Remedial"
            image = #imageLiteral(resourceName: "remedial")
            categoryInfo = "QuickTutor is a learning and teaching community built for everyone. Remedial is provided and intended for people who experience learning difficulties, or who would like to teach others about special education."
            suggestedPrices = [14, 28, 75]
            description = "QuickTutor is a learning and teaching community built for everyone. We live in a complex world with such a wonderfully diverse mix of peoples; each with their own unique educational needs. Whether you’re a QuickTutor or just looking to learn a new thing or two – worry not, QT has your back. The Remedial category is provided and intended for people who experience learning difficulties, or who would like to learn/teach special education."
            
        case .sports: displayName = "Sports & Games"
            image = #imageLiteral(resourceName: "sports")
            categoryInfo = "Snowboarding, video games, chess, fantasy sports, or skydiving — The Sports & Games category is where competitive adrenaline junkies and gamers thrive. Tutor anything."
            suggestedPrices = [16, 40, 95]
            description = "From Snowboarding, Skyrim or Scrabble to Ping Pong, Wrestling or Fantasy Sports — the Sports & Games category is where competitive adrenaline junkies and gamers thrive.\n\nWhether it's getting sweaty outdoors or thumb cramps indoors, QuickTutor won't judge. However, we might - if you're not playing at your best. So, level-up or get more runs on the board – either way, whatever the analogy, get ready to play, perform or execute with QT.\n\nThere's a world of opportunities. Whatever your interests and whatever the weather. Imagine this (go on - shut your eyes and imagine, oh hold on, you can't. You need to read this):\n\nYou're a keen golfer, like the Don or Mr. Levine. You could do with a golfing tutor, but don't have the luxury of millions in the bank, so you don't have one in your entourage. However, worry not — next time you're teeing off – take a golfing QuickTutor with you. Just use our nifty built-in video calling feature!\n\nAre you holding back your mates on Fortnite? Grab a lesson on the down-low or have a QuickTutor sit in on your next match. There are endless possibilities with every Sport & Game you can imagine!"
            
        case .tech: displayName = "Technology"
            image = #imageLiteral(resourceName: "tech")
            categoryInfo = "Programmers, engineers, gamers, and the creators of the future, come all — here’s where you can share your passion and knowledge with those in need. "
            suggestedPrices = [22, 60, 95]
            description = "For those of you who like toiling away in the dark, you can now shine the light of your wisdom on those less tech-savvy. Programmers, engineers, gamers, and creators of the future – come all. Here, you can share your passions and knowledge with those in need.\n\nWhether you’re a guru or a technophobe, there’s support aplenty for those in need on QuickTutor. From lifting the lid on the simplest of IT issues, to sophisticated mobile app algorithms – whatever your needs, a tech QuickTutor awaits. So, the next time grandma calls asking you how to open her computer in recovery mode or your buddy wants to dive into UX design; there’s only one place to point them ... QuickTutor! You can also hop on the user app to level up and become a tech whiz in your respective field."
            
        case .trades: displayName = "Trades"
            image = #imageLiteral(resourceName: "trades")
            categoryInfo = "Time to become a hands-on tutor in construction, industrial, motive-power, services, home, or anything! Turn your everyday skills into a tutoring business."
            suggestedPrices = [17, 50, 74]
            description = "Time to get hands-on with various trades like welding, carpentry, plumbing, and more! Turn your ordinary skills into a learning & teaching business, prepare for trades school, or learn to fix something!\n\nJulia wanted to do a spot of DYI in her new pad. She picked up some flat-pack furniture from that Swedish company (the one with the yummy meatballs). When she got home, she connected with Darren - who's a sure chippy, if you catch our drift. He makes extra cash on the side by sharing what he knows on QuickTutor.\n\nIn their initial video call, Darren gives Courtney a list of things to buy from the hardware store. In their second call, he gives her some tips for installing the new bathroom cabinets. Next thing you know, Courtney's replacing the taps in the kitchen. Oh, and then Courtney decides to become a QuickTutor and teaches Darren bookkeeping (he might be great with things around the house – but he's pretty terrible at keeping track of his expenses)!\n\nSee, that's the thing: everyone has something that they can teach and often something that they want to learn, too."
        }
        return MainPageData(displayName: displayName, image: image, categoryInfo: categoryInfo, description: description, suggestedPrices: suggestedPrices)
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
        let description: String
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
