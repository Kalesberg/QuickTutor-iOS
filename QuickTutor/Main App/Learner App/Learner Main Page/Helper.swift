//
//  Helper.swift
//  QuickTutor
//
//  Created by QuickTutor on 3/24/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class SectionHeader: BaseView {
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
        category.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.centerY.equalToSuperview().inset(5)
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
}

class FeaturedTutorView: BaseView {
    let imageView: UIImageView = {
        let imageView = UIImageView()

        if let image = LocalImageCache.localImageManager.getImage(number: "1") {
            imageView.image = image
        } else {
            // set to some arbitrary image.
        }
        // imageView.image = #imageLiteral(resourceName: "registration-image-placeholder")
        imageView.scaleImage()
        imageView.layer.applyShadow(color: UIColor.black.cgColor, opacity: 0.6, offset: CGSize(width: 3, height: 2), radius: 5)

        return imageView
    }()

    let subject: UILabel = {
        let subject = UILabel()

        subject.textAlignment = .left
        subject.textColor = .white
        subject.text = "German Tutoring"
        subject.font = Fonts.createSize(17)
        subject.adjustsFontSizeToFitWidth = true

        return subject
    }()

    let region: UILabel = {
        let region = UILabel()

        region.textAlignment = .left
        region.textColor = Colors.grayText
        region.text = "Wyandotte, MI"
        region.font = Fonts.createSize(13)
        region.adjustsFontSizeToFitWidth = true

        return region
    }()

    let namePrice: UILabel = {
        let namePrice = UILabel()

        namePrice.textAlignment = .left
        namePrice.textColor = Colors.grayText
        namePrice.text = "Garry, M"
        namePrice.font = Fonts.createSize(13)
        namePrice.adjustsFontSizeToFitWidth = true

        return namePrice
    }()

    let stars: UILabel = {
        let stars = UILabel()

        stars.textAlignment = .left
        stars.textColor = Colors.grayText
        stars.text = "+ + + + + +"
        stars.font = Fonts.createSize(14)
        stars.adjustsFontSizeToFitWidth = true

        return stars
    }()

    override func configureView() {
        addSubview(imageView)
        addSubview(subject)
        addSubview(region)
        addSubview(namePrice)
        addSubview(stars)
        super.configureView()

        backgroundColor = Colors.backgroundDark

        applyConstraints()
    }

    override func applyConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(14)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.width.equalToSuperview().multipliedBy(0.8)
        }
        subject.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.92)
        }
        region.snp.makeConstraints { make in
            make.top.equalTo(subject.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.92)
        }
        namePrice.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.92)
        }
        //        stars.snp.makeConstraints { (make) in
        //            make.top.equalTo(namePrice.snp.bottom)
        //            make.width.equalToSuperview()
        //            make.height.equalToSuperview().multipliedBy(0.1)
        //            make.centerX.equalToSuperview()
        //        }
    }
}

struct SubjectStore {
    static func readSubcategory(resource: String, subjectString: String, completion: @escaping ([String]) -> Void) {
        do {
            if let file = Bundle.main.url(forResource: resource.lowercased(), withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: [String]] {
                    if let subjectArray = object[subjectString] {
                        completion(subjectArray)
                    }
                } else {
                    print("Invalid Json")
                }
            } else {
                print("No File")
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    static func readCategory(resource: String, completion: @escaping ([String]) -> Void) {
        var category: [String] = []
        do {
            if let file = Bundle.main.url(forResource: resource.lowercased(), withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                for key in Category.category(for: resource)!.subcategory.subcategories {
                    if let object = json as? [String: [String]] {
                        if let subjectArray = object[key] {
                            category.append(contentsOf: subjectArray)
                        }
                    } else {
                        print("Invalid Json")
                    }
                }
                completion(category)
            } else {
                print("No File")
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    static func findSubCategory(resource: String, subject: String, completion: @escaping (String) -> Void) {
        do {
            if let file = Bundle.main.url(forResource: resource.lowercased(), withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                for key in Category.category(for: resource)!.subcategory.subcategories {
                    if let object = json as? [String: [String]] {
                        if let subjectArray = object[key] {
                            if subjectArray.contains(subject) {
                                completion(key)
                            }
                        }
                    } else {
                        print("Invalid Json")
                    }
                }
            } else {
                print("No File")
            }
        } catch {
            print(error.localizedDescription)
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

    static let categories: [Category] = [.academics, .arts, .auto, .business, .experiences, .health, .language, .outdoors, .remedial, .sports, .tech, .trades]

    var subcategory: Subcategory {
        let searchBarPhrases: [String]
        let subcategories: [String]
        let icon: [UIImage]
        let displayName: String
        let fileToRead: String

        switch self {
        case .academics: displayName = "ACADEMICS"
            searchBarPhrases = ["search any academic subject"]
            subcategories = ["Mathematics", "Language Arts", "Social Studies", "The Sciences", "Extracurricular", "Test Preparation"]
            icon = [#imageLiteral(resourceName: "mathematics"), #imageLiteral(resourceName: "language-arts"), #imageLiteral(resourceName: "social-studies"), #imageLiteral(resourceName: "science"), #imageLiteral(resourceName: "extracurricular"), #imageLiteral(resourceName: "test-prep")]
            fileToRead = "academics"

        case .arts: displayName = "THE ARTS"
            searchBarPhrases = ["search for any art"]
            subcategories = ["Applied Arts", "Art History", "Performing Arts", "Arts Critism", "Visual Arts", "Literary Arts"]
            icon = [#imageLiteral(resourceName: "applied-arts"), #imageLiteral(resourceName: "history"), #imageLiteral(resourceName: "performing"), #imageLiteral(resourceName: "art-criticism"), #imageLiteral(resourceName: "visual-arts"), #imageLiteral(resourceName: "literacy")]
            fileToRead = "arts"

        case .auto: displayName = "AUTO"
            searchBarPhrases = ["search anything auto-related"]
            subcategories = ["Automobiles", "Motor vehicles", "Maintenance", "Repairs", "Upgrades", "Design"]
            icon = [#imageLiteral(resourceName: "automobiles"), #imageLiteral(resourceName: "motor-vehicles"), #imageLiteral(resourceName: "maintenance"), #imageLiteral(resourceName: "repairs"), #imageLiteral(resourceName: "upgrades"), #imageLiteral(resourceName: "design")]
            fileToRead = "auto"

        case .business: displayName = "BUSINESS"
            searchBarPhrases = ["search any business topic"]
            subcategories = ["Entrepreneurship", "Finance | Law", "Economics | Accounting", "Management", "Information Systems", "Marketing | Hospitality"]
            icon = [#imageLiteral(resourceName: "entrepreneurship"), #imageLiteral(resourceName: "finance-law"), #imageLiteral(resourceName: "economics-accounting"), #imageLiteral(resourceName: "management"), #imageLiteral(resourceName: "it"), #imageLiteral(resourceName: "marketing-hospitality")]
            fileToRead = "business"

        case .experiences: displayName = "EXPERIENCES"
            searchBarPhrases = ["search for any experience"]
            subcategories = ["Career", "Cooking | Baking", "Volunteering", "Motivation | Consulting", "Travel Destinations", "Fitness"]
            icon = [#imageLiteral(resourceName: "life_lessons"), #imageLiteral(resourceName: "cooking-baking"), #imageLiteral(resourceName: "volunteering"), #imageLiteral(resourceName: "motivation"), #imageLiteral(resourceName: "travel-destinations"), #imageLiteral(resourceName: "fitness")]
            fileToRead = "experiences"

        case .health: displayName = "HEALTH"
            searchBarPhrases = ["search health and wellness"]
            subcategories = ["General", "Illness", "Medicines", "Nutrition", "Physical Exercise", "Self-Care"]
            icon = [#imageLiteral(resourceName: "general"), #imageLiteral(resourceName: "illness"), #imageLiteral(resourceName: "medicine"), #imageLiteral(resourceName: "nutrition"), #imageLiteral(resourceName: "physical-sports"), #imageLiteral(resourceName: "selfcare")]
            fileToRead = "health"

        case .language: displayName = "LANGUAGE"
            searchBarPhrases = ["search for any language skill"]
            subcategories = ["ESL", "Listening", "Reading", "Sign Language", "Speech", "Writing"]
            icon = [#imageLiteral(resourceName: "esl"), #imageLiteral(resourceName: "listening"), #imageLiteral(resourceName: "reading"), #imageLiteral(resourceName: "sign-language"), #imageLiteral(resourceName: "speech"), #imageLiteral(resourceName: "writing")]
            fileToRead = "language"

        case .outdoors: displayName = "OUTDOORS"
            searchBarPhrases = ["discover the outdoors"]
            subcategories = ["Activities", "Land | Water", "Life Identification", "Survival", "Preparation", "Seasonal"]
            icon = [#imageLiteral(resourceName: "activities"), #imageLiteral(resourceName: "land-water"), #imageLiteral(resourceName: "life-identity"), #imageLiteral(resourceName: "survival"), #imageLiteral(resourceName: "preperation"), #imageLiteral(resourceName: "seasonal")]
            fileToRead = "outdoors"

        case .remedial: displayName = "REMEDIAL"
            searchBarPhrases = ["search for help in anything"]
            subcategories = ["Conditions", "Development", "Disabilities", "Impairments", "Injuries", "Special Education"]
            icon = [#imageLiteral(resourceName: "conditions"), #imageLiteral(resourceName: "development"), #imageLiteral(resourceName: "disabilities"), #imageLiteral(resourceName: "impairments"), #imageLiteral(resourceName: "injuries"), #imageLiteral(resourceName: "special-education")]
            fileToRead = "remedial"

        case .sports: displayName = "SPORTS"
            searchBarPhrases = ["search sports and games"]
            subcategories = ["E-Sports", "Extreme Sports", "Fantasy Sports", "Mind Sports", "Physical Sports", "Skills Training"]
            icon = [#imageLiteral(resourceName: "esports"), #imageLiteral(resourceName: "extreme-sports"), #imageLiteral(resourceName: "fantasy-sports"), #imageLiteral(resourceName: "mind-sports"), #imageLiteral(resourceName: "physical-sports"), #imageLiteral(resourceName: "skill-training")]
            fileToRead = "sports"

        case .tech: displayName = "TECH"
            searchBarPhrases = ["search technological topics"]
            subcategories = ["Gaming", "Hardware", "IT", "Programming", "Repairs", "Software"]
            icon = [#imageLiteral(resourceName: "gaming"), #imageLiteral(resourceName: "hardware"), #imageLiteral(resourceName: "it"), #imageLiteral(resourceName: "programming"), #imageLiteral(resourceName: "repairs"), #imageLiteral(resourceName: "software")]
            fileToRead = "tech"

        case .trades: displayName = "TRADES"
            searchBarPhrases = ["search for any trade"]
            subcategories = ["Construction", "General", "Home", "Industrial", "Motive Power", "Services"]
            icon = [#imageLiteral(resourceName: "construction"), #imageLiteral(resourceName: "general"), #imageLiteral(resourceName: "home"), #imageLiteral(resourceName: "industry"), #imageLiteral(resourceName: "motive-power"), #imageLiteral(resourceName: "services")]
            fileToRead = "trades"
        }

        return Subcategory(subcategories: subcategories, icon: icon, phrase: searchBarPhrases[Int(arc4random_uniform(UInt32(searchBarPhrases.count)))], displayName: displayName, fileToRead: fileToRead)
    }

    var mainPageData: MainPageData {
        let displayName: String
        let image: UIImage

        switch self {
        case .academics: displayName = "Academics"
            image = #imageLiteral(resourceName: "academics")

        case .arts: displayName = "The Arts"
            image = #imageLiteral(resourceName: "arts")
        case .auto: displayName = "Auto"
            image = #imageLiteral(resourceName: "auto")

        case .business: displayName = "Business"
            image = #imageLiteral(resourceName: "business")

        case .experiences: displayName = "Experiences"
            image = #imageLiteral(resourceName: "experiences")

        case .health: displayName = "Health"
            image = #imageLiteral(resourceName: "health")

        case .language: displayName = "Language"
            image = #imageLiteral(resourceName: "languages")

        case .outdoors: displayName = "Outdoors"
            image = #imageLiteral(resourceName: "outdoors")

        case .remedial: displayName = "Remedial"
            image = #imageLiteral(resourceName: "remedial")

        case .sports: displayName = "Sports"
            image = #imageLiteral(resourceName: "sports")

        case .tech: displayName = "Tech"
            image = #imageLiteral(resourceName: "tech")

        case .trades: displayName = "Trades"
            image = #imageLiteral(resourceName: "trades")
        }
        return MainPageData(displayName: displayName, image: image)
    }

    static func category(for string: String) -> Category? {
        switch string {
        case "academics":
            return .academics
        case "the arts":
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
        let displayName: String
        let image: UIImage
    }

    struct Subcategory {
        let subcategories: [String]
        let icon: [UIImage]
        let phrase: String
        let displayName: String
        let fileToRead: String
    }
}
